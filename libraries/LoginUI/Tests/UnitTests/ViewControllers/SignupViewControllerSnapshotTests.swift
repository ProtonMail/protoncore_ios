//
//  SignupViewControllerSnapshotTests.swift
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

import XCTest
import ProtonCore_Challenge
import ProtonCore_FeatureSwitch
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_LoginUI

@available(iOS 13, *)
class SignupViewControllerSnapshotTests: SnapshotTestCase {
    var sut: SignupViewController!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    private func setupSut() {
        sut = UIStoryboard.instantiate(
            storyboardName: "PMSignup",
            controllerType: SignupViewController.self
        )
        sut.viewModel = SignupViewModel(
            signupService: SignupServiceMock(),
            loginService: LoginMock(),
            challenge: PMChallenge()
        )
    }
    
    func testSignUpScreen_withInternalAccountType() {
        // Given
        FeatureFactory.shared.disable(&.externalSignup)
        setupSut()
        sut.signupAccountType = .internal
        sut.minimumAccountType = .internal
        
        // Then
        checkSnapshots(controller: sut, perceptualPrecision: 0.98)
    }
    
    func testSignUpScreen_withExternalAccountType_ffDisabled() {
        // Given
        FeatureFactory.shared.disable(&.externalSignup)
        setupSut()
        sut.signupAccountType = .external
        sut.minimumAccountType = .external
        
        // Then
        checkSnapshots(controller: sut, perceptualPrecision: 0.98)
    }
    
    func testSignUpScreen_withExternalAccountType_ffEnabled() {
        // Given
        FeatureFactory.shared.enable(&.externalSignup)
        setupSut()
        sut.signupAccountType = .external
        sut.minimumAccountType = .external
        
        // Then
        checkSnapshots(controller: sut, perceptualPrecision: 0.98)
    }
}
