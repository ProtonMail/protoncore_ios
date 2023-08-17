//
//  LoginUISnapshotTests.swift
//  ProtonCore-LoginUI-V5-Unit-TestsUsingCrypto - Created on 13/10/22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#if os(iOS)

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreChallenge
import ProtonCoreUIFoundations
import ProtonCoreEnvironment
import ProtonCoreDataModel
import ProtonCoreLogin
import ProtonCoreFeatureSwitch
@testable import ProtonCoreLoginUI
import SnapshotTesting

@available(iOS 13, *)
class LoginUISnapshotTests: SnapshotTestCase {

    let defaultPrecision: Float = 0.98
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSignInScreen_withNav() {
        withFeatureSwitches([]) {
            let controller = loginViewController(for: .username, clientApp: .vpn)
            checkSnapshots(controller: controller, device: .iPhone12, perceptualPrecision: defaultPrecision)
        }
    }

    func testSignInScreenWithSSO_withNav_iPhone12() {
        withFeatureSwitches([.ssoSignIn]) {
            let controller = loginViewController(for: .username, clientApp: .vpn)
            checkSnapshots(controller: controller, device: .iPhone12, perceptualPrecision: defaultPrecision)
        }
    }
    
    func testSignInScreenWithSSO_withNav_iPadMiniLandscape() {
        withFeatureSwitches([.ssoSignIn]) {
            let controller = loginViewController(for: .username, clientApp: .vpn)
            checkSnapshots(controller: controller, device: .iPadMini(.landscape), perceptualPrecision: defaultPrecision)
        }
    }
    
    private func createHelpViewController(inAppTheme: InAppTheme = .default) -> UIViewController {
        let controller = UIStoryboard.instantiate(storyboardName: "PMLogin",
                                                  controllerType: HelpViewController.self,
                                                  inAppTheme: { inAppTheme })
        var getHelpDecorator: ([[HelpItem]]) -> [[HelpItem]] {
            return { _ in
                [
                    [
                        HelpItem.staticText(text: "Test 1"),
                        HelpItem.custom(icon: IconProvider.eyeSlash,
                                        title: "Test 1 description",
                                        behaviour: { _ in }),
                        HelpItem.otherIssues
                    ],
                    [
                        HelpItem.support,
                        HelpItem.staticText(text: "Test 2"),
                        HelpItem.custom(icon: IconProvider.mobile,
                                        title: "Test 2 description",
                                        behaviour: { _ in })
                    ]
                ]
            }
        }
        controller.viewModel = HelpViewModel(helpDecorator: getHelpDecorator)
        return controller
    }
    
    func testHelpViewControllerScreen() {
        let controller = createHelpViewController()
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }
    
    func testHelpViewControllerScreenEnforcingLight() {
        let controller = createHelpViewController(inAppTheme: .light)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }
    
    func testHelpViewControllerScreenEnforcingDark() {
        let controller = createHelpViewController(inAppTheme: .dark)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }

    func signupViewController(for accountType: AccountType, inAppTheme: InAppTheme? = nil) -> SignupViewController {
        let signupParameters = SignupParameters(separateDomainsButton: true, passwordRestrictions: .default, summaryScreenVariant: .noSummaryScreen)
        let clientApp = ClientApp.other(named: "test")

        let apiService = APIServiceMock()
        apiService.dohInterfaceStub.fixture = Environment.black.doh
        apiService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: clientApp, challenge: PMChallenge())
        
        let customization: LoginCustomizationOptions
        if let inAppTheme {
            customization = .init(inAppTheme: { inAppTheme })
        } else {
            customization = .empty
        }

        let coordinator = SignupCoordinator(
            container: Container(appName: "test", clientApp: clientApp, apiService: apiService, minimumAccountType: accountType),
            minimumAccountType: accountType,
            isCloseButton: false,
            paymentsAvailability: .notAvailable,
            signupAvailability: .available(parameters: signupParameters),
            customization: customization
        )

        let signupViewController = coordinator.createSignupViewController(signupParameters: signupParameters)
        _ = signupViewController.view
        return signupViewController
    }

    func testSignUpScreenForUsernameAccountRequirementWithExternalSignupEnabled() {
        let controller = signupViewController(for: .username)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }

    func testSignUpScreenForUsernameAccountRequirementAfterOtherButtonTapWithExternalSignupEnabled() {
        let controller = signupViewController(for: .external)
        if !controller.otherAccountButton.isHidden {
            controller.onOtherAccountButtonTap(controller.otherAccountButton)
        }

        checkSnapshots(controller: controller, wait: 1.0, perceptualPrecision: defaultPrecision)
    }

    func testSignUpScreenForExternalAccountRequirementWithExternalSignupEnabled() {
        let controller = signupViewController(for: .external)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }

    func testSignUpScreenForExternalAccountRequirementAfterOtherButtonTapWithExternalSignupEnabled() {
        let controller = signupViewController(for: .external)
        if !controller.otherAccountButton.isHidden {
            controller.onOtherAccountButtonTap(controller.otherAccountButton)
        }

        checkSnapshots(controller: controller, wait: 1.0, perceptualPrecision: defaultPrecision)
    }

    func testSignUpScreenForInternalAccountRequirementWithExternalSignupEnabled() {
        let controller = signupViewController(for: .internal)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }
    
    func loginViewController(for accountType: AccountType,
                             clientApp: ClientApp = .other(named: "test"),
                             inAppTheme: InAppTheme? = nil) -> UIViewController {
        let apiService = APIServiceMock()
        apiService.authDelegateStub.fixture = nil
        apiService.dohInterfaceStub.fixture = Environment.black.doh
        apiService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: clientApp, challenge: PMChallenge())
        
        let customization: LoginCustomizationOptions
        if let inAppTheme {
            customization = .init(inAppTheme: { inAppTheme })
        } else {
            customization = .empty
        }

        let coordinator = LoginCoordinator(
            container: Container(appName: "test", clientApp: clientApp, apiService: apiService, minimumAccountType: .internal),
            isCloseButtonAvailable: true,
            isSignupAvailable: true,
            customization: customization
        )

        return coordinator.start(.unmanaged)
    }
    
    func testLoginScreenEnforcingLight() {
        let controller = loginViewController(for: .internal, inAppTheme: .light)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }
    
    func testLoginScreenEnforcingDark() {
        let controller = loginViewController(for: .internal, inAppTheme: .dark)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }
    
    func testLoginScreenMatchingSystemTheme() {
        let controller = loginViewController(for: .internal, inAppTheme: .matchSystem)
        checkSnapshots(controller: controller, perceptualPrecision: defaultPrecision)
    }
}

#endif
