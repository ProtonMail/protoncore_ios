//
//  LoginViewModelTests.swift
//  ProtonCore-Login-Tests - Created on 24.05.23.
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
import TrustKit

@testable import ProtonCoreAuthentication
@testable import ProtonCoreChallenge
import ProtonCoreLogin
@testable import ProtonCoreLoginUI
@testable import ProtonCoreNetworking
@testable import ProtonCoreObservability
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreUIFoundations

final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var apiService: APIServiceMock!
    var dohMock: DohInterfaceMock!
    var login: LoginMock!
    var observabilityServiceMock: ObservabilityServiceMock!

    override func setUp() {
        super.setUp()
        setupMock()
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))
    }

    private func setupMock() {
        observabilityServiceMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observabilityServiceMock
        apiService = APIServiceMock()
        dohMock = DohInterfaceMock()
        login = LoginMock()
    }

    func test_labels_ssoUIEnabled() {
        // Given
        sut.isSsoUIEnabled = true

        // Then
        XCTAssertEqual(sut.loginTextFieldTitle, LUITranslation.email_field_title.l10n)
        XCTAssertEqual(sut.titleLabel, LUITranslation.sign_in_with_sso_title.l10n)
        XCTAssertEqual(sut.signUpButtonTitle, LUITranslation.create_account_button.l10n)
        XCTAssertEqual(sut.signInWithSSOButtonTitle, LUITranslation.sign_in_button_with_password.l10n)
    }

    func test_labels_ssoUIDisabled() {
        // Given
        sut.isSsoUIEnabled = false

        // Then
        XCTAssertEqual(sut.loginTextFieldTitle, LUITranslation.username_title.l10n)
        XCTAssertEqual(sut.titleLabel, LUITranslation._core_sign_in_screen_title.l10n)
        XCTAssertEqual(sut.signUpButtonTitle, LUITranslation.create_account_button.l10n)
        XCTAssertEqual(sut.signInWithSSOButtonTitle, LUITranslation.sign_in_with_sso_button.l10n)
    }

    // MARK: - getSSOTokenFromURL

    func test_getSSOTokenFromURL_getsTokenFromValidURL() {
        // Given
        let token = "92834urjhfog34"
        let uid = "98h2biw4uaekjf"
        let url = URL(string: "http://account.proton.me/sso/login#token=\(token)&uid=\(uid)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertEqual(tokenFromHost, .init(token: token, uid: uid))
    }

    func test_getSSOTokenFromURL_getsNilFromURLWithoutToken() {
        // Given
        let uid = "98h2biw4uaekjf"
        let url = URL(string: "https://account.proton.me/sso/login#uid=\(uid)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertNil(tokenFromHost)
    }

    func test_getSSOTokenFromURL_getsNilFromURLWithoutUid() {
        // Given
        let token = "98h2biw4uaekjf"
        let url = URL(string: "https://account.proton.me/sso/login#token=\(token)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertNil(tokenFromHost)
    }

    func test_getSSOTokenFromURL_getsNilFromBadURL() {
        // Given
        let url = URL(string: "bad url")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertNil(tokenFromHost)
    }

    // MARK: - GetSSORequest
    private var token: String { "0r8wj34iufe" }
    private var challenge: SSOChallengeResponse { .init(ssoChallengeToken: token) }

    func test_getSSORequest_withCredentials_succeed() async {
        // Given
        let credentials = AuthCredential(
            sessionID: "sessionID",
            accessToken: "accessToken",
            refreshToken: "refreshToken",
            userName: "userName",
            userID: "userID",
            privateKey: nil,
            passwordKeySalt: nil
        )
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: credentials))
        }
        apiService.dohInterfaceStub.fixture = dohMock
        apiService.sessionUIDStub.fixture = "testSessionUID"
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in
            "http://account.proton.test/api"
        }
        var expectedRequest = URLRequest(url: URL(string: "http://account.proton.test/api/auth/sso/\(token)")!)
        expectedRequest.setValue("accessToken", forHTTPHeaderField: "Authorization")
        expectedRequest.setValue("testSessionUID", forHTTPHeaderField: "x-pm-uid")

        // When
        let ssoRequestResult = await sut.getSSORequest(challenge: challenge)

        // Then
        XCTAssertNil(ssoRequestResult.error)
        XCTAssertEqual(ssoRequestResult.request?.url, expectedRequest.url)
        XCTAssertEqual(ssoRequestResult.request?.allHTTPHeaderFields, expectedRequest.allHTTPHeaderFields)
    }

    func test_getSSORequest_withoutCredentials_fails() async {
        // Given
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.notFound)
        }
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        // When
        let ssoRequestResult = await sut.getSSORequest(challenge: challenge)

        // Then
        XCTAssertNil(ssoRequestResult.request)
        XCTAssertEqual(ssoRequestResult.error, "Empty token")
    }

    func test_getSSORequest_withWrongConfiguration_fails() async {
        // Given
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.wrongConfigurationNoDelegate)
        }
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        // When
        let ssoRequestResult = await sut.getSSORequest(challenge: challenge)

        // Then
        XCTAssertNil(ssoRequestResult.request)
        XCTAssertEqual(ssoRequestResult.error, "AuthDelegate is required")
    }

    // MARK: - processResponseToken

    func test_processResponseToken_tracksSuccess() {
        // Given
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .successful)
        login.processResponseTokenStub.bodyIs { _, _, _, completion in
            completion(.success(.finished(.init(credential: .dummy, user: .dummy, salts: [], passphrases: [:], addresses: [], scopes: []))))
        }

        // When
        sut.processResponseToken(idpEmail: "", responseToken: .init(token: "", uid: ""))

        // Then
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    func test_processResponseToken_tracksFailure() {
        // Given
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)
        login.processResponseTokenStub.bodyIs { _, _, _, completion in
            completion(.failure(.invalidState))
        }

        // When
        sut.processResponseToken(idpEmail: "", responseToken: .init(token: "", uid: ""))

        // Then
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
}

#endif
