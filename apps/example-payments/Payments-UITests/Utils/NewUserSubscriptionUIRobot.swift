//
//  NewUserSubscriptionUIRobot.swift
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

public final class NewUserSubscriptionUIRobot: CoreElements {
    
    public let verify = Verify()
    
    public class Verify: CoreElements {
        @discardableResult
        public func newUserSubscriptionUIScreenIsShown() -> NewUserSubscriptionUIRobot {
            staticText(titleText).wait().checkExists()
            return NewUserSubscriptionUIRobot()
        }
    }
    
    public func insertUsername(name: String) -> NewUserSubscriptionUIRobot {
        textField(usernameTextField).tap().typeText(name)
        return self
    }
    
    public func insertPassword(password: String) -> NewUserSubscriptionUIRobot {
        textField(passwordTextField).tap().typeText(password)
        return self
    }
    
    public func backendFetchSwitchTap() -> NewUserSubscriptionUIRobot {
        swittch(backendFetchSwitchId).tap()
        return self
    }
    
    public func modalVCSwitchTap() -> NewUserSubscriptionUIRobot {
        swittch(modalVCSwitchId).tap()
        return self
    }
    
    public func loginButtonTap() -> NewUserSubscriptionUIRobot {
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
