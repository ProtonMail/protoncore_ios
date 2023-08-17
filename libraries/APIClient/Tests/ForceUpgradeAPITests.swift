//
//  ForceUpgradeAPITests.swift
//  ProtonCore-APIClient-Tests - Created on 13/11/20.
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

class ForceUpgradeAPITests: XCTestCase {
    
    var apiService: APIServiceMock!
    let timeout = 1.0
    
    var authInfoResponse: AuthInfoResponse {
        let modulus = "testModulus"
        let serverEphemeral = "testServerEphemeral"
        let salt = "0cNmaaFTYxDdFA=="
        let srpSession = "b7953c6a26d97a8f7a673afb79e6e9ce"
        let version = 1
        return .init(
            modulus: modulus,
            serverEphemeral: serverEphemeral,
            version: version,
            salt: salt,
            srpSession: srpSession
        )
    }
    
    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
    }
    
    func testBadAppVersion() {
        // backend answer when there is no verification token
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse.toErrorResponse(code: 5003, error: "This version of the app is no longer supported, please update from the App Store to continue using it")))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expectation = self.expectation(description: "Success completion block called")
        let authInfoOK = AuthAPI.Router.info(username: "user1")
        apiService.perform(request: authInfoOK, response: authInfoResponse) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 5003)
            XCTAssert(response.error != nil)
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBadApiVersion() {
        // backend answer when there is no verification token
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse.toErrorResponse(code: 5005, error: "This version of the api is no longer supported, please update from the App Store to continue using it")))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        
        let expectation = self.expectation(description: "Success completion block called")
        let authInfoOK = AuthAPI.Router.info(username: "user1")
        apiService.perform(request: authInfoOK, response: authInfoResponse) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 5005)
            XCTAssert(response.error != nil)
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
