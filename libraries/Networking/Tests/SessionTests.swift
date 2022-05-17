//
//  SessionTests.swift
//  ProtonCore-Networking-Tests - Created on 9/17/18.
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
@testable import ProtonCore_Networking

@available(iOS 13.0.0, *)
class SessionTests: XCTestCase {

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

    func testProgress() {
        /*let sub = */stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            let body = "{ \"data\": 1 }".data(using: String.Encoding.utf8)!
            let headers = [ "Content-Type": "application/json"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        let expectation1 = self.expectation(description: "Success completion block called")
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, response, error in
            expectation1.fulfill()
        } uploadProgress: { pregress in
        }

        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testHeaderUpdate() {
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30)
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.updateHeader()
    }
    
    func testSessionDoesNotFollowRedirects() async throws {
        stub(condition: isHost("proton.unittests") && isPath("/redirect")) { _ in
                .init(jsonObject: [:], statusCode: 301, headers: ["Location": "https://proton.unittests/other_endpoint"])
        }
        stub(condition: isHost("proton.unittests") && isPath("/other_endpoint")) { _ in
                .init(jsonObject: [:], statusCode: 404, headers: [:])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://proton.unittests/redirect", method: .get, timeout: 30)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { continuation.resume(returning: ($0, $1, $2)) }
        }
        let error = try XCTUnwrap(result.2)
        XCTAssertEqual(error.code, 301)
    }
}
