//
//  AuthenticatorMockTests.swift
//  ProtonCore-Authentication-Tests - Created on 19/02/2020.
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

// swiftlint:disable xctfail_message

import XCTest

import ProtonCoreNetworking
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsAuthentication)
import ProtonCoreTestingToolkitUnitTestsAuthentication
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreAPIClient
import ProtonCoreDataModel
@testable import ProtonCoreAuthentication

class AuthenticatorMockTests: XCTestCase {

    var authenticatorMock: AuthenticatorMock!

    let testCredential = Credential(UID: "testUID", accessToken: "testAccessToken", refreshToken: "testRefreshToken", userName: "testUserName", userID: "testUserID", scopes: ["testScope"])
    let testUser = User(
        ID: "12345",
        name: "test",
        usedSpace: 0,
        usedBaseSpace: 0,
        usedDriveSpace: 0,
        currency: "CHF",
        credit: 0,
        maxSpace: 100000,
        maxBaseSpace: 50000,
        maxDriveSpace: 50000,
        maxUpload: 100000,
        role: 0,
        private: 1,
        subscribed: [],
        services: 0,
        delinquent: 0,
        orgPrivateKey: nil,
        email: "test@user.ch",
        displayName: "test",
        keys: []
    )
    let testExternalAddress = Address(addressID: "123456", domainID: "test", email: "test@user.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 0, displayName: "TEST", signature: "", hasKeys: 0, keys: [])
    let timeout = 1.0

    override func setUp() {
        super.setUp()
        authenticatorMock = AuthenticatorMock()
    }

    func testAuthSuccess() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }

        let expect = expectation(description: "AuthInfo + Auth")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, let passwordMode)):
                XCTAssertEqual(credential, self.testCredential)
                XCTAssertEqual(passwordMode, .one)
            default:
                XCTFail("Auth flow failed")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthNetworkingError() {
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(testResponseError, responseError)
            default:
                XCTFail("Auth flow failed")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthUnauth() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.closeSessionStub.bodyIs { _, _, completion in
            completion(.success(AuthService.EndSessionResponse(code: 1000)))
        }

        let expect = expectation(description: "AuthInfo + Auth + Logout")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            case .success(let stage):
                guard case Authenticator.Status.newCredential(let credential, let passwordMode) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                XCTAssertEqual(credential, self.testCredential)
                XCTAssertEqual(passwordMode, .one)
                self.authenticatorMock.closeSession(credential) { result2 in
                    switch result2 {
                    case .success(let response):
                        XCTAssertEqual(response.code, 1000)
                        XCTAssert(true)
                    case .failure:
                        XCTFail("CloseSession failed")
                    }
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthUnauthNetworkingError() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.closeSessionStub.bodyIs { _, _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth + Logout")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            case .success(let stage):
                guard case Authenticator.Status.newCredential(let credential, let passwordMode) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                XCTAssertEqual(credential, self.testCredential)
                XCTAssertEqual(passwordMode, .one)
                self.authenticatorMock.closeSession(credential) { result2 in
                    switch result2 {
                    case .failure(AuthErrors.networkingError(let responseError)):
                        XCTAssertEqual(testResponseError, responseError)
                    default:
                        XCTFail("CloseSession failed")
                    }
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testWrongAuth2FA() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            let twoFactorContext: TwoFactorContext = (credential: self.testCredential, passwordMode: .two)
            completion(.success(.ask2FA(twoFactorContext)))
        }
        authenticatorMock.confirm2FAStub.bodyIs { _, _, context, completion in
            completion(.failure(AuthErrors.networkingError(ResponseError(httpCode: nil, responseCode: 8002, userFacingMessage: nil, underlyingError: nil))))
        }
        let expect = expectation(description: "AuthInfo + Auth + 2FA")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let status):
                switch status {
                case .updatedCredential, .newCredential:
                    XCTFail()
                    expect.fulfill()
                case let .ask2FA(context):
                    self.authenticatorMock.confirm2FA("555656565655656", context: context) { result in
                        switch result {
                        case .success:
                            XCTFail()
                            expect.fulfill()
                        case let .failure(error):
                            guard case Authenticator.Errors.networkingError(let errorResponse) = error else {
                                XCTFail()
                                expect.fulfill()
                                return
                            }
                            XCTAssertEqual(errorResponse.responseCode, 8002)
                            expect.fulfill()
                        }
                    }
                case .askFIDO2:
                        // TBC in CP-7952
                    break
                case .ssoChallenge:
                    XCTFail("Not expected here")
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthRefresh() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.refreshCredentialStub.bodyIs { _, credential, completion in
            let refreshCredential = Credential(UID: "testUID", accessToken: "testAccessTokenRefresh", refreshToken: "testRefreshTokenRefresh", userName: "testUserName", userID: "testUserID", scopes: ["testScope"])
            completion(.success(.updatedCredential(refreshCredential)))
        }

        let expect = expectation(description: "AuthInfo + Auth + Refresh")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(let firstCredential, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.refreshCredential(firstCredential) { result in
                    defer { expect.fulfill() }
                    guard case Result.success(let stage) = result,
                          case Authenticator.Status.updatedCredential(let updatedCredential) = stage else
                    {
                        return XCTFail("Failed to refresh auth credential")
                    }
                    XCTAssertEqual(updatedCredential.UID, firstCredential.UID)
                    XCTAssertNotEqual(updatedCredential.accessToken, firstCredential.accessToken)
                    XCTAssertNotEqual(updatedCredential.refreshToken, firstCredential.refreshToken)
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthRefreshNetworkingError() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.refreshCredentialStub.bodyIs { _, credential, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth + Refresh")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(let firstCredential, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.refreshCredential(firstCredential) { result in
                    switch result {
                    case .failure(AuthErrors.networkingError(let responseError)):
                        XCTAssertEqual(testResponseError, responseError)
                    default:
                        XCTFail("RefreshCredential failed")
                    }
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUserInfo() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in
            completion(.success(self.testUser))
        }

        let expect = expectation(description: "AuthInfo + Auth + UserInfo")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getUserInfo { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let userInfo):
                        XCTAssertEqual(userInfo.email, self.testUser.email)
                    }

                    expect.fulfill()
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUserInfoNetworkingError() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth + UserInfo")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getUserInfo { result in
                    switch result {
                    case .failure(AuthErrors.networkingError(let responseError)):
                        XCTAssertEqual(testResponseError, responseError)
                    default:
                        XCTFail("GetUserInfo failed")
                    }

                    expect.fulfill()
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUserInfoAndAddressForExternalAccount() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in
            completion(.success(self.testUser))
        }
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in
            completion(.success([self.testExternalAddress]))
        }

        let expect = expectation(description: "AuthInfo + Auth + Addresses")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getUserInfo { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                        expect.fulfill()
                    case .success(let userInfo):
                        XCTAssertEqual(userInfo.name, self.testUser.name)
                        self.authenticatorMock.getAddresses { result in
                            switch result {
                            case let .failure(error):
                                XCTFail(error.localizedDescription)
                            case let .success(addresses):
                                XCTAssertEqual(addresses.filter { $0.type == .externalAddress }.count, 1)
                            }
                            expect.fulfill()
                        }
                    }
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUserInfoAndAddressForExternalAccountNetworkingError() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in
            completion(.success(self.testUser))
        }
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth + Addresses")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getUserInfo { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                        expect.fulfill()
                    case .success(let userInfo):
                        XCTAssertEqual(userInfo.name, self.testUser.name)
                        self.authenticatorMock.getAddresses { result in
                            switch result {
                            case .failure(AuthErrors.networkingError(let responseError)):
                                XCTAssertEqual(testResponseError, responseError)
                            default:
                                XCTFail("GetAddresses failed")
                            }
                            expect.fulfill()
                        }
                    }
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAddresses() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in
            completion(.success([self.testExternalAddress]))
        }

        let expect = expectation(description: "AuthInfo + Auth + Addresses")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getAddresses { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let addresses):
                        XCTAssertFalse(addresses.isEmpty)
                        XCTAssertEqual(addresses.first!.email, self.testExternalAddress.email)
                    }
                    expect.fulfill()
                }

            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAddressesNetworkingError() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth + Addresses")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getAddresses { result in
                    switch result {
                    case .failure(AuthErrors.networkingError(let responseError)):
                        XCTAssertEqual(testResponseError, responseError)
                    default:
                        XCTFail("GetAddresses failed")
                    }
                    expect.fulfill()
                }

            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testKeySalts() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in
            let keySalt = KeySalt(ID: "123", keySalt: "KeySalt")
            completion(.success([keySalt]))
        }

        let expect = expectation(description: "AuthInfo + Auth + KeySalts")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getKeySalts { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let salts):
                        XCTAssertFalse(salts.isEmpty)
                    }

                    expect.fulfill()
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testKeySaltsNetworkingError() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "AuthInfo + Auth + KeySalts")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(let stage):
                guard case Authenticator.Status.newCredential(_, _) = stage else {
                    XCTFail("No credential in auth flow")
                    return expect.fulfill()
                }
                self.authenticatorMock.getKeySalts { result in
                    switch result {
                    case .failure(AuthErrors.networkingError(let responseError)):
                        XCTAssertEqual(testResponseError, responseError)
                    default:
                        XCTFail("GetKeySalts failed")
                    }

                    expect.fulfill()
                }
            case .failure:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameUnavailable() {
        authenticatorMock.checkAvailableUsernameWithoutSpecifyingDomainStub.bodyIs { _, _, completion in
            completion(.failure(AuthErrors.networkingError(ResponseError(httpCode: nil, responseCode: 2500, userFacingMessage: nil, underlyingError: nil))))
        }

        let expect = expectation(description: "UserAvailable")
        authenticatorMock.checkAvailableUsernameWithoutSpecifyingDomain("userName") { result in
            switch result {
            case let .failure(.networkingError(responseError)):
                XCTAssertEqual(responseError.responseCode, 2500)
            case .failure, .success:
                XCTFail("Unavailable username check should fail with proper error")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameAvailable() {
        authenticatorMock.checkAvailableUsernameWithoutSpecifyingDomainStub.bodyIs { _, username, completion in
            XCTAssertEqual(username, "userName")
            completion(.success(()))
        }

        let expect = expectation(description: "UserAvailable")
        authenticatorMock.checkAvailableUsernameWithoutSpecifyingDomain("userName") { result in
            switch result {
            case let .failure(error):
                XCTFail(error.localizedDescription)
            case .success:
                break
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testInternalUnavailable() {
        authenticatorMock.checkAvailableUsernameWithinDomainStub.bodyIs { _, _, _, completion in
            completion(.failure(AuthErrors.networkingError(ResponseError(httpCode: nil, responseCode: 2500, userFacingMessage: nil, underlyingError: nil))))
        }

        let expect = expectation(description: "UserAvailable")
        authenticatorMock.checkAvailableUsernameWithinDomain("userName", domain: "proton.tests") { result in
            switch result {
            case let .failure(.networkingError(responseError)):
                XCTAssertEqual(responseError.responseCode, 2500)
            case .failure, .success:
                XCTFail("Unavailable username check should fail with proper error")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testInternalAvailable() {
        authenticatorMock.checkAvailableUsernameWithinDomainStub.bodyIs { _, username, domain, completion in
            XCTAssertEqual(username, "userName")
            XCTAssertEqual(domain, "proton.tests")
            completion(.success(()))
        }

        let expect = expectation(description: "UserAvailable")
        authenticatorMock.checkAvailableUsernameWithinDomain("userName", domain: "proton.tests") { result in
            switch result {
            case let .failure(error):
                XCTFail(error.localizedDescription)
            case .success:
                break
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGettingRandomModulus() {
        authenticatorMock.getRandomSRPModulusStub.bodyIs { _, completion in
            let modulusEndpointResponse = AuthService.ModulusEndpointResponse(modulus: "test", modulusID: "test")
            completion(.success(modulusEndpointResponse))
        }

        let expect = expectation(description: "Modulus")
        authenticatorMock.getRandomSRPModulus { result in
            switch result {
            case let .failure(error):
                XCTFail(error.localizedDescription)
            case let .success(response):
                XCTAssertFalse(response.modulus.isEmpty)
                XCTAssertFalse(response.modulusID.isEmpty)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGettingRandomModulusNetworkingError() {
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        authenticatorMock.getRandomSRPModulusStub.bodyIs { _, completion in
            completion(.failure(AuthErrors.networkingError(testResponseError)))
        }

        let expect = expectation(description: "Modulus")
        authenticatorMock.getRandomSRPModulus { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(testResponseError, responseError)
            default:
                XCTFail("GetRandomSRPModulus failed")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}

// swiftlint:enable xctfail_message
