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
@testable import ProtonCore_Doh

@available(iOS 15, *)
class DoHProviderQuadTests: XCTestCase {
    
    var networkingEngine: DoHNetworkingEngine!
    
    override func setUp() {
        super.setUp()
        // we use a real url session because the mocking is done on the urlsession level with HTTPStubs
        networkingEngine = URLSession.shared
        HTTPStubs.setEnabled(true)
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
        networkingEngine = nil
    }
 
    func testQuad9ProviderInit() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        XCTAssertEqual(quad9.supported.count, 1)
        XCTAssertEqual(DNSType.txt.rawValue, quad9.supported.first)
    }
    
    func testQuad9Url() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        XCTAssertTrue(quad9.url.contains("dns11.quad9.net"))
    }

    func testQuad9GetQuery() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let query = quad9.query(host: "testurl", sessionId: nil)
        XCTAssertTrue(query.contains("name=testurl"))
    }

    func testQuad9ParseString() {
        let quad9 = Quad9(networkingEngine: networkingEngine)
        let dns = quad9.parse(response: "abcdefg")
        XCTAssertNil(dns)
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
            let dbody = "[\"Ford\", \"BMW\", \"Fiat\"]".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
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
        let query = quad9.query(host: "testurl", sessionId: sessionId)
        XCTAssertTrue(query.contains("name=\(sessionId).testurl"))
    }
}
