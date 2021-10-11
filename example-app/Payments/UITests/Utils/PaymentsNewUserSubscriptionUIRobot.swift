//
//  PaymentsNewUserSubscriptionUIRobot.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import pmtest
import XCTest
import ProtonCore_TestingToolkit

private let titleText = "New user subscription"
private let usernameTextField = "NewUserSubscriptionUIVC.usernameTextField"
private let passwordTextField = "NewUserSubscriptionUIVC.passwordTextField"
private let loginButtonId = "NewUserSubscriptionUIVC.loginButton"
private let showCurrentPlanButtonId = "NewUserSubscriptionUIVC.showCurrentPlanButton"
private let showUpdatePlansButtonId = "NewUserSubscriptionUIVC.showUpdatePlansButton"
private let backendFetchSwitchId = "NewUserSubscriptionUIVC.backendFetchSwitch"
private let modalVCSwitchId = "NewUserSubscriptionUIVC.modalVCSwitch"

public final class PaymentsNewUserSubscriptionUIRobot: CoreElements {
    
    public let verify = Verify()
    
    public class Verify: CoreElements {
        @discardableResult
        public func newUserSubscriptionUIScreenIsShown() -> PaymentsNewUserSubscriptionUIRobot {
            staticText(titleText).wait().checkExists()
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
    
    public func loginButtonTap() -> PaymentsNewUserSubscriptionUIRobot {
        button(loginButtonId).wait().isEnabled().tap()
        return self
    }
    
    public func showCurrentPlanButtonTap() -> PaymentsUIRobot {
        button(showCurrentPlanButtonId).wait().isEnabled().tap()
        return PaymentsUIRobot()
    }
    
    public func showUpdatePlansButtonTap() -> PaymentsUIRobot {
        button(showUpdatePlansButtonId).wait().tap()
        return PaymentsUIRobot()
    }
}
