//
//  PaymentsUIRobot.swift
//  ProtonCore-TestingToolkit - Created on 25.06.2021.
//
//  Copyright (c) 2021 Proton Technologies AG
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

import XCTest
import ProtonCore_CoreTranslation
import pmtest

private let title = CoreString._pu_select_plan_title
private let freePlanName = "Free"
private let plusPlanName = "Plus"
private func planCellIdentifier(name: String) -> String {
    "PlanCell.\(name)"
}
private func selectPlanButtonIdentifier(name: String) -> String {
    "\(name).selectPlanButton"
}

// System dialog definitions

private let subscribeButtonName = "Subscribe"
private let confirmButtonName = "Confirm"
private let passordTextFieldName = "Password"
private let signInButtonName = "Sign In"
private let buyButtonName = "Buy"
private let okButtonName = "OK"

public final class PaymentsUIRobot: CoreElements {
    
    public let verify = Verify()
    
    public final class Verify: CoreElements {
        @discardableResult
        public func paymentsUIScreenIsShown() -> PaymentsUIRobot {
            staticText(title).wait().checkExists()
            return PaymentsUIRobot()
        }
    }
    
    public func selectFreePlanCell() -> PaymentsUIRobot {
        cell(planCellIdentifier(name: freePlanName)).tap()
        return PaymentsUIRobot()
    }
    
    public func freePlanButtonTap() -> SignupHumanVerificationRobot.HVOrCompletionRobot {
        button(selectPlanButtonIdentifier(name: freePlanName)).tap()
        return SignupHumanVerificationRobot().verify.isHumanVerificationRequired()
    }
    
    public func freePlanButtonDoesNotExist() -> PaymentsUIRobot {
        button(selectPlanButtonIdentifier(name: freePlanName)).checkDoesNotExist()
        return PaymentsUIRobot()
    }
    
    public func selectPlusPlanCell() -> PaymentsUIRobot {
        cell(planCellIdentifier(name: plusPlanName)).tap()
        return PaymentsUIRobot()
    }
    
    public func plusPlanButtonTap() -> PaymentsUISystemRobot {
        button(selectPlanButtonIdentifier(name: plusPlanName)).tap()
        return PaymentsUISystemRobot()
    }
    
    public final class PaymentsUISystemRobot: CoreElements {

        public func verifyPaymentIfNeeded(password: String?) -> SignupHumanVerificationRobot.HVOrCompletionRobot {
            guard isButtonExist(name: selectPlanButtonIdentifier(name: freePlanName)) else {
                return SignupHumanVerificationRobot().verify.isHumanVerificationRequired()
            }
            // Continue verification only if plan is not purchased yet
            
            #if targetEnvironment(simulator)
                systemButtonTap(name: confirmButtonName)
                systemButtonTap(name: buyButtonName)
            #else
                systemButtonTap(name: subscribeButtonName)
                systemEditField(name: passordTextFieldName, text: password ?? "")
                systemButtonTap(name: signInButtonName)
                systemButtonTap(name: buyButtonName)
            #endif
            systemButtonTap(name: okButtonName)
            return SignupHumanVerificationRobot().verify.isHumanVerificationRequired()
        }
        
        private func isButtonExist(name: String) -> Bool {
            let button = XCUIApplication().buttons[name]
            Wait(time: 2).forElement(button)
            return button.exists
        }
        
        private func systemButtonTap(name: String) {
            let button = app.buttons[name]
            Wait().forElement(button)
            button.tap()
        }
        
        private func systemEditField(name: String, text: String) {
            let textField = app.secureTextFields[name]
            Wait().forElement(textField)
            textField.typeText(text)
        }
        
        private var app: XCUIApplication {
            return XCUIApplication(bundleIdentifier: "com.apple.springboard")
        }
    }
}
