//
//  SignupCoordinatorTests.swift
//  ProtonCore-LoginUI-Unit-Tests-Crypto-Go1.19.2 - Created on 30.11.22.
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
//  along with ProtonCore. If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

@testable import ProtonCoreLoginUI
import ProtonCoreLogin
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreChallenge
import ProtonCoreUIFoundations
import XCTest

final class SignupCoordinatorTests: XCTestCase {
    var signupAccountTypeManager: SignupAccountTypeManagerMock!
    let controller = LoginNavigationViewController(rootViewController: UIViewController())
    
    override func setUp() {
        super.setUp()
        signupAccountTypeManager = SignupAccountTypeManagerMock()
    }
    
    private func setupCoordinator(minimumAccountType: AccountType, featureFlagEnabled: Bool) -> (SignupCoordinator, Container) {
        let signupParameters = signupParameters()
        let signupAvailability = SignupAvailability.available(parameters: signupParameters)
        let testService = PMAPIService.createAPIServiceWithoutSession(
            environment: .black, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init())
        )
        let container = Container(appName: #file,
                                  clientApp: .other(named: "core"),
                                  apiService: testService,
                                  minimumAccountType: minimumAccountType)
        let coordinator = SignupCoordinator(container: container,
                                            minimumAccountType: minimumAccountType,
                                            isCloseButton: false,
                                            paymentsAvailability: .notAvailable,
                                            signupAvailability: signupAvailability,
                                            customization: .empty,
                                            signupAccountTypeManager: signupAccountTypeManager)
        return (coordinator, container)
    }
    
    private func signupParameters() -> SignupParameters {
        SignupParameters(separateDomainsButton: true, passwordRestrictions: .default, summaryScreenVariant: .noSummaryScreen)
    }
    
    func test_start_withSignupAvailableAndSignupModeInternalAndFFDisabled_setsSignupAccountTypeToInternal() {
        // Given
        let (out, _) = setupCoordinator(minimumAccountType: .internal, featureFlagEnabled: false)

        // When
        out.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
    }
    
    func test_start_withSignupAvailableAndSignupModeExternalAndFFDisabled_setsSignupAccountTypeToInternal() {
        // Given
        let (out, _) = setupCoordinator(minimumAccountType: .internal, featureFlagEnabled: false)

        // When
        out.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
    }
    
    func test_start_withSignupAvailableAndSignupModeInternalAndFFEnabled_setsSignupAccountTypeToInternal() {
        // Given
        let (out, _) = setupCoordinator(minimumAccountType: .internal, featureFlagEnabled: true)

        // When
        out.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
    }
    
    func test_start_withSignupAvailableAndSignupModeExternalAndFFEnabled_setsSignupAccountTypeToExternal() {
        // Given
        let (out, _) = setupCoordinator(minimumAccountType: .internal, featureFlagEnabled: true)

        // When
        out.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
    }

    func testSignupCoordinatorSetsLoginAccountTypeToExternalOnValidatedExternalEmail() {
        // Given
        let (out, coordinator) = setupCoordinator(minimumAccountType: .username, featureFlagEnabled: true)

        XCTAssertEqual(coordinator.login.minimumAccountType, .username)

        // When
        out.validatedEmail(email: "tests@example.com", signupAccountType: .external)

        // Then
        XCTAssertEqual(coordinator.login.minimumAccountType, .external)
    }

    func testSignupCoordinatorSetsLoginAccountTypeToExternalOnValidatedUsername() {
        // Given
        let (out, coordinator) = setupCoordinator(minimumAccountType: .username, featureFlagEnabled: true)

        XCTAssertEqual(coordinator.login.minimumAccountType, .username)

        // When
        out.validatedName(name: "test name", signupAccountType: .internal)

        // Then
        XCTAssertEqual(coordinator.login.minimumAccountType, .internal)
    }

    func testSignupCoordinatorRestoresOriginalLoginAccountTypeOnSignupClose() {
        // Given
        let (out, coordinator) = setupCoordinator(minimumAccountType: .username, featureFlagEnabled: true)
        out.validatedName(name: "test name", signupAccountType: .internal)
        XCTAssertEqual(coordinator.login.minimumAccountType, .internal)

        // When
        out.signupCloseButtonPressed()

        // Then
        XCTAssertEqual(coordinator.login.minimumAccountType, .username)
    }

    func testSignupCoordinatorRestoresOriginalLoginAccountTypeOnSwitchToSignin() {
        // Given
        let (out, coordinator) = setupCoordinator(minimumAccountType: .username, featureFlagEnabled: true)
        out.validatedName(name: "test name", signupAccountType: .internal)
        XCTAssertEqual(coordinator.login.minimumAccountType, .internal)

        // When
        out.signinButtonPressed()

        // Then
        XCTAssertEqual(coordinator.login.minimumAccountType, .username)
    }

    func testSignupCoordinatorRestoresOriginalLoginAccountTypeOnEmailBeingAlreadyUsedViaHV() {
        // Given
        let (out, coordinator) = setupCoordinator(minimumAccountType: .username, featureFlagEnabled: true)
        out.validatedName(name: "test name", signupAccountType: .internal)
        XCTAssertEqual(coordinator.login.minimumAccountType, .internal)

        // When
        out.hvEmailAlreadyExists(email: "test email")

        // Then
        XCTAssertEqual(coordinator.login.minimumAccountType, .username)
    }
}

class SignupAccountTypeManagerMock: SignupAccountTypeManagerProtocol {
    var accountType: SignupAccountType = .internal
    var setSignupAccountTypeCallCount = 0
    
    func setSignupAccountType(type: SignupAccountType) {
        accountType = type
        setSignupAccountTypeCallCount += 1
    }
}

#endif
