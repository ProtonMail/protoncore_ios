//
//  AlternativeRoutingRequestInterceptorTests.swift
//  ProtonCore-Doh-Tests - Created on 27/6/22.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.

import XCTest
import ProtonCore_ObfuscatedConstants
@testable import ProtonCore_Doh
import WebKit

class AlternativeRoutingRequestInterceptorTests: XCTestCase {

    var dummyView: WKWebView! = WKWebView()
    var sut: AlternativeRoutingRequestInterceptor! = AlternativeRoutingRequestInterceptor(headersGetter: requestHeaders,
                                                   onAuthenticationChallengeContinuation: { _, _ in })

    override func tearDown() {
        super.tearDown()
        sut = nil
        dummyView = nil
    }

    func testURLSchemeHandlerIsProperlySet() {
        let configuration = WKWebViewConfiguration()

        sut.setup(webViewConfiguration: configuration)
        
        XCTAssert(configuration.urlSchemeHandler(forURLScheme: "coreios") is AlternativeRoutingRequestInterceptor)
        XCTAssert(configuration.urlSchemeHandler(forURLScheme: "coreios") is AlternativeRoutingRequestInterceptor)
        XCTAssertEqual(2, AlternativeRoutingRequestInterceptor.schemeMapping.count, "Please update this test to reflect new scheme handlers")
        
    }
    
    func testResponseRewriting() {
        let url = URL(string: ObfuscatedConstants.testLiveAccountHost + "/lite?action=delete-account")!
        let request = URLRequest(url: url)
        let task = SchemeTaskStub(request: request)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: responseHeadersWithFontSourceInCSP())!
        
        sut.transformAndProcessResponse(response, nil, task)
        
        XCTAssertNotNil(task.receivedResponse)
        let processedResponse = task.receivedResponse as! HTTPURLResponse
        XCTAssertNil(processedResponse.url?.absoluteString.range(of: "-api"))
        let csp = processedResponse.allHeaderFields["Content-Security-Policy"] as? String
        XCTAssertNotNil(csp)
        [
            "script-src",
            "style-src",
            "img-src",
            "frame-src",
            "connect-src",
            "font-src",
        ] .forEach {
            assertContainsCustomSchemes(csp!, $0)
        }
    }

    func testResponseRewritingForResourceTypeNotPresentInResponse() {
        let url = URL(string: ObfuscatedConstants.testLiveAccountHost + "lite?action=delete-account")!
        let request = URLRequest(url: url)
        let task = SchemeTaskStub(request: request)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: responseHeadersWithFontSourceInCSP())!

        sut.transformAndProcessResponse(response, nil, task)

        XCTAssertNotNil(task.receivedResponse)
        let processedResponse = task.receivedResponse as! HTTPURLResponse
        XCTAssertNil(processedResponse.url?.absoluteString.range(of: "-api"))
        let csp = processedResponse.allHeaderFields["Content-Security-Policy"] as? String
        XCTAssertNotNil(csp)
        XCTExpectFailure {
            assertContainsCustomSchemes(csp!, "media-src")
        }
    }

    private static func requestHeaders() -> [String: String] {
        [String: String]()
    }

    private func responseHeadersWithFontSourceInCSP() -> [String: String] {
        [
            "Vary": "Accept-Encoding",
            "Date": "Tue, 28 Jun 2022 16:04:00 GMT",
            "Content-Security-Policy": """
        default-src 'self'; connect-src 'self' blob:; script-src 'self' blob:; style-src 'self' 'unsafe-inline'; img-src http: https: data: blob: cid:; \
        font-src http: https: data: blob: cid:; \
        frame-src 'self' blob: https://secure.protonmail.com https://account-api.proton.black https://verify.proton.black; object-src 'self' blob:; \
        child-src 'self' data: blob:; frame-ancestors https://mail.proton.black https://calendar.proton.black https://drive.proton.black;
        """,
            "Connection": "keep-alive"
        ]
    }

    private func assertContainsCustomSchemes(_ container: String, _ resource: String, file: StaticString = #filePath, line: UInt = #line ) {
        // the interceptor just adds its own schemes right after the resource type,
        // so we can simplify the searched string
        let wanted = "\(resource) coreios: coreioss:"
        XCTAssert(container.contains(wanted), "CSP \(resource) is not handled", file: file, line: line)
    }
}

private class SchemeTaskStub: NSObject, WKURLSchemeTask {
    var request: URLRequest
    var receivedResponse: URLResponse?
    
    init(request: URLRequest) {
        self.request = request
    }
    
    func didReceive(_ response: URLResponse) {
        receivedResponse = response
    }
    
    func didReceive(_ data: Data) {}
    
    func didFinish() {}
    
    func didFailWithError(_ error: Error) {}
}
