//
//  AuthenticatorTests.swift
//  ProtonCore-Authentication-Tests - Created on 19/02/2020.
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

import ProtonCore_APIClient
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_TestingToolkit
import ProtonCore_DataModel
@testable import ProtonCore_Authentication
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

class AuthenticatorTests: XCTestCase {
    
    var apiService: APIServiceMock!
    var srpAuthMock: SrpAuthMock!
    
    static let exampleServerProof = "1234"
    let timeout = 1.0
    
    override func setUp() {
        apiService = APIServiceMock()
        srpAuthMock = SrpAuthMock()
        super.setUp()
    }
    
    var authInfoResponse: AuthService.AuthInfoResponse {
        let authInfoResponse = AuthService.AuthInfoResponse()
        authInfoResponse.modulus = "test"
        authInfoResponse.serverEphemeral = "test"
        authInfoResponse.salt = "test"
        authInfoResponse.srpSession = "test"
        return authInfoResponse
    }
    
    var srpProofs: SrpProofsMock {
        let srpProofs = SrpProofsMock()
        srpProofs.clientProof = Data()
        srpProofs.clientEphemeral = Data()
        srpProofs.expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)
        return srpProofs
    }
    
    struct Response: Codable {
        public var code: Int
    }
    
    func authRouteResponse(twoFA: AuthService.AuthRouteResponse.TwoFA) -> AuthService.AuthRouteResponse {
        return AuthService.AuthRouteResponse(code: 1000, accessToken: "accessToken", expiresIn: 100.0, tokenType: "tokenType", refreshToken: "refreshToken", scope: "Scope", UID: "UID", userID: "userID", eventID: "eventID", serverProof: AuthenticatorTests.exampleServerProof, passwordMode: PasswordMode.one, _2FA: twoFA)
    }
    
    // MARK: Authenticate
    
    func testAuthenticateSuccessNewCredential() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else if path.contains("/auth") {
                let twoFA = AuthService.AuthRouteResponse.TwoFA(enabled: .off)
                completion?(nil, self.authRouteResponse(twoFA: twoFA).toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }
        
        let username = "username"
        manager.authenticate(username: username, password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, let passwordMode)):
                let twoFA = AuthService.AuthRouteResponse.TwoFA(enabled: .off)
                let authRouteResponse = self.authRouteResponse(twoFA: twoFA)
                XCTAssertEqual(credential.UID, authRouteResponse.UID)
                XCTAssertEqual(credential.accessToken, authRouteResponse.accessToken)
                XCTAssertEqual(credential.refreshToken, authRouteResponse.refreshToken)
                XCTAssertEqual(credential.expiration.description, Date(timeIntervalSinceNow: authRouteResponse.expiresIn).description)
                XCTAssertEqual(credential.userName, username)
                XCTAssertEqual(credential.userID, authRouteResponse.userID)
                XCTAssertEqual(credential.scope, authRouteResponse.scope.components(separatedBy: " "))
                XCTAssertEqual(passwordMode, PasswordMode.one)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateSuccess2FAOn() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else if path.contains("/auth") {
                let twoFA = AuthService.AuthRouteResponse.TwoFA(enabled: .totp)
                completion?(nil, self.authRouteResponse(twoFA: twoFA).toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }
        
        let username = "username"
        manager.authenticate(username: username, password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .success(Authenticator.Status.ask2FA(let context)):
                let twoFA = AuthService.AuthRouteResponse.TwoFA(enabled: .totp)
                let authRouteResponse = self.authRouteResponse(twoFA: twoFA)
                XCTAssertEqual(context.credential.UID, authRouteResponse.UID)
                XCTAssertEqual(context.credential.accessToken, authRouteResponse.accessToken)
                XCTAssertEqual(context.credential.refreshToken, authRouteResponse.refreshToken)
                XCTAssertEqual(context.credential.expiration.description, Date(timeIntervalSinceNow: authRouteResponse.expiresIn).description)
                XCTAssertEqual(context.credential.userName, username)
                XCTAssertEqual(context.credential.userID, authRouteResponse.userID)
                XCTAssertEqual(context.credential.scope, authRouteResponse.scope.components(separatedBy: " "))
                XCTAssertEqual(context.passwordMode, PasswordMode.one)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateSuccess2FAWebAuthn() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else if path.contains("/auth") {
                let twoFA = AuthService.AuthRouteResponse.TwoFA(enabled: .webAuthn)
                completion?(nil, self.authRouteResponse(twoFA: twoFA).toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.notImplementedYet(let string)):
                XCTAssertEqual("WebAuthn not implemented yet", string)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorUserInfoNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result { 
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorUserInfoPerseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyAuthInfoResponse = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyAuthInfoResponseMissingSalt() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let authInfoRes = self.authInfoResponse
                authInfoRes.salt = nil
                completion?(nil, authInfoRes.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyAuthInfoResponse = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorEmptyAuthInfoResponseMissingModulus() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let authInfoRes = self.authInfoResponse
                authInfoRes.modulus = nil
                completion?(nil, authInfoRes.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyAuthInfoResponse = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorEmptyAuthInfoResponseMissingServerEphemeral() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let authInfoRes = self.authInfoResponse
                authInfoRes.serverEphemeral = nil
                completion?(nil, authInfoRes.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyAuthInfoResponse = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorEmptyAuthInfoResponseMissingSrpSession() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let authInfoRes = self.authInfoResponse
                authInfoRes.srpSession = nil
                completion?(nil, authInfoRes.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyAuthInfoResponse = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorSrpAuth() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.authenticate(username: "username", password: "password") { result in
            switch result {
            case .failure(let error):
                if case .emptyServerSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorEmptyClientSrpAuthException() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            // throw exception here
            throw AuthErrors.notImplementedYet("generateProofs error")
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.parsingError(let error)):
                let resp = error as? AuthErrors
                if case .notImplementedYet(let message) = resp {
                    XCTAssertEqual("generateProofs error", message)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorEmptyClientSrpAuthEmptyClientProof() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = nil
            srpProofs.clientEphemeral = Data()
            srpProofs.expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)
            return srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthEmptyClientEphemeral() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = Data()
            srpProofs.clientEphemeral = nil
            srpProofs.expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)
            return srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorEmptyClientSrpAuthEmptyExpectedServerProof() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = Data()
            srpProofs.clientEphemeral = Data()
            srpProofs.expectedServerProof = nil
            return srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthEmptyExpectedServerProofParse() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = Data()
            srpProofs.clientEphemeral = Data()
            srpProofs.expectedServerProof = Data(base64Encoded: "Wrong data")
            return srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorAuthNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else if path.contains("/auth") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorAuthPerseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else if path.contains("/auth") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testAuthenticateErrorWrongServerProof() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion?(nil, self.authInfoResponse.toSuccessfulResponse, nil)
            } else if path.contains("/auth") {
                let twoFA = AuthService.AuthRouteResponse.TwoFA(enabled: .off)
                completion?(nil, self.authRouteResponse(twoFA: twoFA).toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = self.srpProofs
            srpProofs.expectedServerProof = Data(base64Encoded: "1239")
            return srpProofs
        }
        
        manager.authenticate(username: "username", password: "password", srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .wrongServerProof = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: Confirm2FA

    func testConfirm2FASucess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        let response = AuthService.TwoFAResponse(code: 1000, scope: "Scope")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/2fa") {
                completion?(nil, response.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope1", "Scope2"])
        let context = TwoFactorContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, let passwordMode)):
                XCTAssertEqual(credential.UID, testCredential.UID)
                XCTAssertEqual(credential.accessToken, testCredential.accessToken)
                XCTAssertEqual(credential.refreshToken, testCredential.refreshToken)
                XCTAssertEqual(credential.expiration, testCredential.expiration)
                XCTAssertEqual(credential.userName, testCredential.userName)
                XCTAssertEqual(credential.userID, testCredential.userID)
                XCTAssertEqual(credential.scope.count, 1)
                XCTAssertEqual(credential.scope.first, response.scope)
                XCTAssertEqual(passwordMode, .one)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testConfirm2FAErrorResponseParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/2fa") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        let context = TwoFactorContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testConfirm2FAErrorResponseNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/2fa") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        let context = TwoFactorContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: refreshCredential
    
    func testRefreshCredentialSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        let refreshResponse = AuthService.RefreshResponse(code: 1000, accessToken: "accessToken", expiresIn: 1000, tokenType: "tokenType", scope: "Scope", refreshToken: "refreshToken")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/refresh") {
                completion?(nil, refreshResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .success(Authenticator.Status.updatedCredential(let updatedCredential)):
                XCTAssertEqual(updatedCredential.UID, testCredential.UID)
                XCTAssertEqual(updatedCredential.accessToken, refreshResponse.accessToken)
                XCTAssertEqual(updatedCredential.refreshToken, refreshResponse.refreshToken)
                XCTAssertEqual(updatedCredential.expiration.description, Date(timeIntervalSinceNow: refreshResponse.expiresIn).description)
                XCTAssertEqual(updatedCredential.userName, testCredential.userName)
                XCTAssertEqual(updatedCredential.userID, testCredential.userID)
                XCTAssertEqual(updatedCredential.scope, refreshResponse.scope.components(separatedBy: " "))
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testRefreshCredentialErrorResponseParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/refresh") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
        
    func testRefreshCredentialErrorNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/refresh") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: checkAvailable
    
    func testCheckAvailableSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "checkAvailable")
        let userName = "userName"
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users" + "/available?Name=") {
                XCTAssertTrue(path.contains(userName))
                let userAvailableResponse = AuthService.UserAvailableResponse(code: 1000)
                completion?(nil, userAvailableResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.checkAvailable(userName) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCheckAvailableErrorUsernameAlreadyUsed() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "checkAvailable")
        let userName = "userName"
        let nsError = NSError(domain: "ProtonCore-Networking", code: 12106, userInfo: ["NSLocalizedDescription": "Username already used"])
        let testResponseError = ResponseError(httpCode: 409, responseCode: 12106, userFacingMessage: "Username already used", underlyingError: nsError)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users" + "/available?Name=") {
                XCTAssertTrue(path.contains(userName))
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.checkAvailable(userName) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: setUsername
    
    func testSetUsernameSuccess() {
        let manager = Authenticator(api: apiService)
        let expect1 = expectation(description: "setUsername")
        let expect2 = expectation(description: "setUsername without credentials")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/settings/username") {
                let setUsernameResponse = AuthService.SetUsernameResponse(code: 1000)
                completion?(nil, setUsernameResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.setUsername(testCredential, username: "username") { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect1.fulfill()
        }
        
        manager.setUsername(nil, username: "username") { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testSetUsernameNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "setUsername")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/settings/username") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.setUsername(nil, username: "username") { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: createAddress
    
    func testCreateAddressSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        let key = Key(keyID: "keyID", privateKey: "privateKey")
        let testAddress = Address(addressID: "addressID", domainID: "domainID", email: "email@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName", signature: "signature", hasKeys: 100, keys: [key])
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                let response = AuthService.CreateAddressEndpointResponse(code: 1000, address: testAddress)
                completion?(nil, response.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", siganture: "siganture") { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, testAddress)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCreateAddressParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", siganture: "siganture") { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCreateAddressNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", siganture: "siganture") { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: createUser
    
    func testCreateUserSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                let response = Response(code: 1000)
                completion?(nil, response.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", deviceToken: "deviceToken")
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCreateUserNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", deviceToken: "deviceToken")
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: createExternalUser

    func testCreateExternalUserSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createExternalUser")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users/external") {
                let response = Response(code: 1000)
                completion?(nil, response.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let externalUserParameters = ExternalUserParameters(email: "email@email.ch", modulusID: "modulusID", salt: "salt", verifer: "verifer", deviceToken: "deviceToken", challenge: [["challenge": "challenge"]], verifyToken: "verifyToken")
        manager.createExternalUser(externalUserParameters: externalUserParameters) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCreateExternalUserNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createExternalUser")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users/external") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let externalUserParameters = ExternalUserParameters(email: "email@email.ch", modulusID: "modulusID", salt: "salt", verifer: "verifer", deviceToken: "deviceToken", challenge: [["challenge": "challenge"]], verifyToken: "verifyToken")
        manager.createExternalUser(externalUserParameters: externalUserParameters) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: getUserInfo
    
    func testGetUserInfoSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        let key = Key(keyID: "keyID", privateKey: "privateKey")
        let testUser = User(ID: "ID", name: "name", usedSpace: 1000, currency: "USD", credit: 0, maxSpace: 1000000, maxUpload: 100000, role: 1, private: 2, subscribed: 3, services: 4, delinquent: 0, orgPrivateKey: "orgPrivateKey", email: "email@email.ch", displayName: "displayName", keys: [key])
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                let userResponse = AuthService.UserResponse(code: 1000, user: testUser)
                completion?(nil, userResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user, testUser)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testGetUserInfoParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetUserInfoNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: getAddresses
    
    func testGetAddressesSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        let key1 = Key(keyID: "keyID", privateKey: "privateKey")
        let key2 = Key(keyID: "keyID2", privateKey: "privateKey2")
        let testAddress1 = Address(addressID: "addressID", domainID: "domainID", email: "email@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName", signature: "signature", hasKeys: 100, keys: [key1])
        let testAddress2 = Address(addressID: "addressID2", domainID: "domainID2", email: "email2@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName2", signature: "signature2", hasKeys: 100, keys: [key1, key2])
        let testAddresses = [testAddress1, testAddress2]
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                let response = AuthService.AddressesResponse(code: 1000, addresses: testAddresses)
                completion?(nil, response.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, testAddresses)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testGetAddressesParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetAddressesNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: getKeySalts
    
    func testGetKeySaltsSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        let keySalt1 = KeySalt(ID: "ID1", keySalt: "keySalt1")
        let keySalt2 = KeySalt(ID: "ID2", keySalt: "keySalt2")
        let testKeySalts = [keySalt1, keySalt2]
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                let response = AuthService.KeySaltsResponse(code: 1000, keySalts: testKeySalts)
                completion?(nil, response.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, testKeySalts)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testGetKeySaltsParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetKeySaltsNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: closeSession
    
    func testCloseSessionSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "closeSession")
        let testResponse = AuthService.EndSessionResponse(code: 1000)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth") {
                completion?(nil, testResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.closeSession(testCredential) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, testResponse)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCloseSessionNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "closeSession")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userID", scope: ["Scope"])
        manager.closeSession(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: getRandomSRPModulus
    
    func testGetRandomSRPModulusSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        let modulusEndpointResponse = AuthService.ModulusEndpointResponse(modulus: "modulus", modulusID: "modulusID", code: 1000)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                completion?(nil, modulusEndpointResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.getRandomSRPModulus { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, modulusEndpointResponse)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testGetRandomSRPModulusParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                let wrongResponse = ["Test": 123]
                completion?(nil, wrongResponse.toSuccessfulResponse, nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.getRandomSRPModulus { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testGetRandomSRPModulusNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                completion?(nil, nil, AuthErrors.networkingError(testResponseError) as NSError)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        
        manager.getRandomSRPModulus { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
