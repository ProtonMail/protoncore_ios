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

class AuthAPITests: XCTestCase {

    var apiService: APIServiceMock!

    private let timeout = 1.0
    private let modulus = "testModulus"
    private let serverEphemeral = "testServerEphemeral"
    private let salt = "0cNmaaFTYxDdFA=="
    private let srpSession = "b7953c6a26d97a8f7a673afb79e6e9ce"
    private let version = 1

    private var authInfoResponse: AuthInfoResponse {
        .init(
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

    func testAuthInfo_jsonStub() {
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expectation = self.expectation(description: "Success completion block called")
        let authInfoOK = AuthAPI.Router.info(username: "ok")
        apiService.perform(request: authInfoOK, response: authInfoResponse) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            XCTAssertEqual(response.modulus, self.modulus)
            XCTAssertEqual(response.serverEphemeral, self.serverEphemeral)
            XCTAssertEqual(response.salt, self.salt)
            XCTAssertEqual(response.srpSession, self.srpSession)
            XCTAssertEqual(response.version, self.version)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { expectationError -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthInfo_decodableStub() {
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(AuthInfoResponse.from(self.authInfoResponse.toSuccessfulResponse)))
            } else {
                XCTFail()
            }
        }

        let expectation = self.expectation(description: "Success completion block called")
        let authInfoOK1 = AuthAPI.Router.info(username: "ok")
        apiService.perform(request: authInfoOK1) { (task, result: Result<AuthInfoResponse, ResponseError>) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    /// Test async variants of `perform` methods
    func testAuthInfoAsync() async throws {
        let authInfoRes = AuthInfoResponse(
            modulus: modulus,
            serverEphemeral: serverEphemeral,
            version: version,
            salt: salt,
            srpSession: srpSession
        )

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(authInfoRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let authInfoOK = AuthAPI.Router.info(username: "ok")
        /// Response conforming to `ResponseType`
        let (_, response1) = await apiService.perform(request: authInfoOK, response: authInfoResponse)
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
        let (_, response3): (URLSessionTask?, AuthInfoResponse) = try await apiService.perform(request: authInfoOK)
        XCTAssertEqual(response3.modulus, modulus)
        XCTAssertEqual(response3.serverEphemeral, serverEphemeral)
        XCTAssertEqual(response3.salt, salt)
        XCTAssertEqual(response3.srpSession, srpSession)
        XCTAssertEqual(response3.version, version)
    }

    func testAuthModulus() {
        let modulus = "testModulus"
        let modulusID = "testModulusID"
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                let authModulusResponse = AuthModulusResponse()
                authModulusResponse.modulus = modulus
                authModulusResponse.modulusID = modulusID
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
            XCTAssertEqual(response.modulus, modulus)
            XCTAssertEqual(response.modulusID, modulusID)
            expectation1.fulfill()
        }
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuth() {
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4") {
                let authResponse = AuthResponse()
                authResponse.accessToken = "testAccessToken"
                authResponse.tokenType = "testTokenType"
                authResponse.userID = "testUserID"
                authResponse.scopes = ["testScope"]
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

extension AuthInfoResponse: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AuthInfoResponse.CodingKeys.self)
        try container.encode(modulus, forKey: .modulus)
        try container.encode(serverEphemeral, forKey: .serverEphemeral)
        try container.encode(version, forKey: .version)
        try container.encode(salt, forKey: .salt)
        try container.encode(srpSession, forKey: .srpSession)
        try? container.encode(_2FA, forKey: ._2FA)
    }
}
