//
//  SignupScreenLoadObservabilityTests.swift
//  ProtonCore-LoginUI-Unit-Tests-Crypto-Go1.19.2 - Created on 14.02.23.
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
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsObservability
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreUIFoundations
import ProtonCoreLogin
@testable import ProtonCoreObservability
@testable import ProtonCoreLoginUI

@available(iOS 13, *)
class SignupScreenLoadObservabilityTests: SnapshotTestCase {

    func testExternalSignupScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let signupViewController = UIStoryboard.instantiate(storyboardName: "PMSignup",
                                                            controllerType: SignupViewController.self,
                                                            inAppTheme: { .default })
        signupViewController.viewModel = SignupViewModel(signupService: SignupServiceMock(), loginService: LoginMock(), challenge: .init())
        signupViewController.signupAccountType = .external
        _ = signupViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .externalAccountAvailable)))
    }

    func testInternalSignupScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let signupViewController = UIStoryboard.instantiate(storyboardName: "PMSignup",
                                                            controllerType: SignupViewController.self,
                                                            inAppTheme: { .default })
        signupViewController.viewModel = SignupViewModel(signupService: SignupServiceMock(), loginService: LoginMock(), challenge: .init())
        signupViewController.signupAccountType = .internal
        _ = signupViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .protonAccountAvailable)))
    }

    func testPasswordCreationScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let passwordViewController = UIStoryboard.instantiate(storyboardName: "PMSignup",
                                                              controllerType: PasswordViewController.self,
                                                              inAppTheme: { .default })
        passwordViewController.viewModel = PasswordViewModel()
        _ = passwordViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .passwordCreation)))
    }

    func testSetRecoveryScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let recoveryViewController = UIStoryboard.instantiate(storyboardName: "PMSignup",
                                                              controllerType: RecoveryViewController.self,
                                                              inAppTheme: { .default })
        recoveryViewController.viewModel = RecoveryViewModel(signupService: SignupServiceMock(), initialCountryCode: 42, challenge: .init())
        _ = recoveryViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .setRecoveryMethod)))
    }

    func testEmailVerificationScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let emailVerificationViewController = UIStoryboard.instantiate(storyboardName: "PMSignup",
                                                                       controllerType: EmailVerificationViewController.self,
                                                                       inAppTheme: { .default })
        emailVerificationViewController.viewModel = EmailVerificationViewModel(signupService: SignupServiceMock())
        _ = emailVerificationViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .emailVerification)))
    }

    func testCongratulationScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let summaryViewController = UIStoryboard.instantiate(storyboardName: "PMSignup",
                                                             controllerType: SummaryViewController.self,
                                                             inAppTheme: { .default })
        summaryViewController.viewModel = SummaryViewModel(planName: nil, paymentsAvailability: .notAvailable, screenVariant: .noSummaryScreen, clientApp: .other(named: "core-unit-tests"))
        _ = summaryViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .congratulation)))
    }

    func testProtonAccountWithCurrentEmailScreenLoadEventIsSent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let createAddressViewController = UIStoryboard.instantiate(storyboardName: "PMLogin",
                                                                   controllerType: CreateAddressViewController.self,
                                                                   inAppTheme: { .default })
        createAddressViewController.viewModel = CreateAddressViewModel(
            data: CreateAddressData(email: .empty, credential: .dummy, user: .dummy, mailboxPassword: .empty, passwordMode: .one),
            login: LoginMock(),
            defaultUsername: nil
        )
        _ = createAddressViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(
            event: .screenLoadCountTotal(screenName: .createProtonAccountWithCurrentEmail)
        ))
    }
}

#endif
