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

#if canImport(ProtonCoreTestingToolkitUnitTestsAuthentication)
import ProtonCoreTestingToolkitUnitTestsAuthentication
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreDoh
import ProtonCoreNetworking
import ProtonCoreServices
@testable import ProtonCoreAPIClient

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
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
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
                    completion(nil, .success(response.toSuccessfulResponse))
                case "InvalidCharacters":
                    let response = Response(code: 400)
                    completion(nil, .success(response.toErrorResponse(code: 12102, error: "Invalid characters")))
                case "StartSpecialCharacter":
                    let response = Response(code: 400)
                    completion(nil, .success(response.toErrorResponse(code: 12103, error: "Username start with special character")))
                case "EndSpecialCharacter":
                    let response = Response(code: 400)
                    completion(nil, .success(response.toErrorResponse(code: 12104, error: "Username end with special character")))
                case "UsernameToolong":
                    let response = Response(code: 400)
                    completion(nil, .success(response.toErrorResponse(code: 12105, error: "Username too long")))
                case "UsernameAlreadyUsed":
                    let response = Response(code: 400)
                    completion(nil, .success(response.toErrorResponse(code: 2500, error: "Username already used")))
                default:
                    completion(nil, .success([:]))
                }
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        
        let expectation1 = self.expectation(description: "Success completion block called")
        let checkNameOk = UserAPI.Router.checkUsername("ok")
        apiService.perform(request: checkNameOk, response: ProtonCoreNetworking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            expectation1.fulfill()
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        let checkNameInvalidChar = UserAPI.Router.checkUsername("InvalidCharacters")
        apiService.perform(request: checkNameInvalidChar, response: ProtonCoreNetworking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12102)
            XCTAssertEqual(response.error?.userFacingMessage, "Invalid characters")
            XCTAssert(response.error != nil)
            expectation2.fulfill()
        }
        
        let expectation3 = self.expectation(description: "Success completion block called")
        let startSpecialCharacter = UserAPI.Router.checkUsername("StartSpecialCharacter")
        apiService.perform(request: startSpecialCharacter, response: ProtonCoreNetworking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12103)
            XCTAssertEqual(response.error?.userFacingMessage, "Username start with special character")
            XCTAssert(response.error != nil)
            expectation3.fulfill()
        }
        
        let expectation4 = self.expectation(description: "Success completion block called")
        let endSpecialCharacter = UserAPI.Router.checkUsername("EndSpecialCharacter")
        apiService.perform(request: endSpecialCharacter, response: ProtonCoreNetworking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12104)
            XCTAssertEqual(response.error?.userFacingMessage, "Username end with special character")
            XCTAssert(response.error != nil)
            expectation4.fulfill()
        }

        let expectation5 = self.expectation(description: "Success completion block called")
        let usernameToolong = UserAPI.Router.checkUsername("UsernameToolong")
        apiService.perform(request: usernameToolong, response: ProtonCoreNetworking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 12105)
            XCTAssertEqual(response.error?.userFacingMessage, "Username too long")
            XCTAssert(response.error != nil)
            expectation5.fulfill()
        }
        
        let expectation6 = self.expectation(description: "Success completion block called")
        let usernameAlreadyUsed = UserAPI.Router.checkUsername("UsernameAlreadyUsed")
        apiService.perform(request: usernameAlreadyUsed, response: ProtonCoreNetworking.Response()) { (task, response) in
            XCTAssertEqual(response.responseCode, 2500)
            XCTAssertEqual(response.error?.userFacingMessage, "Username already used")
            XCTAssert(response.error != nil)
            expectation6.fulfill()
        }
        self.waitForExpectations(timeout: 1.0) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
