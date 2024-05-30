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

#if os(iOS)

import XCTest

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsAuthenticationKeyGeneration
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#endif
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreObfuscatedConstants
@testable import ProtonCoreFeatureFlags
@testable import ProtonCoreServices
@testable import ProtonCoreLogin
@testable import ProtonCoreObservability

class LoginServiceTests: XCTestCase {
    var authInfoRequestData: [String: Any]?
    var server: SrpServer?
    var sut: LoginService!
    var api: APIServiceMock!
    var observabilityServiceMock: ObservabilityServiceMock!
    var featureFlagsRepositoryMock: FeatureFlagsRepositoryMock!

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    private func setupSUT() {
        featureFlagsRepositoryMock = FeatureFlagsRepositoryMock()
        api = APIServiceMock()
        api.authDelegateStub.fixture = AuthDelegateMock()
        let dohInterface = DohInterfaceMock()
        dohInterface.getCurrentlyUsedHostUrlStub.bodyIs { _ in
            "http://proton.black/api"
        }
        dohInterface.getAccountHostStub.bodyIs { _ in
            "http://account.proton.black"
        }
        api.sessionUIDStub.fixture = "sessionUID"
        api.dohInterfaceStub.fixture = dohInterface
        sut = LoginService(api: api,
                           clientApp: .vpn,
                           minimumAccountType: .external,
                           featureFlagsRepository: featureFlagsRepositoryMock)
    }

    // MARK: - handleValidCredentials

    func test_handleValidCredentials_fetchesFeatureFlagsOnSuccess() {
        // Given
        setupSUT()
        let userId = "test_user_id"
        let expectation = XCTestExpectation(description: "success expected")
        let credential = Credential(UID: "",
                                    accessToken: "",
                                    refreshToken: "",
                                    userName: "",
                                    userID: userId,
                                    scopes: .empty)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion(nil, .success(AuthService.UserResponse(user: .dummy.updated(ID: userId))))
            } else if path.contains("/feature/v2/frontend") {
                completion(nil, .success(FeatureFlagResponse(code: 0, toggles: [])))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // When
        sut.handleValidCredentials(credential: credential, passwordMode: .one, mailboxPassword: nil, isSSO: true) { (result: Result<LoginStatus, LoginError>) in
            switch result {
            case .success(.finished):
                break
            default:
                XCTFail()
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(self.featureFlagsRepositoryMock.setApiServiceWasCalled)
        XCTAssertTrue(self.featureFlagsRepositoryMock.setUserIdWasCalled)
        XCTAssertTrue(self.featureFlagsRepositoryMock.fetchFlagsWasCalled)
        XCTAssertEqual(self.featureFlagsRepositoryMock.userId, userId)
    }

    func test_handleValidCredentials_isSSO_succeed() {
        // Given
        setupSUT()
        let expectation = XCTestExpectation(description: "success expected")
        let credential = Credential(UID: "", accessToken: "", refreshToken: "", userName: "", userID: "", scopes: .empty)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion(nil, .success(AuthService.UserResponse(user: .dummy)))
            } else if path.contains("/feature/v2/frontend") {
                completion(nil, .success(FeatureFlagResponse(code: 0, toggles: [])))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // When
        sut.handleValidCredentials(credential: credential, passwordMode: .one, mailboxPassword: nil, isSSO: true) { (result: Result<LoginStatus, LoginError>) in
            switch result {
            case .success(.finished):
                break
            default:
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func test_handleValidCredentialsWithoutPasswordMode_callsFailureInvalidState() {
        setupSUT()
        let credential = Credential(UID: "", accessToken: "", refreshToken: "", userName: "", userID: "", scopes: .empty)
        let expectation = XCTestExpectation(description: "failure expected")
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion(nil, .success(AuthService.UserResponse(user: .dummy)))
            } else if path.contains("/feature/v2/frontend") {
                completion(nil, .success(FeatureFlagResponse(code: 0, toggles: [])))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        sut.handleValidCredentials(credential: credential, passwordMode: .one, mailboxPassword: nil) { (result: Result<LoginStatus, LoginError>) in
            switch result {
            case .failure(.invalidState):
                break
            default:
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - processResponseToken

    func test_processResponseToken_callsAuthenticate() {
        // Given
        setupSUT()

        // When
        sut.processResponseToken(idpEmail: "test@protonhub.org", responseToken: .init(token: "token", uid: "sessionUID")) { _ in }

        // Then
        XCTAssertTrue(api.requestDecodableStub.wasCalledExactlyOnce)
    }

    // MARK: - getSSORequest

    func test_getSSORequest_authCredentialsNotFound() async {
        // Given
        setupSUT()
        api.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.notFound)
        }

        // When
        let ssoResult = await sut.getSSORequest(challenge: .init(ssoChallengeToken: "ssoChallengeToken"))

        // Then
        XCTAssertNil(ssoResult.request)
        XCTAssertEqual(ssoResult.error, "Empty token")
    }

    func test_getSSORequest_authCredentialsWrongConfigurationNoDelegate() async {
        // Given
        setupSUT()
        api.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.wrongConfigurationNoDelegate)
        }

        // When
        let ssoResult = await sut.getSSORequest(challenge: .init(ssoChallengeToken: "ssoChallengeToken"))

        // Then
        XCTAssertNil(ssoResult.request)
        XCTAssertEqual(ssoResult.error, "AuthDelegate is required")
    }

    func test_getSSORequest_authCredentialsFound() async {
        // Given
        setupSUT()
        api.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: .init(Credential(UID: "", accessToken: "accessToken", refreshToken: "", userName: "", userID: "", scopes: .empty))))
        }

        // When
        let ssoResult = await sut.getSSORequest(challenge: .init(ssoChallengeToken: "ssoChallengeToken"))

        // Then
        XCTAssertNil(ssoResult.error)
        XCTAssertEqual(ssoResult.request?.url, URL(string: "http://proton.black/api/auth/sso/ssoChallengeToken"))
        XCTAssertEqual(ssoResult.request?.headers.dictionary, ["x-pm-uid": "sessionUID", "Authorization": "accessToken"])
    }

    // MARK: - Login

    func testLoginWithWrongPassword_failsWithInvalidCredentialsError() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockInvalidCredentialsLogin()

        let expect = expectation(description: "testLoginWithWrongPasswordFails")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: "username", password: "ddssd", challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Sign in with wrong password should fail")
            case let .failure(error):
                switch error {
                case .invalidCredentials:
                    expect.fulfill()
                default:
                    XCTFail("Unexpected error")
                }
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithNonExistentUser_failsWithInvalidCredentialsError() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockNonExistentUserLogin()

        let expect = expectation(description: "testLoginWithNonExistentUserFails")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: "nonExistentUserName", password: "MadeUpPassword", challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Sign in with wrong password should fail")
            case let .failure(error):
                switch error {
                case .invalidCredentials:
                    expect.fulfill()
                default:
                    XCTFail("Unexpected error")
                }
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLogin_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLoginIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case let .success(status):
                switch status {
                case .finished:
                    expect.fulfill()
                default:
                    XCTFail("Should be finished")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSettingSSOCallbackScheme() {
        setupSUT()
        XCTAssertNil(sut.ssoCallbackScheme)

        let testScheme = "testScheme"

        sut = LoginService(api: api,
                           clientApp: .vpn,
                           minimumAccountType: .external,
                           ssoCallbackScheme: testScheme)

        XCTAssertEqual(sut.ssoCallbackScheme, testScheme)
    }

    func testLoginWithSSO_isSuccessful() {
        withFeatureFlags([.externalSSO]) {
            let authDelegate = AuthHelper()
            let apiService = APIServiceMock()
            apiService.authDelegateStub.fixture = authDelegate
            apiService.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }

            mockSSOUserLogin()
            apiService.requestDecodableStub.bodyIs { count, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(SSOChallengeResponse(ssoChallengeToken: "b7953c6a26d97a8f7a673afb79e6e9ce")))
            }
            let expect = expectation(description: "testLoginWithSSOisSuccessful")
            let service = LoginService(api: apiService, clientApp: .other(named: "core"), minimumAccountType: .internal)

            service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, intent: .sso, challenge: nil) { result in
                switch result {
                case let .success(status):
                    switch status {
                    case .ssoChallenge:
                        expect.fulfill()
                    default:
                        XCTFail("Should receive SSO challenge")
                    }
                case .failure:
                    XCTFail("Sign in should succeed")
                }
            }

            waitForExpectations(timeout: 30) { (error) in
                XCTAssertNil(error, String(describing: error))
            }
        }
    }

    func testLoginWithSSO_fails() {
        withFeatureFlags([.externalSSO]) {
            let authDelegate = AuthHelper()
            let apiService = APIServiceMock()
            apiService.authDelegateStub.fixture = authDelegate
            apiService.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }

            mockSSOUserLogin()
            apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(.badResponse()))
            }
            let expect = expectation(description: "testLoginWithSSOisSuccessful")
            let service = LoginService(api: apiService, clientApp: .other(named: "core"), minimumAccountType: .internal)

            service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, intent: .sso, challenge: nil) { result in
                switch result {
                case .success:
                    XCTFail("Failure expected")
                case .failure:
                    expect.fulfill()
                }
            }

            waitForExpectations(timeout: 30) { (error) in
                XCTAssertNil(error, String(describing: error))
            }
        }
    }

    func testLoginWithSSO_fails_tracksFailure() {
        withFeatureFlags([.externalSSO]) {
            observabilityServiceMock = ObservabilityServiceMock()
            ObservabilityEnv.current.observabilityService = observabilityServiceMock
            let authDelegate = AuthHelper()
            let apiService = APIServiceMock()
            apiService.authDelegateStub.fixture = authDelegate
            apiService.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
            let expectedEvent: ObservabilityEvent = .ssoObtainChallengeToken(status: .ssoDomainNotFound)

            mockSSOUserLogin()
            apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(ResponseError(httpCode: 422, responseCode: 8101, userFacingMessage: "Email domain not found, please sign in with a password", underlyingError: nil) as NSError))
            }
            let expect = expectation(description: "testLoginWithSSOisSuccessful")
            let service = LoginService(api: apiService, clientApp: .other(named: "core"), minimumAccountType: .internal)

            service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, intent: .sso, challenge: nil) { _ in
                XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
                expect.fulfill()
            }

            waitForExpectations(timeout: 30) { (error) in
                XCTAssertNil(error, String(describing: error))
            }
        }
    }

    func testLoginWithTOTPCode_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockOnePasswordWith2FAUserLogin()

        let expect = expectation(description: "testLoginWithTOTPCodeIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case let .success(status):
                switch status {
                case .askTOTP:
                    service.provide2FACode(LoginTestUser.defaultUser.twoFactorCode) { result in
                        switch result {
                        case let .success(status):
                            switch status {
                            case .finished:
                                expect.fulfill()
                            default:
                                XCTFail("Should be finished")
                            }
                        case .failure:
                            XCTFail("2FA code should be correct")
                        }
                    }
                default:
                    XCTFail("Should ask for 2FA code")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithWrongTOTPCode_isFailure() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockOnePasswordWith2FAUserLoginWrong2FA()

        let expect = expectation(description: "testLoginWithWrongTOTPCodeFails")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case let .success(status):
                switch status {
                case .askTOTP:
                    service.provide2FACode("999999") { result in
                        switch result {
                        case .success:
                            XCTFail("2FA code should be incorrect")
                        case .failure:
                            expect.fulfill()
                        }
                    }
                default:
                    XCTFail("Should ask for 2FA code")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithFIDO2_isSuccessful() {
        withFeatureFlags([.fidoKeys]) {
            let (api, authDelegate) = self.apiService
            _ = authDelegate
            mockOnePasswordWithFIDO2UserLogin()

            let expect = expectation(description: "testLoginWithFIDO2IsSuccessful")
            let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

            service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
                switch result {
                case let .success(status):
                    switch status {
                    case let .askAny2FA(authenticationOptions):
                        service.provideFido2Signature(LoginTestUser.defaultUser.fido2SignatureWithAuthenticationOptions(authenticationOptions)) { result in
                            switch result {
                            case let .success(status):
                                switch status {
                                case .finished:
                                    expect.fulfill()
                                default:
                                    XCTFail("Should be finished")
                                }
                            case .failure:
                                XCTFail("FIDO2 signature should be correct")
                            }
                        }
                    default:
                        XCTFail("Should ask for 2FA code")
                    }
                case .failure:
                    XCTFail("Sign in should succeed")
                }
            }

            waitForExpectations(timeout: 30) { (error) in
                XCTAssertNil(error, String(describing: error))
            }
        }
    }

    func testLogoutInvalidaCredentials_isFailure() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockLogoutError()

        let expect = expectation(description: "testLogoutInvalidaCredentialsFails")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        let credential = AuthCredential(Credential(UID: "UIC", accessToken: "AccessToken", refreshToken: "RefreshToken", userName: "UserName", userID: "UserID", scopes: []))
        service.logout(credential: credential) { result in
            switch result {
            case .success:
                XCTFail("Logout with invalid credentials should not succeed")
            case .failure:
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithUsernameOnlyAccount_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockUsernameOnlyUser()

        let expect = expectation(description: "testLoginWithUsernameOnlyAccountIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .username)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case .success(.finished):
                expect.fulfill()
            case .failure:
                XCTFail("Username only account should work when only username required")
            default:
                XCTFail("Invalid state")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithExternalUser_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUserIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .external)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case .success(.finished):
                expect.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            default:
                XCTFail("Invalid state")
            }
        }

        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithExternalUserWhenUsernameRequired_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUserIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .username)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case .success(.finished):
                expect.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            default:
                XCTFail("Invalid state")
            }
        }

        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_login_withExternalUserWhenInternalRequired_capCFFEnabled_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockExternalUser()

        let expect = expectation(description: "testLoginWithExternalUserWhenInternalRequiredIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case .success(.chooseInternalUsernameAndCreateInternalAddress):
                expect.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            default:
                XCTFail("Invalid state")
            }
        }

        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginUpdatesCredentialsEvenIfTheCredentialsAreAlreadyThere() throws {
        let (api, authDelegate) = apiService
        _ = authDelegate

        // setup api and auth delegate as if unauth session is already fetched
        let alreadyExistingCredentials = Credential(UID: "session from \(#function)", accessToken: "token from \(#function)", refreshToken: "refresh from \(#function)", userName: .empty, userID: .empty, scopes: ["\(#function)"])
        api.setSessionUID(uid: alreadyExistingCredentials.UID)
        authDelegate.onUpdate(credential: alreadyExistingCredentials, sessionUID: alreadyExistingCredentials.UID)
        XCTAssertNotNil(authDelegate.credential(sessionUID: alreadyExistingCredentials.UID))

        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLogin")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
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

        XCTAssertNil(authDelegate.credential(sessionUID: alreadyExistingCredentials.UID))
        let fetchedCredentials = try XCTUnwrap(authDelegate.credential(sessionUID: "test session ID"))
        XCTAssertEqual(fetchedCredentials.UID, "test session ID")
        XCTAssertEqual(fetchedCredentials.accessToken, "AccessToken")
        XCTAssertEqual(fetchedCredentials.refreshToken, "RefreshToken")
        XCTAssertEqual(fetchedCredentials.userID, "UserID")
        XCTAssertEqual(fetchedCredentials.scopes, ["full", "self", "organization", "payments", "keys", "parent", "user", "loggedin", "paid", "nondelinquent", "mail"])
    }

    func testLogout_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockOnePasswordUserLogin()

        let expect = expectation(description: "testLogoutIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case let .success(status):
                switch status {
                case let .finished(userData):
                    self.mockLogout()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        service.logout(credential: userData.credential) { result in
                            switch result {
                            case .success:
                                expect.fulfill()
                            case .failure:
                                XCTFail("Logout with valid credentials should succeed")
                            }
                        }
                    }
                default:
                    XCTFail("Should be finished")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameAccountAvailable_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockUsernameAccountAvailable()

        let expect = expectation(description: "testUsernameAvailableIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .username)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForUsernameAccount(username: "nonExistingUsername") { result in
            switch result {
            case .success:
                expect.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameAccountNotAvailable_isFailure() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockUsernameAccountNotAvailable()

        let expect = expectation(description: "testUsernameNotAvailableIsFailure")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .username)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForUsernameAccount(username: "existingUsername") { result in
            switch result {
            case .success:
                XCTFail("Checking unavailable username should never succeed")
            case .failure:
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testInternalUsernameAvailable_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockInternalAccountAvailable(encodedEmail: "nonExistingUsername%40proton.test")

        let expect = expectation(description: "testUsernameAvailableIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForInternalAccount(username: "nonExistingUsername") { result in
            switch result {
            case .success:
                expect.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testInternalUsernameNotAvailable_isFailure() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockInternalAccountNotAvailable(encodedEmail: "existingUsername%40proton.test")

        let expect = expectation(description: "testUsernameNotAvailableIsFailure")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.checkAvailabilityForInternalAccount(username: "existingUsername") { result in
            switch result {
            case .success:
                XCTFail("Checking unavailable username should never succeed")
            case .failure:
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testExternalEmailAvailable_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockEmailAvailable()

        let expect = expectation(description: "testExternalEmailAvailableIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .external)

        service.checkAvailabilityForExternalAccount(email: "nonExistingEmail") { result in
            switch result {
            case .success:
                expect.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testExternalEmailNotAvailable_isFailure() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockEmailNotAvailable()

        let expect = expectation(description: "testExternalEmailNotAvailableIsFailure")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .external)

        service.checkAvailabilityForExternalAccount(email: "existingEmail") { result in
            switch result {
            case .success:
                XCTFail("Checking unavailable username should never succeed")
            case .failure:
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testExternalEmailIsProtonEmail() {
        let api = APIServiceMock()
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }

        let expect = expectation(description: "testExternalEmailNotAvailableIsFailure")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .external)
        service.updatedSignUpDomains = ["test.proton"]

        service.checkAvailabilityForExternalAccount(email: "username@test.proton") { result in
            switch result {
            case .failure(.protonDomainUsedForExternalAccount(username: "username", domain: "test.proton", _)):
                expect.fulfill()
            case .success: XCTFail()
            case .failure: XCTFail()
            }
        }

        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: two password mode tests

    private func performLoginWithTwoPasswordUser(minimumAccountType: AccountType,
                                                 expectationFulfillment: @escaping (XCTestExpectation, LoginService, LoginStatus) -> Void) {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockTwoPasswordWith2FAUserLogin()

        let expect = expectation(description: "testLoginWith2FAAndSecondPasswordIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: minimumAccountType)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case let .success(status):
                switch status {
                case .askTOTP:
                    service.provide2FACode(LoginTestUser.defaultUser.twoFactorCode) { result in
                        switch result {
                        case let .success(status):
                            expectationFulfillment(expect, service, status)
                        case .failure:
                            XCTFail("2FA code should be correct")
                        }
                    }
                default:
                    XCTFail("Should ask for 2FA code")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithTOTPAndSecondPassword_isSuccessfulForInternal() {
        performLoginWithTwoPasswordUser(minimumAccountType: .internal) { expect, service, status in
            switch status {
            case .askSecondPassword:
                service.finishLoginFlow(mailboxPassword: LoginTestUser.defaultUser.password, passwordMode: .two) { result in
                    switch result {
                    case let .success(status):
                        switch status {
                        case.finished:
                            expect.fulfill()
                        default:
                            XCTFail("Second password should be the last step")
                        }
                    case .failure:
                        XCTFail("Second password should be accepted")
                    }
                }
            default:
                XCTFail("Should ask for second password")
            }
        }
    }

    func testLoginWithTOTPAndSecondPassword_isSuccessfulForExternal() {
        performLoginWithTwoPasswordUser(minimumAccountType: .external) { expect, service, status in
            switch status {
            case .askSecondPassword:
                service.finishLoginFlow(mailboxPassword: LoginTestUser.defaultUser.password, passwordMode: .two) { result in
                    switch result {
                    case let .success(status):
                        switch status {
                        case.finished:
                            expect.fulfill()
                        default:
                            XCTFail("Second password should be the last step")
                        }
                    case .failure:
                        XCTFail("Second password should be accepted")
                    }
                }
            default:
                XCTFail("Should ask for second password")
            }
        }
    }

    func testLoginWithTOTPAndSecondPassword_DoesNotAskForSecondPasswordForUsername() {
        performLoginWithTwoPasswordUser(minimumAccountType: .username) { expect, service, status in
            switch status {
            case .finished:
                expect.fulfill()
            default:
                XCTFail("Should finish successfully")
            }
        }
    }

    func testLoginWithWrongSecondPassword_failsWithInvalidSecondPasswordError() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockTwoPasswordWith2FAUserLoginFail()

        let expect = expectation(description: "testLoginWithTOTPAndWrongSecondPasswordFails")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case let .success(status):
                switch status {
                case .askSecondPassword:
                    service.finishLoginFlow(mailboxPassword: "abcdefgh", passwordMode: .two) { result in
                        switch result {
                        case .success:
                            XCTFail("Incorrect second password should not be accepted")
                        case let .failure(error):
                            switch error {
                            case .invalidSecondPassword:
                                expect.fulfill()
                            default:
                                XCTFail("Incorrect error")
                            }
                        }
                    }
                default:
                    XCTFail("Should ask for second password")
                }
            case .failure:
                XCTFail("Sign in should succeed")
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testLoginWithPrivateUserWithOnlyCustomDomainAddress_failsWithNeedsFirstTimePasswordChangeError() {

        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressFails")

        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.setUpForTestLoginWithUserWithOnlyCustomDomainAddress(private: 1)

        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: authenticator)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Sign in should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, .needsFirstTimePasswordChange)
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 0.1) { (error) in XCTAssertNil(error, String(describing: error)) }
    }

    func testLoginWithNonPrivateUserWithOnlyCustomDomainAddress_failsWithMissingSubUserConfiguration() {

        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressFails")

        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.setUpForTestLoginWithUserWithOnlyCustomDomainAddress(private: 0)

        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: authenticator)

        service.login(username: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Sign in should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, .missingSubUserConfiguration)
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 0.1) { (error) in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededDoesNotCreateKeysForUserWithKeys_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressIsSuccessful")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: AuthenticatorWithKeyGenerationMock())
        service.createAccountKeysIfNeeded(user: LoginTestUser.user, addresses: nil, mailboxPassword: nil) { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(LoginTestUser.user, user)
                expect.fulfill()
            case .failure:
                XCTFail("should not fail")
            }
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailsIfNoMailboxPasswordIsAvailable_failsWithInvalidStateError() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressFails")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: AuthenticatorWithKeyGenerationMock())
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: nil) { result in
            switch result {
            case .success:
                XCTFail("should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, .invalidState)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededDoesNotCreateKeysForUserWithoutAddresses_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressIsSuccessful")
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.success([])) }
        authenticator.getAddressesStub.ensureWasCalled = true
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(LoginTestUser.externalUserWithoutKeys, user)
                expect.fulfill()
            case .failure:
                XCTFail("Should succeed")
            }
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testCreateAccountKeysIfNeededFailsIfUnableToFetchAddresses_failsWithGenericError() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressFails")
        let authenticator = AuthenticatorWithKeyGenerationMock()
        authenticator.getAddressesStub.bodyIs { _, _, completion in completion(.failure(.notImplementedYet("test message"))) }
        authenticator.getAddressesStub.ensureWasCalled = true
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success:
                XCTFail("should not succeed")
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("should pass error returned from authentictor")
                    return
                }
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1) { error in XCTAssertNil(error, String(describing: error)) }
    }

    /// for the new flow. external address without account key but with a external address. will trigger account setup
    func testCreateAccountKeysIfNeededSuccessReturnsExtUser_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        let expect = expectation(description: "testLoginWithUserWithOnlyCustomDomainAddressIsSuccessful")
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
        authenticator.setupAccountKeysStub.bodyIs { _, _, _, _, completion in
            completion(.success)
        }
        authenticator.getUserInfoStub.bodyIs {_, _, completion in
            completion(.success(LoginTestUser.externalUserWithoutKeys))
        }
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal, authenticator: authenticator)
        service.createAccountKeysIfNeeded(user: LoginTestUser.externalUserWithoutKeys, addresses: nil, mailboxPassword: "test password") { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(LoginTestUser.externalUserWithoutKeys, user)
                expect.fulfill()
            case .failure:
                XCTFail("Should be successful")
            }
        }
        waitForExpectations(timeout: 10) { error in XCTAssertNil(error, String(describing: error)) }
    }

    func testAvailableDomainSignupSuccess() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockAvailableDomainsSignupOK()

        let expect = expectation(description: "testAvailableDomainsMockOK")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

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
        _ = authDelegate
        mockAvailableDomainsLoginOK()

        let expect = expectation(description: "testAvailableDomainsMockOK")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

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
        _ = authDelegate
        mockAvailableDomainsSignupError()

        let expect = expectation(description: "testAvailableDomainsMockError")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.updateAllAvailableDomains(type: .signup) { result in
            XCTAssertNil(result)
            expect.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testDefaultDomainIsUsedIfNoAvailableDomains() async {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/domains/available") {
                completion(nil, .success(AvailableDomainResponse.from(["Code": 1000, "Domains": []])))
            } else {
                XCTFail()
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        XCTAssertTrue(result!.isEmpty)
        XCTAssertTrue(service.allSignUpDomains.isEmpty)
        XCTAssertEqual(service.currentlyChosenSignUpDomain, service.defaultSignUpDomain)
    }

    func testOnlyAvailableDomainIsUsedIfNoChosen() async {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/domains/available") {
                completion(nil, .success(AvailableDomainResponse.from(["Code": 1000, "Domains": ["proton.first"]])))
            } else {
                XCTFail()
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        XCTAssertEqual(result, ["proton.first"])
        XCTAssertEqual(service.allSignUpDomains, ["proton.first"])
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.first")
    }

    func testFirstAvailableDomainIsUsedIfNoChosen() async {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/domains/available") {
                completion(nil, .success(AvailableDomainResponse.from(["Code": 1000, "Domains": ["proton.first", "proton.second", "proton.third"]])))
            } else {
                XCTFail()
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.updateAllAvailableDomains(type: .signup) { continuation.resume(returning: $0) }
        }
        XCTAssertEqual(result, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.allSignUpDomains, ["proton.first", "proton.second", "proton.third"])
        XCTAssertEqual(service.currentlyChosenSignUpDomain, "proton.first")
    }

    func testChosenDomainIsUsed() async {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/domains/available") {
                completion(nil, .success(AvailableDomainResponse.from(["Code": 1000, "Domains": ["proton.first", "proton.second", "proton.third"]])))
            } else {
                XCTFail()
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

    func testTryingToSetUnavailableDomainDoesntChangeAnything() async {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/domains/available") {
                completion(nil, .success(AvailableDomainResponse.from(["Code": 1000, "Domains": ["proton.first", "proton.second", "proton.third"]])))
            } else {
                XCTFail()
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

    func testLoginWithAuthExtAccountsNotSupported_error5099() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockAuthExtAccountsNotSupportedLoginError5099()

        let expect = expectation(description: "testLoginWithUnsupportedExternalAcount")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: "extAccount", password: "ddssd", challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Sign in with external account should fail")
            case let .failure(error):
                switch error {
                case .externalAccountsNotSupported(let message, let title, let originalError):
                    XCTAssertEqual(originalError.responseCode, 5099)
                    XCTAssertEqual(message, "This app does not support external accounts")
                    XCTAssertEqual(title, "Proton address required")
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

    func testLoginWithAuthExtAccountsNotSupported_error5098() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockAuthExtAccountsNotSupportedLoginError5098()

        let expect = expectation(description: "testLoginWithUnsupportedExternalAcount")
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        service.login(username: "extAccount", password: "ddssd", challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Sign in with external account should fail")
            case let .failure(error):
                switch error {
                case .externalAccountsNotSupported(let message, let title, let originalError):
                    XCTAssertEqual(originalError.responseCode, 5098)
                    XCTAssertEqual(message, "This app does not support external accounts")
                    XCTAssertEqual(title, "Update required")
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

    func testExternalAccountNotSupported_Error5099IsReturned() async throws {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let userFacingMessage = "Get a Proton Mail address linked to this account in your Proton web settings."
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let verifier = Data(base64Encoded: ObfuscatedConstants.srpAuthVerifier)!
                self.server = CryptoGo.SrpNewServerFromSigned(ObfuscatedConstants.modulus, verifier, 2048, nil)!
                let challenge = try! self.server!.generateChallenge() // this is the serverEphemeral
                completion(nil, .success(AuthInfoResponse(
                    modulus: ObfuscatedConstants.modulus,
                    serverEphemeral: challenge.base64EncodedString(),
                    version: 4,
                    salt: ObfuscatedConstants.srpAuthSalt,
                    srpSession: "test srp session"
                )))
            } else if path.contains("/auth/v4") {
                completion(nil, .failure(ResponseError(httpCode: 422, responseCode: 5099, userFacingMessage: userFacingMessage, underlyingError: nil) as NSError))
            } else {
                XCTFail()
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.login(username: "test user", password: "test password", challenge: nil, completion: continuation.resume)
        }
        let error = try XCTUnwrap(result.error)
        guard case .externalAccountsNotSupported(message: userFacingMessage, title: "Proton address required", let originalError) = error else {
            XCTFail(); return
        }
        XCTAssertEqual(originalError.httpCode, 422)
        XCTAssertEqual(originalError.responseCode, 5099)
        XCTAssertEqual(originalError.localizedDescription, userFacingMessage)
    }

    func testExternalAccountNotSupported_Error5098IsReturned() async throws {
        let authDelegate = AuthHelper()
        let api = APIServiceMock()
        api.authDelegateStub.fixture = authDelegate
        api.fetchAuthCredentialsStub.bodyIs { $1(.wrongConfigurationNoDelegate) }
        let userFacingMessage = "Get a Proton Mail address linked to this account in your Proton web settings."
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        api.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                let verifier = Data(base64Encoded: ObfuscatedConstants.srpAuthVerifier)!
                self.server = CryptoGo.SrpNewServerFromSigned(ObfuscatedConstants.modulus, verifier, 2048, nil)!
                let challenge = try! self.server!.generateChallenge() // this is the serverEphemeral
                completion(nil, .success(AuthInfoResponse(
                    modulus: ObfuscatedConstants.modulus,
                    serverEphemeral: challenge.base64EncodedString(),
                    version: 4,
                    salt: ObfuscatedConstants.srpAuthSalt,
                    srpSession: "test srp session"
                )))
            } else if path.contains("/auth/v4") {
                completion(nil, .failure(ResponseError(httpCode: 422, responseCode: 5098, userFacingMessage: userFacingMessage, underlyingError: nil) as NSError))
            } else {
                completion(nil, .failure(.badResponse()))
                XCTFail()
            }
        }
        let result = await withCheckedContinuation { continuation in
            service.login(username: "test user", password: "test password", challenge: nil, completion: {
                continuation.resume(with: .success($0))
            })
        }
        let error = try XCTUnwrap(result.error)
        guard case .externalAccountsNotSupported(message: userFacingMessage, title: "Update required", let originalError) = error else {
            XCTFail(); return
        }
        XCTAssertEqual(originalError.httpCode, 422)
        XCTAssertEqual(originalError.responseCode, 5098)
        XCTAssertEqual(originalError.localizedDescription, userFacingMessage)
    }

    func testAvailableUsernameForExternalAccountEmail_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockInternalAccountAvailable(encodedEmail: "nonExistingUsername%40proton.test")

        let expect = expectation(description: #function)
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.availableUsernameForExternalAccountEmail(email: "nonExistingUsername") { result in
            switch result {
            case .some(let defaultUserName):
                XCTAssertEqual(defaultUserName, "nonExistingUsername")
            case .none:
                XCTFail("no username found")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameForExternalAccountEmailNotAvailableEmail_isSuccessful() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockInternalAccountNotAvailable(encodedEmail: "existingUsername%40proton.test")

        let expect = expectation(description: #function)
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.availableUsernameForExternalAccountEmail(email: "existingUsername") { result in
            switch result {
            case .some:
                XCTFail("username found when not expected")
            case .none:
                break
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testUsernameForExternalAccountEmailError12087_shouldFail() {
        let (api, authDelegate) = apiService
        _ = authDelegate
        mockInternalAccountError12087()

        let expect = expectation(description: #function)
        let service = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)
        service.chosenSignUpDomain = "proton.test"

        service.availableUsernameForExternalAccountEmail(email: "existingUsername") { result in
            switch result {
            case .some:
                XCTFail("username not expected here")
            case .none:
                break
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
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
        authenticateStub.bodyIs { _, _, _, _, _, _, completion  in
            let credential = Credential(UID: "testUID", accessToken: "testAccessToken", refreshToken: "testRefreshToken", userName: "testUserName", userID: "testUserID", scopes: ["testScope"])
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
        createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, completion in
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

#endif
