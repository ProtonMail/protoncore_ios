//
//  DohTests.swift
//  ProtonCore-Doh-Tests - Created on 4/19/21.
//
//  Copyright (c) 2019 Proton Technologies AG
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

class DoHProviderGoogleTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
            // ...
        }
        
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
 
    func testGoogleProviderInit() {
        let google = Google.init()
        XCTAssertEqual(google.supported.count, 1)
        XCTAssertEqual(DNSType.txt.rawValue, google.supported.first)
    }
    
    func testGoogleUrl() {
        let google = Google.init()
        XCTAssertTrue(google.url.contains("dns.google.com"))
    }

    func testGoogleGetQuery() {
        let google = Google.init()
        let query = google.query(host: "testurl")
        XCTAssertTrue(query.contains("name=testurl"))
    }

    func testGoogleParseString() {
        let google = Google.init()
        let dns = google.parse(response: "abcdefg")
        XCTAssertNil(dns)
    }

    func testGoogleTimeout() {
        stub(condition: isHost("dns.google.com") && isMethodGET() && isPath("/resolve")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            sleep(10)
            let dbody = "{ \"Code\": 1000 }".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 400, headers: [:])
        }
   
        let google = Google.init()
        let dns = google.fetch(sync: "test.host.name")
        XCTAssertNil(dns)
    }
    
    func testGoogleResponse() {
        let google = Google.init()
        let dns = google.fetch(sync: "google.com")
        XCTAssertNotNil(dns)
    }
    
    func testGoogleAsyncResponse() {
        let google = Google.init()
        google.fetch(async: "google.com")
    }
    
    func testGoogleBadResponse1() {
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
        let google = Google.init()
        let dns = google.fetch(sync: "google.com")
        XCTAssertNil(dns)
    }
    
    func testGoogleBadResponse2() {
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
        let google = Google.init()
        let dns = google.fetch(sync: "google.com")
        XCTAssertNil(dns)
    }
    
    func testGoogleBadResponse3() {
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
        let google = Google.init()
        let dns = google.fetch(sync: "google.com")
        XCTAssertNil(dns)
    }
    
}
