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
class DoHProviderGoogleTests: XCTestCase {

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

    func testGoogleProviderInit() {
        let google = Google(networkingEngine: networkingEngine)
        XCTAssertEqual(google.supported.count, 2)
        XCTAssert(google.supported.contains(DNSRecordType.txt))
        XCTAssert(google.supported.contains(DNSRecordType.a))
    }

    func testGoogleUrl() {
        let google = Google(networkingEngine: networkingEngine)
        XCTAssertTrue(google.queryUrl.absoluteString.contains("dns.google.com"))
    }

    func testGoogleGetQuery() {
        let google = Google(networkingEngine: networkingEngine)
        do {
            let query = google.query(host: "testurl", type: .txt, sessionId: nil)
            XCTAssertTrue(query.contains("name=testurl"))
            XCTAssertTrue(query.contains("type=TXT"))
        }
        do {
            let query = google.query(host: "testurl", type: .a, sessionId: nil)
            XCTAssertTrue(query.contains("name=testurl"))
            XCTAssertTrue(query.contains("type=A"))
        }
    }

    func testGoogleTimeout() async {
        stubDoHProvidersTimeout()
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "test.host.name", sessionId: nil, timeout: 0.5) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testGoogleResponse() async {
        stubDoHProvidersSuccess()
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "doh.query.text.protonpro", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNotNil(dns)
    }

    func testGoogleBadResponse1() async {
        stub(condition: isHost("dns.google.com") && isMethodGET() && isPath("/resolve")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let dbody = "".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
        }
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "google.com", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testGoogleBadResponse2() async {
        stub(condition: isHost("dns.google.com") && isMethodGET() && isPath("/resolve")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let dbody = "{\"Status\":3,\"TC\":false,\"RD\":true,\"RA\":true,\"AD\":true,\"CD\":false,\"Question\":[{\"name\":\"test.host.name.\",\"type\":16}],\"Authority\":[{\"name\":\".\",\"type\":6,\"TTL\":86394,\"data\":\"a.root-servers.net. nstld.verisign-grs.com. 2021071901 1800 900 604800 86400\"}]}".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
        }
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "google.com", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testGoogleBadResponse3() async {
        stub(condition: isHost("dns.google.com") && isMethodGET() && isPath("/resolve")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let dbody = "[\"Ford\", \"BMW\", \"Fiat\"]".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 200, headers: [:])
        }
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "google.com", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testGoogleBadResponse4() async {
        stub(condition: isHost("dns.google.com") && isMethodGET() && isPath("/resolve")) { request in
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
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "google.com", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testGoogleBadResponse5() async {
        stub(condition: isHost("dns.google.com") && isMethodGET() && isPath("/resolve")) { request in
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
        let google = Google(networkingEngine: networkingEngine)
        let dns = await withCheckedContinuation { continuation in
            google.fetch(host: "google.com", sessionId: nil) { continuation.resume(returning: $0) }
        }
        XCTAssertNil(dns)
    }

    func testGoogleGetQueryWithSessionID() {
        let google = Google(networkingEngine: networkingEngine)
        let sessionId = "Session123"
        let query = google.query(host: "testurl", type: .txt, sessionId: sessionId)
        XCTAssertTrue(query.contains("name=\(sessionId).testurl"))
    }
}
