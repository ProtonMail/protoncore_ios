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

    var controllerWillAppearForFirstTime: Bool?
    var timeout: TimeInterval = 3

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

    func test_dynamicPlansEnabled_SignupModeIsUsedRightObservabilityEventIsSent() {
        withFeatureSwitches([.dynamicPlans]) {
            let expectation = self.expectation(description: "Event is sent")

            let observeMock = ObservabilityServiceMock()
            ObservabilityEnv.current.observabilityService = observeMock
            observeMock.reportStub.bodyIs { _, event in
                guard event.isSameAs(event: .paymentScreenView(screenID: .dynamicPlanSelection)) else {
                    return
                }
                expectation.fulfill()
            }

            let paymentsUIViewController = UIStoryboard.instantiate(
                storyboardName: "PaymentsUI",
                controllerType: PaymentsUIViewController.self,
                inAppTheme: { .default }
            )
            paymentsUIViewController.mode = .signup
            _ = paymentsUIViewController.view

            waitForExpectations(timeout: timeout)
        }
    }

    func test_dynamicPlansEnabled_CurrentModeIsUsedRightObservabilityEventIsSent() {
        withFeatureSwitches([.dynamicPlans]) {
            let expectation = self.expectation(description: "Event is sent")

            let observeMock = ObservabilityServiceMock()
            ObservabilityEnv.current.observabilityService = observeMock
            observeMock.reportStub.bodyIs { _, event in
                guard event.isSameAs(event: .paymentScreenView(screenID: .dynamicPlansCurrentSubscription)) else {
                    return
                }
                expectation.fulfill()
            }

            let paymentsUIViewController = UIStoryboard.instantiate(
                storyboardName: "PaymentsUI",
                controllerType: PaymentsUIViewController.self,
                inAppTheme: { .default }
            )
            paymentsUIViewController.mode = .current
            _ = paymentsUIViewController.view

            waitForExpectations(timeout: timeout)
        }
    }

    func test_dynamicPlansEnabled_UpdateModeIsUsedRightObservabilityEventIsSent() {
        withFeatureSwitches([.dynamicPlans]) {
            let expectation = self.expectation(description: "Event is sent")

            let observeMock = ObservabilityServiceMock()
            ObservabilityEnv.current.observabilityService = observeMock
            observeMock.reportStub.bodyIs { _, event in
                guard event.isSameAs(event: .paymentScreenView(screenID: .dynamicPlansUpgrade)) else {
                    return
                }
                expectation.fulfill()
            }

            let paymentsUIViewController = UIStoryboard.instantiate(
                storyboardName: "PaymentsUI",
                controllerType: PaymentsUIViewController.self,
                inAppTheme: { .default }
            )
            paymentsUIViewController.mode = .update
            _ = paymentsUIViewController.view

            waitForExpectations(timeout: timeout)
        }
    }

    func test_dynamicPlansDisabled_SignupModeIsUsedNoDynamicPlanObservabilityEventIsSent() {
        let expectation = self.expectation(description: "Event is sent")

        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        observeMock.reportStub.bodyIs { _, event in
            if event.isSameAs(event: .paymentScreenView(screenID: .dynamicPlanSelection)) {
                XCTFail("This event shouldn't be sent when dynamic plans feature flag is disabled")
            }
        }

        let paymentsUIViewController = UIStoryboard.instantiate(
            storyboardName: "PaymentsUI",
            controllerType: PaymentsUIViewController.self,
            inAppTheme: { .default }
        )
        paymentsUIViewController.mode = .signup
        _ = paymentsUIViewController.view

        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + timeout - 1) {
            // Expect that controller loading and events sending will be handled fast.
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
    }

    func test_dynamicPlansDisabled_CurrentModeIsUsedNoDynamicPlanObservabilityEventIsSent() {
        let expectation = self.expectation(description: "Event is sent")

        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        observeMock.reportStub.bodyIs { _, event in
            if event.isSameAs(event: .paymentScreenView(screenID: .dynamicPlanSelection)) {
                XCTFail("This event shouldn't be sent when dynamic plans feature flag is disabled")
            }
        }

        let paymentsUIViewController = UIStoryboard.instantiate(
            storyboardName: "PaymentsUI",
            controllerType: PaymentsUIViewController.self,
            inAppTheme: { .default }
        )
        paymentsUIViewController.mode = .current
        _ = paymentsUIViewController.view

        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + timeout - 1) {
            // Expect that controller loading and events sending will be handled fast.
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
    }

    func test_dynamicPlansDisabled_UpdateModeIsUsedNoDynamicPlanObservabilityEventIsSent() {
        let expectation = self.expectation(description: "Event is sent")

        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        observeMock.reportStub.bodyIs { _, event in
            if event.isSameAs(event: .paymentScreenView(screenID: .dynamicPlanSelection)) {
                XCTFail("This event shouldn't be sent when dynamic plans feature flag is disabled")
            }
        }

        let paymentsUIViewController = UIStoryboard.instantiate(
            storyboardName: "PaymentsUI",
            controllerType: PaymentsUIViewController.self,
            inAppTheme: { .default }
        )
        paymentsUIViewController.mode = .update
        _ = paymentsUIViewController.view

        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + timeout - 1) {
            // Expect that controller loading and events sending will be handled fast.
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
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
