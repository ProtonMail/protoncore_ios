//
//  DohTests.swift
//  ProtonCore-Doh-Tests - Created on 4/19/21.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
@testable import ProtonCoreDoh

@available(iOS 15, *)
class DoHProviderQuadTests: XCTestCase {

    var networkingEngine: DoHNetworkingEngine!

    override func setUp() {
        super.setUp()
        // we use a real url session because the mocking is done on the urlsession level with HTTPStubs
        networkingEngine = URLSession.shared
        HTTPStubs.setEnabled(true)
        stubProductionHosts()
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
        networkingEngine = nil
    }

    func testQuad9ProviderInit() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        XCTAssertEqual(quad9.supported.count, 2)
        XCTAssert(quad9.supported.contains(DNSRecordType.txt))
        XCTAssert(quad9.supported.contains(DNSRecordType.a))
    }

    func testQuad9Url() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        XCTAssertTrue(quad9.queryUrl.absoluteString.contains("dns11.quad9.net"))
    }

    func testQuad9GetQuery() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        do {
            let query = quad9.query(host: "testurl", type: .txt, sessionId: nil)
            XCTAssertTrue(query.contains("name=testurl"))
            XCTAssertTrue(query.contains("type=TXT"))
        }
        do {
            let query = quad9.query(host: "testurl", type: .a, sessionId: nil)
            XCTAssertTrue(query.contains("name=testurl"))
            XCTAssertTrue(query.contains("type=A"))
        }
    }

    func testQuad9Timeout() async {
        stubDoHProvidersTimeout()
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "test.host.name", sessionId: nil, timeout: 0.5) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testQuad9Response() async {
        stubDoHProvidersSuccess()
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "doh.query.text.protonpro", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNotNil(dns)
    }

    func testQuad9BadResponse1() async {
        stub(condition: isHost("dns11.quad9.net") && isMethodGET() && isPath("/dns-query")) { request in
            let dbody = "".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
        }
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "quad9.net", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testQuad9BadResponse2() async {
        stub(condition: isHost("dns11.quad9.net") && isMethodGET() && isPath("/dns-query")) { request in
            let dbody = "{\"Status\":3,\"TC\":false,\"RD\":true,\"RA\":true,\"AD\":true,\"CD\":false,\"Question\":[{\"name\":\"test.host.name.\",\"type\":16}],\"Authority\":[{\"name\":\".\",\"type\":6,\"TTL\":86394,\"data\":\"a.root-servers.net. nstld.verisign-grs.com. 2021071901 1800 900 604800 86400\"}]}".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
        }
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "quad9.net", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testQuad9BadResponse3() async {
        stub(condition: isHost("dns11.quad9.net") && isMethodGET() && isPath("/dns-query")) { request in
            let dbody = "[\"Ford\", \"BMW\", \"Fiat\", \"Tonka\"]".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
        }
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "quad9.net", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testQuad9BadResponse4() async {
        stub(condition: isHost("dns11.quad9.net") && isMethodGET() && isPath("/dns-query")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let response = """
            {
            "Status":0,"TC":false,"RD":true,"RA":true,"AD":false,"CD":false,
            "Question":[{"name":"doh.query.text.protonpro.","type":16}],
            "Answer":[
              {"name":"doh.query.text.protonpro","type":16,"TTL":120,"data":"not a url"},
            ]
            }
            """.data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: response, statusCode: 200, headers: [:])
        }
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "quad9.net", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testQuad9BadResponse5() async {
        stub(condition: isHost("dns11.quad9.net") && isMethodGET() && isPath("/dns-query")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let response = """
            {
            "Status":0,"TC":false,"RD":true,"RA":true,"AD":false,"CD":false,
            "Question":[{"name":"doh.query.text.protonpro.","type":16}],
            "Answer":[
              {"name":"doh.query.text.protonpro","type":8,"TTL":120,"data":"actual.url"},
            ]
            }
            """.data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: response, statusCode: 200, headers: [:])
        }
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            quad9.fetch(host: "quad9.net", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testQuad9GetQueryWithSessionID() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let sessionId = "Session123"
        let query = quad9.query(host: "testurl", type: .txt, sessionId: sessionId)
        XCTAssertTrue(query.contains("name=\(sessionId).testurl"))
    }
}
