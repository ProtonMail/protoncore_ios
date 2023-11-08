//
//  PaymentsNewUserSubscriptionUIRobot.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import fusion
import XCTest
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsPaymentsUI
#else
import ProtonCoreTestingToolkit
#endif

private let titleText = "New user subscription"
private let usernameTextField = "PaymentsNewUserSubscriptionUIVC.usernameTextField"
private let passwordTextField = "PaymentsNewUserSubscriptionUIVC.passwordTextField"
private let loginButtonId = "PaymentsNewUserSubscriptionUIVC.loginButton"
private let showCurrentPlanButtonId = "PaymentsNewUserSubscriptionUIVC.showCurrentPlanButton"
private let showUpdatePlansButtonId = "PaymentsNewUserSubscriptionUIVC.showUpdatePlansButton"
private let backendFetchSwitchId = "PaymentsNewUserSubscriptionUIVC.backendFetchSwitch"
private let modalVCSwitchId = "PaymentsNewUserSubscriptionUIVC.modalVCSwitch"
private let extendSubscriptionSwitchId = "PaymentsNewUserSubscriptionUIVC.canExtendSubscriptionSwitch"

public final class PaymentsNewUserSubscriptionUIRobot: CoreElements {

    public let verify = Verify()

    public class Verify: CoreElements {
        @discardableResult
        public func newUserSubscriptionUIScreenIsShown() -> PaymentsNewUserSubscriptionUIRobot {
            staticText(titleText).waitUntilExists().checkExists()
            return PaymentsNewUserSubscriptionUIRobot()
        }
    }

    public func insertUsername(name: String) -> PaymentsNewUserSubscriptionUIRobot {
        textField(usernameTextField).tap().typeText(name)
        return self
    }

    public func insertPassword(password: String) -> PaymentsNewUserSubscriptionUIRobot {
        textField(passwordTextField).tap().typeText(password)
        return self
    }

    public func backendFetchSwitchTap() -> PaymentsNewUserSubscriptionUIRobot {
        swittch(backendFetchSwitchId).tap()
        return self
    }

    public func modalVCSwitchTap() -> PaymentsNewUserSubscriptionUIRobot {
        swittch(modalVCSwitchId).tap()
        return self
    }

    public func extendSunscriptionSwitchTap() -> PaymentsNewUserSubscriptionUIRobot {
        swittch(extendSubscriptionSwitchId).tap()
        return self
    }

    public func loginButtonTap() -> PaymentsNewUserSubscriptionUIRobot {
        button(loginButtonId).waitUntilExists().isEnabled().tap()
        return self
    }

    public func showCurrentPlanButtonTap() -> PaymentsUIRobot {
        button(showCurrentPlanButtonId).waitUntilExists().isEnabled().doubleTap()
        return PaymentsUIRobot()
    }

    public func showUpdatePlansButtonTap() -> PaymentsUIRobot {
        button(showUpdatePlansButtonId).waitUntilExists().tap()
        return PaymentsUIRobot()
    }
}
