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

class AuthAPITests: XCTestCase {

    var apiService: APIServiceMock!
    let timeout = 1.0
    
    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
    }

    func testAuthInfo() {
        let modulus = "testModulus"
        let serverEphemeral = "testServerEphemeral"
        let salt = "0cNmaaFTYxDdFA=="
        let srpSession = "b7953c6a26d97a8f7a673afb79e6e9ce"
        let version = 1
        let authInfoResponse = AuthInfoResponse()
        authInfoResponse.modulus = modulus
        authInfoResponse.serverEphemeral = serverEphemeral
        authInfoResponse.salt = salt
        authInfoResponse.srpSession = srpSession
        authInfoResponse.version = version
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(authInfoResponse.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(AuthInfoRes.from(authInfoResponse.toSuccessfulResponse)))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expectation1 = self.expectation(description: "Success completion block called")
        let authInfoOK = AuthAPI.Router.info(username: "ok")
        apiService.perform(request: authInfoOK, response: AuthInfoResponse()) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            XCTAssertEqual(response.modulus, modulus)
            XCTAssertEqual(response.serverEphemeral, serverEphemeral)
            XCTAssertEqual(response.salt, salt)
            XCTAssertEqual(response.srpSession, srpSession)
            XCTAssertEqual(response.version, version)
            expectation1.fulfill()
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        let authInfoOK1 = AuthAPI.Router.info(username: "ok")
        apiService.perform(request: authInfoOK1) { (task, result: Result<AuthInfoRes, ResponseError>) in
            expectation2.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    /// Test async variants of `perform` methods
    func testAuthInfoAsync() async throws {
        let modulus = "testModulus"
        let serverEphemeral = "testServerEphemeral"
        let salt = "0cNmaaFTYxDdFA=="
        let srpSession = "b7953c6a26d97a8f7a673afb79e6e9ce"
        let version = 1

        let authInfoResponse = AuthInfoResponse()
        authInfoResponse.modulus = modulus
        authInfoResponse.serverEphemeral = serverEphemeral
        authInfoResponse.salt = salt
        authInfoResponse.srpSession = srpSession
        authInfoResponse.version = version

        let authInfoRes = AuthInfoRes()
        authInfoRes.Modulus = modulus
        authInfoRes.ServerEphemeral = serverEphemeral
        authInfoRes.Salt = salt
        authInfoRes.SRPSession = srpSession
        authInfoRes.Version = version

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(authInfoResponse.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(authInfoRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let authInfoOK = AuthAPI.Router.info(username: "ok")
        /// Response conforming to `ResponseType`
        let (_, response1) = await apiService.perform(request: authInfoOK, response: AuthInfoResponse())
        XCTAssertEqual(response1.responseCode, 1000)
        XCTAssert(response1.error == nil)
        XCTAssertEqual(response1.modulus, modulus)
        XCTAssertEqual(response1.serverEphemeral, serverEphemeral)
        XCTAssertEqual(response1.salt, salt)
        XCTAssertEqual(response1.srpSession, srpSession)
        XCTAssertEqual(response1.version, version)

        /// Response as `JSONDictionary`
        let (_, response2) = try await apiService.perform(request: authInfoOK)
        XCTAssertEqual(response2["Modulus"] as? String, modulus)
        XCTAssertEqual(response2["ServerEphemeral"] as? String, serverEphemeral)
        XCTAssertEqual(response2["Salt"] as? String, salt)
        XCTAssertEqual(response2["SRPSession"] as? String, srpSession)
        XCTAssertEqual(response2["Version"] as? Int, version)

        /// Response conforming to `APIDecodableResponse`
        let (_, response3): (URLSessionTask?, AuthInfoRes) = try await apiService.perform(request: authInfoOK)
        XCTAssertEqual(response3.Modulus, modulus)
        XCTAssertEqual(response3.ServerEphemeral, serverEphemeral)
        XCTAssertEqual(response3.Salt, salt)
        XCTAssertEqual(response3.SRPSession, srpSession)
        XCTAssertEqual(response3.Version, version)
    }
    
    func testAuthModulus() {
        let modulus = "testModulus"
        let modulusID = "testModulusID"
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                let authModulusResponse = AuthModulusResponse()
                authModulusResponse.Modulus = modulus
                authModulusResponse.ModulusID = modulusID
                completion(nil, .success(authModulusResponse.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expectation1 = self.expectation(description: "Success completion block called")
        let authModulusOK = AuthAPI.Router.modulus
        apiService.perform(request: authModulusOK, response: AuthModulusResponse()) { (task, response: AuthModulusResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            XCTAssertEqual(response.Modulus, modulus)
            XCTAssertEqual(response.ModulusID, modulusID)
            expectation1.fulfill()
        }
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuth() {
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, completion in
            if path.contains("/auth") {
                let authResponse = AuthResponse()
                authResponse.accessToken = "testAccessToken"
                authResponse.expiresIn = 1000
                authResponse.tokenType = "testTokenType"
                authResponse.userID = "testUserID"
                authResponse.scope = "testScope"
                authResponse.refreshToken = "testRefreshToken"
                completion(nil, .success(authResponse.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expectation1 = self.expectation(description: "Success completion block called")
        let authOK = AuthAPI.Router.auth(username: "ok", ephemeral: "", proof: "", session: "")
        apiService.perform(request: authOK, response: AuthResponse()) { (task, response: AuthResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            expectation1.fulfill()
        }
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
