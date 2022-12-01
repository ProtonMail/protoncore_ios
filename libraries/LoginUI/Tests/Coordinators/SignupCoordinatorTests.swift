//
//  SignupCoordinatorTests.swift
//  ProtonCore-LoginUI-V5-Unit-Tests-Crypto-Go1.19.2 - Created on 30.11.22.
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

@testable import ProtonCore_LoginUI
import ProtonCore_TestingToolkit
import ProtonCore_UIFoundations
import XCTest

final class SignupCoordinatorTests: XCTestCase {
    var sut: SignupCoordinator!
    var signupAccountTypeManager: SignupAccountTypeManagerMock!
    let controller = LoginNavigationViewController(rootViewController: UIViewController())
    
    override func setUp() {
        super.setUp()
        signupAccountTypeManager = SignupAccountTypeManagerMock()
    }
    
    private func setupSut(signupAvailability: SignupAvailability,
                          featureFlagEnabled: Bool) {
        sut = .init(
            container: Container(
                appName: #file,
                clientApp: .other(named: #file),
                environment: .black,
                apiServiceDelegate: APIServiceDelegateMock(),
                forceUpgradeDelegate: ForceUpgradeDelegateMock(),
                minimumAccountType: .internal),
            isCloseButton: false,
            paymentsAvailability: .notAvailable,
            signupAvailability: signupAvailability,
            performBeforeFlow: nil,
            customErrorPresenter: nil,
            isExternalSignupFeatureEnabled: featureFlagEnabled,
            signupAccountTypeManager: signupAccountTypeManager
        )
    }
    
    private func signupParameters(signupMode: SignupMode) -> SignupParameters {
        SignupParameters(
            passwordRestrictions: .default,
            summaryScreenVariant: .noSummaryScreen,
            signupMode: signupMode)
    }
    
    func test_start_withSignupAvailableAndSignupModeInternalAndFFDisabled_setsSignupAccountTypeToInternal() {
        // Given
        let signupParameters = signupParameters(signupMode: .internal)
        let signupAvailability = SignupAvailability.available(parameters: signupParameters)
        setupSut(signupAvailability: signupAvailability, featureFlagEnabled: false)

        // When
        sut.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
    }
    
    func test_start_withSignupAvailableAndSignupModeExternalAndFFDisabled_setsSignupAccountTypeToInternal() {
        // Given
        let signupParameters = signupParameters(signupMode: .external)
        let signupAvailability = SignupAvailability.available(parameters: signupParameters)
        setupSut(signupAvailability: signupAvailability, featureFlagEnabled: false)

        // When
        sut.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 0)
    }
    
    func test_start_withSignupAvailableAndSignupModeInternalAndFFEnabled_setsSignupAccountTypeToInternal() {
        // Given
        let signupParameters = signupParameters(signupMode: .internal)
        let signupAvailability = SignupAvailability.available(parameters: signupParameters)
        setupSut(signupAvailability: signupAvailability, featureFlagEnabled: true)

        // When
        sut.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .internal)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
    }
    
    func test_start_withSignupAvailableAndSignupModeExternalAndFFEnabled_setsSignupAccountTypeToExternal() {
        // Given
        let signupParameters = signupParameters(signupMode: .external)
        let signupAvailability = SignupAvailability.available(parameters: signupParameters)
        setupSut(signupAvailability: signupAvailability, featureFlagEnabled: true)

        // When
        sut.start(kind: .inside(controller))
        
        // Then
        XCTAssertEqual(signupAccountTypeManager.accountType, .external)
        XCTAssertEqual(signupAccountTypeManager.setSignupAccountTypeCallCount, 1)
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
