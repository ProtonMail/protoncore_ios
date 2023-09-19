//
//  PaymentsUIScreenAppearTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 13/09/2023.
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

final class PaymentsUIScreenAppearTests: XCTestCase {

    var controllerWillAppearForFirstTime: Bool? = nil

    override func setUp() {
        super.setUp()
        controllerWillAppearForFirstTime = nil
    }

    func testControllerCallsDelegateWhenAppears() {
        let paymentsUIViewController = UIStoryboard.instantiate(
            storyboardName: "PaymentsUI",
            controllerType: PaymentsUIViewController.self,
            inAppTheme: { .default }
        )
        paymentsUIViewController.delegate = self
        paymentsUIViewController.viewWillAppear(true)

        XCTAssertEqual(controllerWillAppearForFirstTime, true)
        controllerWillAppearForFirstTime = nil

        paymentsUIViewController.viewWillAppear(true)

        XCTAssertEqual(controllerWillAppearForFirstTime, false)
    }

    func testControllerCallsDelegateWhenAppGoesToForeground() {
        let paymentsUIViewController = UIStoryboard.instantiate(
            storyboardName: "PaymentsUI",
            controllerType: PaymentsUIViewController.self,
            inAppTheme: { .default }
        )
        paymentsUIViewController.delegate = self
        _ = paymentsUIViewController.view

        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        XCTAssertEqual(controllerWillAppearForFirstTime, false)
    }
}

extension PaymentsUIScreenAppearTests: PaymentsUIViewControllerDelegate {
    func viewControllerWillAppear(isFirstAppearance: Bool) {
        controllerWillAppearForFirstTime = isFirstAppearance
    }

    func userDidCloseViewController() { }
    func userDidDismissViewController() { }
    func userDidSelectPlan(plan: PlanPresentation, addCredits: Bool, completionHandler: @escaping () -> Void) { }
    func userDidSelectPlan(plan: AvailablePlansPresentation, completionHandler: @escaping () -> Void) { }
    func planPurchaseError() { }
}

#endif

