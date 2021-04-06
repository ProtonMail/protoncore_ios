//
//  ForceUpgradeAPITests.swift
//  ProtonCore-APIClient-Tests - Created on 13/11/20.
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
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_APIClient

class ForceUpgradeAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in }
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    class DoHMail: DoH, ServerConfig {
        var signupDomain: String = ObfuscatedConstants.blueSignupDomain
        /// defind your default host
        var defaultHost: String = ObfuscatedConstants.blueDefaultHost
        /// defind your default captcha host
        var captchaHost: String = ObfuscatedConstants.blueCaptchaHost
        /// defind your query host
        var apiHost: String = ObfuscatedConstants.blueApiHost
        var defaultPath: String = ObfuscatedConstants.blueDefaultPath
        /// singleton
        static let `default` = try! DoHMail()
        override init() throws {
            
        }
    }
    
    class TestAuthDelegate: AuthDelegate {
        func onForceUpgrade() { }
        var authCredential: AuthCredential?
        func getToken(bySessionUID uid: String) -> AuthCredential? { return nil }
        func onLogout(sessionUID uid: String) { }
        func onUpdate(auth: Credential) { }
        func onRevoke(sessionUID uid: String) { }
        func onRefresh(bySessionUID uid: String, complete: (Credential?, AuthErrors?) -> Void) { }
    }
    
    class TestAPIServiceDelegate: APIServiceDelegate {
        var locale: String { return "en_US" }
        func isReachable() -> Bool { return true }
        var userAgent: String? { return "" }
        func onUpdate(serverTime: Int64) { }
        var appVersion: String { return "iOS_0.0.1" }
        func onDohTroubleshot() { }
        func onHumanVerify() { }
        func onChallenge(challenge: URLAuthenticationChallenge, credential: AutoreleasingUnsafeMutablePointer<URLCredential?>?) -> URLSession.AuthChallengeDisposition {
            return .useCredential
        }
    }
    
    func testBadAppVersion() {
        // backend answer when there is no verification token
        stub(condition: isHost(ObfuscatedConstants.blueDefaultHostWithoutHttps) && isMethodPOST() && isPath("/api/auth/info")) { request in
            let responseString = "{\"Error\": \"This version of the app is no longer supported, please update from the App Store to continue using it\",\"Code\": 5003}"
            let body = responseString.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        
        let expectation = self.expectation(description: "Success completion block called")
        let api = PMAPIService(doh: DoHMail.default, sessionUID: "testSessionUID")
        let testAPIServiceDelegate = TestAPIServiceDelegate()
        api.serviceDelegate = testAPIServiceDelegate
        let authInfoOK = AuthAPI.Router.info(username: "user1")
        api.exec(route: authInfoOK) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 5003)
            XCTAssert(response.error != nil)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBadApiVersion() {
        // backend answer when there is no verification token
        stub(condition: isHost(ObfuscatedConstants.blueDefaultHostWithoutHttps) && isMethodPOST() && isPath("/api/auth/info")) { request in
            let responseString = "{\"Error\": \"This version of the api is no longer supported, please update from the App Store to continue using it\",\"Code\": 5005}"
            let body = responseString.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        
        let expectation = self.expectation(description: "Success completion block called")
        let api = PMAPIService(doh: DoHMail.default, sessionUID: "testSessionUID")
        let testAPIServiceDelegate = TestAPIServiceDelegate()
        api.serviceDelegate = testAPIServiceDelegate
        let authInfoOK = AuthAPI.Router.info(username: "user1")
        api.exec(route: authInfoOK) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 5005)
            XCTAssert(response.error != nil)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
