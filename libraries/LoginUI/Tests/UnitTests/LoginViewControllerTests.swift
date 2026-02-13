//
//  LoginViewControllerTests.swift
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
import AuthenticationServices
@testable import ProtonCoreLoginUI
import ProtonCoreChallenge
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreObservability

final class LoginViewControllerTests: XCTestCase {
    var sut: LoginViewController!
    var loginMock: LoginMock!
    var observabilityServiceMock: ObservabilityServiceMock!

    override func setUp() {
        super.setUp()
        loginMock = .init()
        observabilityServiceMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observabilityServiceMock
        sut = LoginViewController()
        sut.viewModel = LoginViewModel(api: APIServiceMock(), login: loginMock, challenge: PMChallenge(), clientApp: .vpn)
    }

    // MARK: - ASWebAuthenticationSession SSO Tests

    func test_ssoAuthSession_canceled_tracksObservabilityEvent() {
        // Given
        let loginVC = setupVCThroughStoryboard()
        let error = NSError(domain: ASWebAuthenticationSessionError.errorDomain,
                           code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                           userInfo: nil)
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .canceled)

        // When
        loginVC.handleSSOAuthSessionCompletion(callbackURL: nil, error: error)

        // Then
        XCTAssertTrue(observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    func test_ssoAuthSession_error_tracksFailureObservabilityEvent() {
        // Given
        let loginVC = setupVCThroughStoryboard()
        let error = NSError(domain: "TestError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)

        // When
        loginVC.handleSSOAuthSessionCompletion(callbackURL: nil, error: error)

        // Then
        XCTAssertTrue(observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    func test_ssoAuthSession_noCallbackURL_tracksFailureObservabilityEvent() {
        // Given
        let loginVC = setupVCThroughStoryboard()
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)

        // When
        loginVC.handleSSOAuthSessionCompletion(callbackURL: nil, error: nil)

        // Then
        XCTAssertTrue(observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    func test_ssoAuthSession_invalidToken_tracksFailureObservabilityEvent() {
        // Given
        let loginVC = setupVCThroughStoryboard()
        // URL without token and uid in fragment - will fail parsing and return nil
        let callbackURL = URL(string: "proton://account.proton.me/sso/login")!
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)

        // When
        loginVC.handleSSOAuthSessionCompletion(callbackURL: callbackURL, error: nil)

        // Then
        XCTAssertTrue(observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    // MARK: - Helper Methods

    private func setupVCThroughStoryboard() -> LoginViewController {
        let loginVC = UIStoryboard.instantiate(storyboardName: "PMLogin", controllerType: LoginViewController.self, inAppTheme: { .default })
        loginVC.viewModel = LoginViewModel(api: APIServiceMock(), login: loginMock, challenge: PMChallenge(), clientApp: .vpn)
        loginVC.loadView()
        return loginVC
    }
}
#endif
