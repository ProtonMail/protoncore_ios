//
//  AuthFlowTests.swift
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

import XCTest

import ProtonCoreAPIClient
import ProtonCoreDoh
import ProtonCoreNetworking
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsAuthentication)
import ProtonCoreTestingToolkitUnitTestsAuthentication
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreDataModel
@testable import ProtonCoreAuthentication

class AuthFlowTests: XCTestCase {

    var authenticatorMock: AuthenticatorMock!

    let testCredential = Credential(UID: "testUID", accessToken: "testAccessToken", refreshToken: "testRefreshToken", userName: "testUserName", userID: "testUserID", scopes: ["testScope"])
    let refreshCredential = Credential(UID: "testUID", accessToken: "testAccessTokenRefresh", refreshToken: "testRefreshTokenRefresh", userName: "testUserName", userID: "testUserID", scopes: ["testScope"])
    let testExternalAddress = Address(addressID: "123456", domainID: "test", email: "test@user.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 0, displayName: "TEST", signature: "", hasKeys: 0, keys: [])
    let timeout = 1.0

    override func setUp() {
        super.setUp()
        authenticatorMock = AuthenticatorMock()
    }

    var authCredential: AuthCredential?

    func testAutoAuthRefresh() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.refreshCredentialStub.bodyIs { _, credential, completion in
            completion(.success(.updatedCredential(self.refreshCredential)))
        }
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in
            completion(.success([self.testExternalAddress]))
        }
        authenticatorMock.closeSessionStub.bodyIs { _, _, completion in
            completion(.success(AuthService.EndSessionResponse(code: 1000)))
        }

        let expect = expectation(description: "AuthInfo + Auth")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let firstCredential, _)):
                self.authCredential = AuthCredential(firstCredential)
                self.authenticatorMock.getAddresses { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                        expect.fulfill()
                    case .success(let addresses):
                        XCTAssertFalse(addresses.isEmpty)
                        self.authenticatorMock.refreshCredential(firstCredential) { result1 in
                            guard case Result.success(let stage) = result1,
                                  case Authenticator.Status.updatedCredential(let updatedCredential) = stage else
                            {
                                return XCTFail("Failed to refresh auth credential")
                            }
                            XCTAssertEqual(updatedCredential.UID, firstCredential.UID)
                            XCTAssertNotEqual(updatedCredential.accessToken, firstCredential.accessToken)
                            XCTAssertNotEqual(updatedCredential.refreshToken, firstCredential.refreshToken)
                            self.authenticatorMock.getAddresses { result in
                                switch result {
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                    expect.fulfill()
                                case .success(let addresses):
                                    XCTAssertFalse(addresses.isEmpty)
                                    self.authenticatorMock.closeSession( Credential( self.authCredential!)) { result2 in
                                        switch result2 {
                                        case .success(let response):
                                            XCTAssertEqual(response.code, 1000)
                                            XCTAssert(true)
                                            self.authenticatorMock.getAddresses { result in
                                                switch result {
                                                case .failure(let error):
                                                    if error.codeInNetworking == -1011 && error.underlyingError.code == -1011 {
                                                        let errstr = error.localizedDescription
                                                        XCTAssertEqual(errstr, "Request failed: client error (422)")
                                                    } else {
                                                        XCTAssertEqual(error.underlyingError.code, 422)
                                                        XCTAssertEqual(error.codeInNetworking, 422)
                                                    }
                                                    expect.fulfill()
                                                case .success(let addresses):
                                                    XCTAssertFalse(addresses.isEmpty)
                                                    expect.fulfill()
                                                }
                                            }
                                        case .failure:
                                            XCTFail("Auth flow failed")
                                            expect.fulfill()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect.fulfill()
            default:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        let result = XCTWaiter.wait(for: [expect], timeout: timeout)
        XCTAssertTrue( result == .completed )
    }

    func testAutoAuthRefreshRaceCondition() {
        authenticatorMock.authenticateStub.bodyIs { _, _, _, _, _, _, completion in
            completion(.success(.newCredential(self.testCredential, .one)))
        }
        authenticatorMock.refreshCredentialStub.bodyIs { _, credential, completion in
            completion(.success(.updatedCredential(self.refreshCredential)))
        }
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in
            completion(.success([self.testExternalAddress]))
        }

        let expect0 = expectation(description: "AuthInfo + Auth")
        let expect1 = expectation(description: "AuthInfo + Auth")
        let expect2 = expectation(description: "AuthInfo + Auth")
        authenticatorMock.authenticate(username: "username", password: "password", challenge: nil, intent: nil, srpAuth: nil) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let firstCredential, _)):
                self.authCredential = AuthCredential(firstCredential)
                expect0.fulfill()
                ///
                self.authenticatorMock.getAddresses { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let addresses):
                        XCTAssertFalse(addresses.isEmpty)
                        self.authenticatorMock.refreshCredential(firstCredential) { result1 in
                            guard case Result.success(let stage) = result1,
                                  case Authenticator.Status.updatedCredential(let updatedCredential) = stage else
                            {
                                return XCTFail("Failed to refresh auth credential")
                            }
                            XCTAssertEqual(updatedCredential.UID, firstCredential.UID)
                            XCTAssertNotEqual(updatedCredential.accessToken, firstCredential.accessToken)
                            XCTAssertNotEqual(updatedCredential.refreshToken, firstCredential.refreshToken)
                            self.authenticatorMock.getAddresses { result in
                                switch result {
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                case .success(let addresses):
                                    XCTAssertFalse(addresses.isEmpty)
                                    expect1.fulfill()
                                }
                            }
                            self.authenticatorMock.getAddresses { result in
                                switch result {
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                case .success(let addresses):
                                    XCTAssertFalse(addresses.isEmpty)
                                    expect2.fulfill()
                                }
                            }
                        }
                    }
                }
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect0.fulfill()
                expect1.fulfill()
                expect2.fulfill()
            default:
                XCTFail("Auth flow failed")
                expect0.fulfill()
                expect1.fulfill()
                expect2.fulfill()
            }
        }
        let result = XCTWaiter.wait(for: [expect0, expect1, expect2], timeout: timeout)
        XCTAssertTrue( result == .completed )
    }

    func testAuthInvalidAccessTokenError() {
        let underlyingError = NSError(domain: "ProtonCore-Networking", code: 10013, localizedDescription: "Invalid refresh token")
        let error = AuthErrors.networkingError(.init(httpCode: 401, responseCode: nil, userFacingMessage: nil, underlyingError: underlyingError))
        XCTAssertTrue(error.isInvalidAccessToken)
    }

    func testAuthNetworkingNotInvalidAccessTokenError() {
        let underlyingError = NSError(domain: "ProtonCore-Networking", code: 100, localizedDescription: "test")
        let error = AuthErrors.networkingError(.init(httpCode: 300, responseCode: nil, userFacingMessage: nil, underlyingError: underlyingError))
        XCTAssertFalse(error.isInvalidAccessToken)
    }
}
