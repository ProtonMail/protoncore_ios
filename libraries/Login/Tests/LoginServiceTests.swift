//
//  LoginServiceTests.swift
//  ProtonCore-Login-Tests - Created on 11/11/2020.
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
import Crypto

import ProtonCore_TestingToolkit

import ProtonCore_Authentication
import ProtonCore_Authentication_KeyGeneration
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Login

class LoginServiceTests: XCTestCase {
    var authInfoRequestData: [String: Any]?
    var server: SrpServer?
    
    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    func testLoginWithWrongPassword() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        mockInvalidCredentialsLogin()

        let expect = expectation(description: "testLoginWithWrongPassword")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: "ddssd") { result in
            switch result {
            case .success:
                XCTFail("Sign in with wrong password should fail")
            case let .failure(error):
                switch error {
                case .invalidCredentials:
                    break // all OK
                default:
                    XCTFail("Wrong error")
                }
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }

        _ = authDelegate
        _ = serviceDelegate
    }

    func testLoginWithNonExistentUser() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockNonExistentUserLogin()

        let expect = expectation(description: "testLoginWithNonExistentUser")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: "nonExistentUserName", password: "MadeUpPassword") { result in
            switch result {
            case .success:
                XCTFail("Sign in with wrong password should fail")
            case let .failure(error):
                switch error {
                case .invalidCredentials:
                    break // all OK
                default:
                    XCTFail("Wrong error")
                }
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLogin() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLogin")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)
        
        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .finished:
                    break
                default:
                    XCTFail("Should be finished")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWith2FACode() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockOnePasswordWith2FAUserLogin()

        let expect = expectation(description: "testLoginWith2FACode")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .ask2FA:
                    service.provide2FACode(TestUser.defaultUser.twoFactorCode) { result in
                        switch result {
                        case let .success(status):
                            switch status {
                            case .finished:
                                break
                            default:
                                XCTFail("Should be finished")
                            }
                        case .failure:
                            XCTFail("2FA code should be correct")
                        }
                        expect.fulfill()
                    }
                default:
                    XCTFail("Should ask for 2FA code")
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Sign in should succeed")
                expect.fulfill()
            }

        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithWrong2FACode() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockOnePasswordWith2FAUserLoginWrong2FA()

        let expect = expectation(description: "testLoginWithWrong2FACode")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .ask2FA:
                    service.provide2FACode("999999") { result in
                        switch result {
                        case .success:
                            XCTFail("2FA code should be incorrect")
                            expect.fulfill()
                        case .failure:
                            expect.fulfill()
                        }
                    }
                default:
                    XCTFail("Should ask for 2FA code")
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Sign in should succeed")
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLogoutInvalidaCredentials() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockLogoutError()

        let expect = expectation(description: "testLogoutInvalidaCredentials")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        let credential = AuthCredential(Credential(UID: "UIC", accessToken: "AccessToken", refreshToken: "RefreshToken", expiration: Date(), scope: []))
        service.logout(credential: credential) { result in
            switch result {
            case .success:
                XCTFail("Logout with invalid credentials should not succeed")
            case .failure:
                break
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithUsernameOnlyAccount() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockUsernameOnlyUser()

        let expect = expectation(description: "testLoginWithUsernameOnlyAccount")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .username)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case .success(.finished):
                break
            case .failure:
                XCTFail("Username only account should work when only username required")
            default:
                XCTFail("Invalid state")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithExternalUser() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUser")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .external)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case .success(.finished):
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            default:
                XCTFail("Invalid state")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithExternalUserWhenUsernameRequired() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUser")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .username)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case .success(.finished):
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            default:
                XCTFail("Invalid state")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithExternalUserWhenInternalRequired() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUserWhenInternalRequired")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case .success(.chooseInternalUsernameAndCreateInternalAddress):
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            default:
                XCTFail("Invalid state")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLogout() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLogout")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case let .finished(data):
                    self.mockLogout()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        service.logout(credential: data.credential) { result in
                            switch result {
                            case .success:
                                break
                            case .failure:
                                XCTFail("Logout with valid credentials should succeed")
                            }
                            expect.fulfill()
                        }
                    }
                default:
                    XCTFail("Should be finished")
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Sign in should succeed")
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameAvailable() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockUsernameAvailable()

        let expect = expectation(description: "testUsernameAvailable")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.checkAvailability(username: ObfuscatedConstants.nonExistingUsername) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameNotAvailable() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockUsernameNotAvailable()

        let expect = expectation(description: "testUsernameNotAvailable")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.checkAvailability(username: ObfuscatedConstants.existingUsername) { result in
            switch result {
            case .success:
                XCTFail("Checking unavailable username should never succeed")
            case .failure:
                break
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWith2FAAndSecondPassword() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockTwoPasswordWith2FAUserLogin()

        let expect = expectation(description: "testLoginWith2FAAndSecondPassword")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .ask2FA:
                    service.provide2FACode(TestUser.defaultUser.twoFactorCode) { result in
                        switch result {
                        case let .success(status):
                            switch status {
                            case .askSecondPassword:
                                service.finishLoginFlow(mailboxPassword: TestUser.defaultUser.password) { result in
                                    switch result {
                                    case let .success(status):
                                        switch status {
                                        case.finished:
                                            break
                                        default:
                                            XCTFail("Second password should be the last step")
                                        }
                                    case .failure:
                                        XCTFail("Second password should be accepted")
                                    }
                                    expect.fulfill()
                                }
                            default:
                                XCTFail("Should ask for second password")
                                expect.fulfill()
                            }
                        case .failure:
                            XCTFail("2FA code should be correct")
                            expect.fulfill()
                        }
                    }
                default:
                    XCTFail("Should ask for 2FA code")
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Sign in should succeed")
                expect.fulfill()
            }

        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithWrongSecondPassword() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockTwoPasswordWith2FAUserLoginFail()

        let expect = expectation(description: "testLoginWith2FAAndWrongSecondPassword")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .askSecondPassword:
                    service.finishLoginFlow(mailboxPassword: "abcdefgh") { result in
                        switch result {
                        case .success:
                            XCTFail("Incorrect second password should not be accepted")
                        case let .failure(error):
                            switch error {
                            case .invalidSecondPassword:
                                break
                            default:
                                XCTFail("Incorrect error")
                            }
                        }
                        expect.fulfill()
                    }
                default:
                    XCTFail("Should ask for second password")
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Sign in should succeed")
                expect.fulfill()
            }

        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithUserWithOnlyCustomDomainAddress() {

        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)

        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")

        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.setUpForTestLoginWithUserWithOnlyCustomDomainAddress()

        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: authenticator)

        service.login(username: TestUser.defaultUser.username, password: TestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .finished:
                    break
                case .chooseInternalUsernameAndCreateInternalAddress:
                    XCTFail("Should not create address")
                case .ask2FA, .askSecondPassword:
                    XCTFail("Should not ask for anything password")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.1) { (error) in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededDoesNotCreateKeysForUserWithKeys() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: AuthenticatorWithKeyGenerationMock())
        service.createAccountKeysIfNeeded(user: TestUser.user, addresses: nil, mailboxPassword: nil) { result in
            switch result {
            case .success(let user): XCTAssertEqual(TestUser.user, user)
            case .failure: XCTFail("should not fail")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailsIfNoMailboxPasswordIsAvailable() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: AuthenticatorWithKeyGenerationMock())
        service.createAccountKeysIfNeeded(user: TestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: nil) { result in
            switch result {
            case .success: XCTFail("should not succeed")
            case .failure(let error):
                guard case .invalidState = error else {
                    XCTFail("the error should be LoginError.invalidState")
                    return
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededDoesNotCreateKeysForUserWithoutAddresses() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.success([])) }
        authenticator.getAddressesStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: TestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success(let user): XCTAssertEqual(TestUser.externalUserWithoutKeys, user)
            case .failure: XCTFail("should not fail")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailsIfUnableToFetchAddresses() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.failure(.notImplementedYet("test message"))) }
        authenticator.getAddressesStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: TestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success: XCTFail("should not succeed")
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("should pass error returned from authentictor")
                    return
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailesIfSettingUpAccountKeysFails() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let testExternalAddressWithoutKeys = try! JSONDecoder().decode(Address.self, from: """
            {
                "ID": "test address ID",
                "domainID": "test domain ID",
                "email": "test email",
                "send": 1,
                "receive": 1,
                "status": 1,
                "type": 5,
                "order": 1,
                "displayName": "test display name",
                "signature": "",
                "hasKeys": 0,
                "keys": []
            }
        """.data(using: .utf8)!)
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.success([testExternalAddressWithoutKeys])) }
        authenticator.getAddressesStub.ensureWasCalled = true
        authenticator.setupAccountKeysStub.bodyIs { _, _, _, _, completion in completion(.failure(.notImplementedYet("test message"))) }
        authenticator.setupAccountKeysStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: TestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success: XCTFail("should not succeed")
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("should pass error returned from authentictor")
                    return
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailesIfRefreshingUserAfterKeysCreationFails() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let testExternalAddressWithoutKeys = try! JSONDecoder().decode(Address.self, from: """
            {
                "ID": "test address ID",
                "domainID": "test domain ID",
                "email": "test email",
                "send": 1,
                "receive": 1,
                "status": 1,
                "type": 5,
                "order": 1,
                "displayName": "test display name",
                "signature": "",
                "hasKeys": 0,
                "keys": []
            }
        """.data(using: .utf8)!)
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.success([testExternalAddressWithoutKeys])) }
        authenticator.getAddressesStub.ensureWasCalled = true
        authenticator.setupAccountKeysStub.bodyIs { _, _, _, _, completion in completion(.success) }
        authenticator.setupAccountKeysStub.ensureWasCalled = true
        authenticator.getUserInfoStub.bodyIs { _, _, completion in completion(.failure(.notImplementedYet("test message"))) }
        authenticator.getUserInfoStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: TestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success: XCTFail("should not succeed")
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("should pass error returned from authentictor")
                    return
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededSuccessReturnsRefreshedUser() {
        let (api, authDelegate, _) = createApiService(doh: LiveDoHMail.default)
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let testExternalAddressWithoutKeys = try! JSONDecoder().decode(Address.self, from: """
            {
                "ID": "test address ID",
                "domainID": "test domain ID",
                "email": "test email",
                "send": 1,
                "receive": 1,
                "status": 1,
                "type": 5,
                "order": 1,
                "displayName": "test display name",
                "signature": "",
                "hasKeys": 0,
                "keys": []
            }
        """.data(using: .utf8)!)
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.success([testExternalAddressWithoutKeys])) }
        authenticator.getAddressesStub.ensureWasCalled = true
        authenticator.setupAccountKeysStub.bodyIs { _, _, _, _, completion in completion(.success) }
        authenticator.setupAccountKeysStub.ensureWasCalled = true
        let testUser = TestUser.user
        authenticator.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }
        authenticator.getUserInfoStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: TestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success(let user):
                XCTAssertNotEqual(TestUser.externalUserWithoutKeys, user)
                XCTAssertEqual(testUser, user)
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("should pass error returned from authentictor")
                    return
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testAvailableDomainSignupSuccess() {
        let doh = LiveDoHMail.default
        let (api, authDelegate, serviceDelegate) = createApiService(doh: doh)
        _ = serviceDelegate
        mockAvailableDomainsSignupOK()

        let expect = expectation(description: "testAvailableDomainsMockOK")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.updateAvailableDomain(type: .signup) { result in
            XCTAssertEqual(result, "signup.xyz") // taken from the mocked api responses
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAvailableDomainLoginSuccess() {
        let doh = LiveDoHMail.default
        let (api, authDelegate, serviceDelegate) = createApiService(doh: doh)
        _ = serviceDelegate
        mockAvailableDomainsLoginOK()

        let expect = expectation(description: "testAvailableDomainsMockOK")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.updateAvailableDomain(type: .login) { result in
            XCTAssertEqual(result, "login.xyz") // // taken from the mocked api responses
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    /// TODO:: fix me, the test function name deon't match with the logic
    func testAvailableDomainSignupError401() {
        let (api, authDelegate, serviceDelegate) = createApiService(doh: LiveDoHMail.default)
        _ = serviceDelegate
        mockAvailableDomainsSignupError()

        let expect = expectation(description: "testAvailableDomainsMockError")
        let service = LoginService(api: api, authManager: authDelegate, minimumAccountType: .internal)

        service.updateAvailableDomain(type: .signup) { result in
            XCTAssertNil(result)
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        let encoder = JSONEncoder()
        let lhsData = try! encoder.encode(lhs)
        let rhsData = try! encoder.encode(rhs)
        return lhsData == rhsData
    }
}

extension AuthenticatorWithKeyGenerationMock {

    func setUpForTestLoginWithUserWithOnlyCustomDomainAddress() {
        let decoder = JSONDecoder()

        let keysBeforeSetup = "[]"

        let userKeysAfterSetup = """
            [{
                "ID": "test key ID",
                "version": 3,
                "primary": 1,
                "privateKey": "test private key",
                "fingerprint": "test fingerprint"
            }]
        """

        let addressKeysAfterSetup = """
            [{
                "ID": "test key ID",
                "version": 3,
                "flags": 0,
                "privateKey": "test private key",
                "token": "test token",
                "signature": "test signature",
                "primary": 1
            }]
        """

        var hasKeysFixture = "0"
        var userKeysFixture = keysBeforeSetup
        var addressKeysFixture = keysBeforeSetup
        authenticateStub.bodyIs { _, _, _, completion in
            let credential = Credential(UID: "testUID", accessToken: "testAccessToken", refreshToken: "testRefreshToken",
                                        expiration: .distantFuture, scope: ["testScope"])
            completion(.success(.newCredential(credential, .one)))
        }
        getUserInfoStub.bodyIs { _, _, completion in
            let userData = """
                {
                    "ID": "test id",
                    "name": "test name",
                    "usedSpace": 0,
                    "currency": "test currency",
                    "credit": 0,
                    "maxSpace": 0,
                    "maxUpload": 0,
                    "subscribed": 1,
                    "services": 1,
                    "role": 1,
                    "private": 0,
                    "delinquent": 1,
                    "email": "test email",
                    "displayName": "test name",
                    "keys": \(userKeysFixture)
                }
            """.data(using: .utf8)!
            let user = try! decoder.decode(User.self, from: userData)
            completion(.success(user))
        }
        getAddressesStub.bodyIs { _, _, completion in
            let addressData = """
                {
                    "ID": "test address ID",
                    "domainID": "test domain ID",
                    "email": "test email",
                    "send": 1,
                    "receive": 1,
                    "status": 1,
                    "type": 3,
                    "order": 1,
                    "displayName": "test display name",
                    "signature": "",
                    "hasKeys": \(hasKeysFixture),
                    "keys": \(addressKeysFixture)
                }
            """.data(using: .utf8)!
            let address = try! decoder.decode(Address.self, from: addressData)
            completion(.success([address]))
        }
        getKeySaltsStub.bodyIs { _, _, completion in
            let addressKeySaltData = """
                {
                    "ID": "test key ID",
                    "keySalt": "+JGTUecCSgnCfKCSaPOZKQ=="
                }
            """.data(using: .utf8)!
            let addressKeySalt = try! decoder.decode(KeySalt.self, from: addressKeySaltData)
            completion(.success([addressKeySalt]))
        }
        getRandomSRPModulusStub.bodyIs { _, args in
            let modulusData = """
                {
                    "modulus": String,
                    "modulusID": String,
                    "code": Int
                }
            """.data(using: .utf8)!
            let modulus = try! decoder.decode(AuthService.ModulusEndpointResponse.self, from: modulusData)
            args(.success(modulus))
        }
        createAddressKeyStub.bodyIs { _, _, _, _, _, _, completion in
            let addressKeyData = """
                {
                    "ID": "test key ID",
                    "version": 3,
                    "flags": 0,
                    "privateKey": "test private key",
                    "token": "test token",
                    "signature": "test signature",
                    "primary": 1
                }
            """.data(using: .utf8)!
            let addressKey = try! decoder.decode(Key.self, from: addressKeyData)
            completion(.success(addressKey))
        }
        setupAccountKeysStub.bodyIs { _, _, _, _, completion in
            userKeysFixture = userKeysAfterSetup
            addressKeysFixture = addressKeysAfterSetup
            hasKeysFixture = "1"
            completion(.success)
        }
    }

    func setUpForTestCreateAccountKeysIfNeeded() {

    }
}
