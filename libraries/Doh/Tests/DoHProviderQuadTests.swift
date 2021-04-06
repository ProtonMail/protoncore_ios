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

class DoHProviderQuadTests: XCTestCase {
    
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
 
    func testDohGeturl() {
        do {
            let doh = try DohMock.init()
            let url = doh.getHostUrl()
            XCTAssertEqual(url, MockData.testHost1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDohGetUrlConcurrent() {
        let concurrentQueue = DispatchQueue(label: "com.queue.Concurrent", attributes: .concurrent)
        for _ in 1...50 {
            concurrentQueue.async {
                do {
                    let doh = try DohMock.init()
                    let url = doh.getHostUrl()
                    XCTAssertEqual(url, MockData.testHost1)
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }
    
    func testDohTimeout() {
        stub(condition: isHost("dns.google.com")) { request in
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
   
        do {
            let doh = try DohMock.init()
            let url = doh.getHostUrl()
            XCTAssertEqual(url, MockData.testHost1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
