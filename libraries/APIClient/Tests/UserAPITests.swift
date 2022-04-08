//
//  UserAPITests.swift
//  ProtonCore-APIClient-Tests - Created on 9/17/18.
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

import ProtonCore_TestingToolkit
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_APIClient

class UserAPITests: XCTestCase {
    
    var apiService: APIServiceMock!

    struct Response: Codable {
        public var code: Int
    }
    
    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
    }

    func testUserAvailable() {
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users/available") {
                var dict = [String: Any]()
                if let components = URLComponents(url: URL(string: path)!, resolvingAgainstBaseURL: false) {
                    if let queryItems = components.queryItems {
                        for item in queryItems {
                            dict[item.name] = item.value!
                        }
                    }
                }
                let value = dict["Name"] as! String
                switch value {
                case "ok":
                    let response = Response(code: 200)
                    completion?(nil, response.toSuccessfulResponse, nil)
                case "InvalidCharacters":
                    let response = Response(code: 400)
                    completion?(nil, response.toErrorResponse(code: 12102, error: "Invalid characters"), nil)
                case "StartSpecialCharacter":
                    let response = Response(code: 400)
                    completion?(nil, response.toErrorResponse(code: 12103, error: "Username start with special character"), nil)
                case "EndSpecialCharacter":
                    let response = Response(code: 400)
                    completion?(nil, response.toErrorResponse(code: 12104, error: "Username end with special character"), nil)
                case "UsernameToolong":
                    let response = Response(code: 400)
                    completion?(nil, response.toErrorResponse(code: 12105, error: "Username too long"), nil)
                case "UsernameAlreadyUsed":
                    let response = Response(code: 400)
                    completion?(nil, response.toErrorResponse(code: 12106, error: "Username already used"), nil)
                default:
                    completion?(nil, nil, nil)
                }
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let expectation1 = self.expectation(description: "Success completion block called")
        let checkNameOk = UserAPI.Router.checkUsername("ok")
        apiService.exec(route: checkNameOk, responseObject: ProtonCore_Networking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            expectation1.fulfill()
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        let checkNameInvalidChar = UserAPI.Router.checkUsername("InvalidCharacters")
        apiService.exec(route: checkNameInvalidChar, responseObject: ProtonCore_Networking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12102)
            XCTAssertEqual(response.error?.userFacingMessage, "Invalid characters")
            XCTAssert(response.error != nil)
            expectation2.fulfill()
        }
        
        let expectation3 = self.expectation(description: "Success completion block called")
        let startSpecialCharacter = UserAPI.Router.checkUsername("StartSpecialCharacter")
        apiService.exec(route: startSpecialCharacter, responseObject: ProtonCore_Networking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12103)
            XCTAssertEqual(response.error?.userFacingMessage, "Username start with special character")
            XCTAssert(response.error != nil)
            expectation3.fulfill()
        }
        
        let expectation4 = self.expectation(description: "Success completion block called")
        let endSpecialCharacter = UserAPI.Router.checkUsername("EndSpecialCharacter")
        apiService.exec(route: endSpecialCharacter, responseObject: ProtonCore_Networking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12104)
            XCTAssertEqual(response.error?.userFacingMessage, "Username end with special character")
            XCTAssert(response.error != nil)
            expectation4.fulfill()
        }

        let expectation5 = self.expectation(description: "Success completion block called")
        let usernameToolong = UserAPI.Router.checkUsername("UsernameToolong")
        apiService.exec(route: usernameToolong, responseObject: ProtonCore_Networking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12105)
            XCTAssertEqual(response.error?.userFacingMessage, "Username too long")
            XCTAssert(response.error != nil)
            expectation5.fulfill()
        }
        
        let expectation6 = self.expectation(description: "Success completion block called")
        let usernameAlreadyUsed = UserAPI.Router.checkUsername("UsernameAlreadyUsed")
        apiService.exec(route: usernameAlreadyUsed, responseObject: ProtonCore_Networking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12106)
            XCTAssertEqual(response.error?.userFacingMessage, "Username already used")
            XCTAssert(response.error != nil)
            expectation6.fulfill()
        }
        self.waitForExpectations(timeout: 1.0) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
