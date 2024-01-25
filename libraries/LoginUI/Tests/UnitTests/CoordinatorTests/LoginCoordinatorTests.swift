//
//  LoginCoordinatorTests.swift
//  ProtonCore-Login-Tests - Created on 14.10.22.
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
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreServices
@testable import ProtonCoreChallenge
@testable import ProtonCoreNetworking
@testable import ProtonCoreLoginUI
@testable import ProtonCoreUIFoundations
import TrustKit

final class LoginCoordinatorTests: XCTestCase {

    private func setUpStack() -> (AuthDelegateMock, LoginNavigationViewController, UIViewController, LoginCoordinator) {
        let testService = APIServiceMock()
        let authDelegateMock = AuthDelegateMock()
        testService.authDelegateStub.fixture = authDelegateMock
        let dohMock = DohInterfaceMock()
        testService.dohInterfaceStub.fixture = dohMock
        testService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: .init())
        testService.sessionUIDStub.fixture = "test session"
        testService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.wrongConfigurationNoDelegate)
        }

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in
            AuthCredential(sessionID: "test session", accessToken: "test token", refreshToken: "test refresh", userName: "test username",
                           userID: "test userID", privateKey: "test private key", passwordKeySalt: "test password key")
        }
        let container = Container(appName: "tests", clientApp: .other(named: "tests"), apiService: testService, minimumAccountType: .internal)
        let out = LoginCoordinator(container: container, isCloseButtonAvailable: false, isSignupAvailable: false, customization: .empty)
        let rootVC = UIViewController()
        let navigationVC = LoginNavigationViewController(rootViewController: rootVC)
        _ = out.start(.inside(navigationVC))
        return (authDelegateMock, navigationVC, rootVC, out)
    }

    func testLoginCoordinatorClearSessionOnUserComingBackToRootViewController_SingleVC() {
        let (authDelegateMock, navigationVC, rootVC, out) = setUpStack()
        XCTAssertIdentical(navigationVC.viewControllers.first!, rootVC)
        out.userDidGoBack()
        XCTAssertTrue(authDelegateMock.onAuthenticatedSessionInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUnauthenticatedSessionInvalidatedStub.wasNotCalled)
    }

    func testLoginCoordinatorClearSessionOnUserComingBackToRootViewController_TwoVC() {
        let (authDelegateMock, navigationVC, rootVC, out) = setUpStack()
        navigationVC.setViewControllers([rootVC, UIViewController()], animated: false)
        out.userDidGoBack()
        XCTAssertTrue(authDelegateMock.onAuthenticatedSessionInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUnauthenticatedSessionInvalidatedStub.wasNotCalled)
    }

    func testLoginCoordinatorClearSessionOnUserComingBackToRootViewController_ThreeVC() {
        let (authDelegateMock, navigationVC, rootVC, out) = setUpStack()
        navigationVC.setViewControllers([rootVC, TwoFactorViewController(), UIViewController()], animated: false)
        out.userDidGoBack()
        XCTAssertTrue(authDelegateMock.onAuthenticatedSessionInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUnauthenticatedSessionInvalidatedStub.wasNotCalled)
    }

    func testLoginCoordinatorDoesNotClearSessionOnUserPoppingToPreviousViewController_ThreeVC() {
        let (authDelegateMock, navigationVC, rootVC, out) = setUpStack()
        navigationVC.setViewControllers([rootVC, UIViewController(), UIViewController()], animated: false)
        out.userDidGoBack()
        XCTAssertTrue(authDelegateMock.onAuthenticatedSessionInvalidatedStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUnauthenticatedSessionInvalidatedStub.wasNotCalled)
    }
}

#endif
