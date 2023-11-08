//
//  PaymentsUIScreenLoadObservabilityTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 14/02/2023.
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

import UIKit
import XCTest
import ProtonCoreDataModel
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsObservability
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreObfuscatedConstants
import SnapshotTesting
import ProtonCoreUIFoundations
@testable import ProtonCoreObservability
@testable import ProtonCorePayments
@testable import ProtonCorePaymentsUI

final class PaymentsUIScreenLoadObservabilityTests: XCTestCase {

    func testPlanSelectionScreenLoadEventIsSentInSignup() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI",
                                                                controllerType: PaymentsUIViewController.self,
                                                                inAppTheme: { .default })
        paymentsUIViewController.mode = .signup
        _ = paymentsUIViewController.view
        XCTAssertTrue(stub.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(stub.reportStub.lastArguments!.value.isSameAs(event: .screenLoadCountTotal(screenName: .planSelection)))
    }

    func testPlanSelectionScreenLoadEventIsNotSentInCurrent() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI",
                                                                controllerType: PaymentsUIViewController.self,
                                                                inAppTheme: { .default })
        paymentsUIViewController.mode = .current
        _ = paymentsUIViewController.view
        XCTAssertTrue(stub.reportStub.wasNotCalled)
    }

    func testPlanSelectionScreenLoadEventIsNotSentInUpdate() {
        let stub = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = stub
        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI",
                                                                controllerType: PaymentsUIViewController.self,
                                                                inAppTheme: { .default })
        paymentsUIViewController.mode = .update
        _ = paymentsUIViewController.view
        XCTAssertTrue(stub.reportStub.wasNotCalled)
    }
}

#endif
