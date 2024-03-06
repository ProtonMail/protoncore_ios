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

#if os(iOS)

import UIKit
import XCTest
import ProtonCoreChallenge
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreLoginUI

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
            controllerType: SignupViewController.self,
            inAppTheme: { .default }
        )
        sut.viewModel = SignupViewModel(
            signupService: SignupServiceMock(),
            loginService: LoginMock(),
            challenge: PMChallenge()
        )
    }

    func testSignUpScreen_withExternalAccountType_ffEnabled() {
        // Given
        setupSut()
        sut.signupAccountType = .external
        sut.minimumAccountType = .external

        // Then
        checkSnapshots(controller: sut, perceptualPrecision: 0.98)
    }
}

#endif
