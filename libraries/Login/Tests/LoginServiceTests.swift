//
//  LoginServiceTests.swift
//  ProtonCore-Login-Tests - Created on 11/11/2020.
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
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

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

    func testLoginWithWrongPassword() {
        let (api, authDelegate) = apiService
        mockInvalidCredentialsLogin()

        let expect = expectation(description: "testLoginWithWrongPassword")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: "username", password: "ddssd") { result in
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

    func testLoginWithNonExistentUser() {
        let (api, authDelegate) = apiService
        mockNonExistentUserLogin()

        let expect = expectation(description: "testLoginWithNonExistentUser")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

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
        let (api, authDelegate) = apiService
        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLogin")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        
        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockOnePasswordWith2FAUserLogin()

        let expect = expectation(description: "testLoginWith2FACode")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .ask2FA:
                    service.provide2FACode(LoginTestUser.defaultUser.twoFactorCode) { result in
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
        let (api, authDelegate) = apiService
        mockOnePasswordWith2FAUserLoginWrong2FA()

        let expect = expectation(description: "testLoginWithWrong2FACode")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockLogoutError()

        let expect = expectation(description: "testLogoutInvalidaCredentials")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        let credential = AuthCredential(Credential(UID: "UIC", accessToken: "AccessToken", refreshToken: "RefreshToken", expiration: Date(), userName: "UserName", userID: "UserID", scope: []))
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
        let (api, authDelegate) = apiService
        mockUsernameOnlyUser()

        let expect = expectation(description: "testLoginWithUsernameOnlyAccount")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .username)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUser")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .external)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUser")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .username)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUserWhenInternalRequired")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLogout")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case let .finished(data):
                    self.mockLogout()
                    let authCredential: AuthCredential
                    switch data {
                    case .credential(let credential):
                        authCredential = AuthCredential(credential)
                    case .userData(let userData):
                        authCredential = userData.credential
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        service.logout(credential: authCredential) { result in
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
    
    func testUsernameAccountAvailable() {
        let (api, authDelegate) = apiService
        mockUsernameAccountAvailable()

        let expect = expectation(description: "testUsernameAvailable")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .username)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForUsernameAccount(username: "nonExistingUsername") { result in
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

    func testUsernameAccountNotAvailable() {
        let (api, authDelegate) = apiService
        mockUsernameAccountNotAvailable()

        let expect = expectation(description: "testUsernameNotAvailable")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .username)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForUsernameAccount(username: "existingUsername") { result in
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

    func testInternalUsernameAvailable() {
        let (api, authDelegate) = apiService
        mockInternalAccountAvailable(encodedEmail: "nonExistingUsername%40proton.test")

        let expect = expectation(description: "testUsernameAvailable")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForInternalAccount(username: "nonExistingUsername") { result in
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

    func testInternalUsernameNotAvailable() {
        let (api, authDelegate) = apiService
        mockInternalAccountNotAvailable(encodedEmail: "existingUsername%40proton.test")

        let expect = expectation(description: "testUsernameNotAvailable")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForInternalAccount(username: "existingUsername") { result in
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
    
    func testExternalEmailAvailable() {
        let (api, authDelegate) = apiService
        mockEmailAvailable()

        let expect = expectation(description: "testExternalEmailAvailable")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .external)

        service.checkAvailabilityForExternalAccount(email: "nonExistingEmail") { result in
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
    
    func testExternalEmailNotAvailable() {
        let (api, authDelegate) = apiService
        mockEmailNotAvailable()

        let expect = expectation(description: "testExternalEmailNotAvailable")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .external)

        service.checkAvailabilityForExternalAccount(email: "existingEmail") { result in
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
        let (api, authDelegate) = apiService
        mockTwoPasswordWith2FAUserLogin()

        let expect = expectation(description: "testLoginWith2FAAndSecondPassword")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
            switch result {
            case let .success(status):
                switch status {
                case .ask2FA:
                    service.provide2FACode(LoginTestUser.defaultUser.twoFactorCode) { result in
                        switch result {
                        case let .success(status):
                            switch status {
                            case .askSecondPassword:
                                service.finishLoginFlow(mailboxPassword: LoginTestUser.defaultUser.password) { result in
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
        let (api, authDelegate) = apiService
        mockTwoPasswordWith2FAUserLoginFail()

        let expect = expectation(description: "testLoginWith2FAAndWrongSecondPassword")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
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

    func testLoginWithPrivateUserWithOnlyCustomDomainAddress() {

        let (api, authDelegate) = apiService

        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")

        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.setUpForTestLoginWithUserWithOnlyCustomDomainAddress(private: 1)

        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: authenticator)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
            switch result {
            case .success:
                XCTFail("Sign in should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, LoginError.needsFirstTimePasswordChange)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.1) { (error) in XCTAssertNil(error, String(describing: error)) }
    }
    
    func testLoginWithNonPrivateUserWithOnlyCustomDomainAddress() {

        let (api, authDelegate) = apiService

        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")

        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.setUpForTestLoginWithUserWithOnlyCustomDomainAddress(private: 0)

        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: authenticator)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password) { result in
            switch result {
            case .success:
                XCTFail("Sign in should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, LoginError.missingSubUserConfiguration)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.1) { (error) in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededDoesNotCreateKeysForUserWithKeys() {
        let (api, authDelegate) = apiService
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: AuthenticatorWithKeyGenerationMock())
        service.createAccountKeysIfNeeded(user: LoginTestUser.user, addresses: nil, mailboxPassword: nil) { result in
            switch result {
            case .success(let user): XCTAssertEqual(LoginTestUser.user, user)
            case .failure: XCTFail("should not fail")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailsIfNoMailboxPasswordIsAvailable() {
        let (api, authDelegate) = apiService
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: AuthenticatorWithKeyGenerationMock())
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: nil) { result in
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
        let (api, authDelegate) = apiService
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.success([])) }
        authenticator.getAddressesStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success(let user): XCTAssertEqual(LoginTestUser.externalUserWithoutKeys, user)
            case .failure: XCTFail("should not fail")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailsIfUnableToFetchAddresses() {
        let (api, authDelegate) = apiService
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddress")
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.failure(.notImplementedYet("test message"))) }
        authenticator.getAddressesStub.ensureWasCalled = true
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
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

    func testCreateAccountKeysIfNeededSuccessReturnsExtUser() {
        let (api, authDelegate) = apiService
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
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(LoginTestUser.externalUserWithoutKeys, user)
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
        let (api, authDelegate) = apiService
        mockAvailableDomainsSignupOK()

        let expect = expectation(description: "testAvailableDomainsMockOK")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.updateAllAvailableDomains(type: .signup) { result in
            XCTAssertEqual(result, ["signup.xyz"]) // taken from the mocked api responses
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAvailableDomainLoginSuccess() {
        let (api, authDelegate) = apiService
        mockAvailableDomainsLoginOK()

        let expect = expectation(description: "testAvailableDomainsMockOK")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.updateAllAvailableDomains(type: .login) { result in
            XCTAssertEqual(result, ["login.xyz"]) // // taken from the mocked api responses
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    /// TODO:: fix me, the test function name deon't match with the logic
    func testAvailableDomainSignupError401() {
        let (api, authDelegate) = apiService
        mockAvailableDomainsSignupError()

        let expect = expectation(description: "testAvailableDomainsMockError")
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)

        service.updateAllAvailableDomains(type: .signup) { result in
            XCTAssertNil(result)
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    @available(iOS 13, *)
    func testDefaultDomainIsUsedIfNoAvailableDomains() async {
        let authDelegate = AuthManager()
        let api = APIServiceMock()
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        api.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/domains/available") {
                completion?(nil, ["Code": 1000, "Domains": []], nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        XCTAssertTrue(result!.isEmpty)
        XCTAssertTrue(service.allSignUpDomains.isEmpty)
        XCTAssertEqual(service.currentlyChosenSignUpDomain, service.defaultSignUpDomain)
    }
    
    @available(iOS 13, *)
    func testOnlyAvailableDomainIsUsedIfNoChosen() async {
        let authDelegate = AuthManager()
        let api = APIServiceMock()
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        api.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/domains/available") {
                completion?(nil, ["Code": 1000, "Domains": ["proton.first"]], nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        XCTAssertEqual(result, ["proton.first"])
        XCTAssertEqual(service.allSignUpDomains, ["proton.first"])
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.first")
    }
    
    @available(iOS 13, *)
    func testFirstAvailableDomainIsUsedIfNoChosen() async {
        let authDelegate = AuthManager()
        let api = APIServiceMock()
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        api.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/domains/available") {
                completion?(nil, ["Code": 1000, "Domains": ["proton.first", "proton.second", "proton.third"]], nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        XCTAssertEqual(result, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.allSignUpDomains, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.first")
    }
    
    @available(iOS 13, *)
    func testChosenDomainIsUsed() async {
        let authDelegate = AuthManager()
        let api = APIServiceMock()
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        api.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/domains/available") {
                completion?(nil, ["Code": 1000, "Domains": ["proton.first", "proton.second", "proton.third"]], nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        service.currentlyChosenSignUpDomain = "proton.second"
        XCTAssertEqual(result, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.allSignUpDomains, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.second")
    }
    
    @available(iOS 13, *)
    func testTryingToSetUnavailableDomainDoesntChangeAnything() async {
        let authDelegate = AuthManager()
        let api = APIServiceMock()
        let service = LoginService(api: api, authManager: authDelegate, sessionId: "test session id", minimumAccountType: .internal)
        api.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/domains/available") {
                completion?(nil, ["Code": 1000, "Domains": ["proton.first", "proton.second", "proton.third"]], nil)
            } else {
                XCTFail()
                completion?(nil, nil, nil)
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        service.currentlyChosenSignUpDomain = "proton.second"
        XCTAssertEqual(result, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.allSignUpDomains, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.second")
        
        service.currentlyChosenSignUpDomain = service.defaultSignUpDomain
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.second")
    }
}

extension User {
    public static func == (lhs: User, rhs: User) -> Bool {
        let encoder = JSONEncoder()
        let lhsData = try! encoder.encode(lhs)
        let rhsData = try! encoder.encode(rhs)
        return lhsData == rhsData
    }
}

extension AuthenticatorWithKeyGenerationMock {

    func setUpForTestLoginWithUserWithOnlyCustomDomainAddress(`private`: Int) {
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
        authenticateStub.bodyIs { _, _, _, _, completion in
            let credential = Credential(UID: "testUID", accessToken: "testAccessToken", refreshToken: "testRefreshToken",
                                        expiration: .distantFuture, userName: "testUserName", userID: "testUserID", scope: ["testScope"])
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
                    "private": \(`private`),
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
