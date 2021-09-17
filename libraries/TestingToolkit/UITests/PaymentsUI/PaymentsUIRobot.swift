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

public enum PaymentsPlan: String {
    case free = "Proton_Free"
    case plus = "Proton_Plus"
    case pro = "Professional"
    case visionary = "Visionary"
    
    var getDescription: [String] {
        switch self {
        case .free:
            return [
                "Current plan",
                "1 user",
                "500 MB storage",
                "1 address"]
        case .plus:
            return [
                "Current plan",
                "1 user",
                "5 GB storage *",
                "5 addresses",
                "Unlimited folders / labels / filters",
                "Custom email addresses"]
        case .pro:
            return [
                "Current plan",
                "1 user",
                "5 GB storage *",
                "10 addresses",
                "Unlimited folders / labels / filters",
                "Custom email addresses"]
        case .visionary:
            return [
                "Current plan",
                "6 users",
                "20 GB storage *",
                "50 addresses",
                "Unlimited folders / labels / filters",
                "Custom email addresses"]
        }
    }
}

public final class PaymentsUIRobot: CoreElements {
    
    public let verify = Verify()
    
    public final class Verify: CoreElements {
        @discardableResult
        public func paymentsUIScreenIsShown() -> PaymentsUIRobot {
            staticText(title).wait().checkExists()
            return PaymentsUIRobot()
        }
    }
    
    public func selectPlanCell(plan: PaymentsPlan) -> PaymentsUIRobot {
        cell(planCellIdentifier(name: plan.rawValue)).wait().tap()
        return self
    }
    
    public func freePlanButtonTap() -> SignupHumanVerificationRobot.HVOrCompletionRobot {
        button(selectPlanButtonIdentifier(name: PaymentsPlan.free.rawValue)).tap()
        return SignupHumanVerificationRobot().verify.isHumanVerificationRequired()
    }
    
    public func planButtonDoesNotExist(plan: PaymentsPlan) -> PaymentsUIRobot {
        button(selectPlanButtonIdentifier(name: plan.rawValue)).checkDoesNotExist()
        return self
    }
    
    @discardableResult
    public func verifyNumberOfCells(number: Int) -> PaymentsUIRobot {
        let count = XCUIApplication().tables.cells.count
        XCTAssert(count == number)
        return self
    }
    
    @discardableResult
    public func verifyPlan(plan: PaymentsPlan) -> PaymentsUIRobot {
        plan.getDescription.forEach {
            staticText($0).wait().checkExists()
        }
        return self
    }
    
    @discardableResult
    public func verifyExpirationTime() -> PaymentsUIRobot {
        let expirationString = String(format: CoreString._pu_plan_details_renew_expired, getEndDateString)
        staticText(expirationString).checkExists()
        return self
    }
    
    public func wait(timeInterval: TimeInterval) -> PaymentsUIRobot {
        Wait().wait(timeInterval: timeInterval)
        return self
    }
    
    public func planButtonTap(plan: PaymentsPlan) -> PaymentsUISystemRobot {
        button(selectPlanButtonIdentifier(name: plan.rawValue)).tap()
        return PaymentsUISystemRobot()
    }

    public final class PaymentsUISystemRobot: CoreElements {

        public func verifyPaymentIfNeeded(password: String?) -> SignupHumanVerificationRobot.HVOrCompletionRobot {
            guard isButtonExist(name: selectPlanButtonIdentifier(name: PaymentsPlan.free.rawValue)) else {
                return SignupHumanVerificationRobot().verify.isHumanVerificationRequired()
            }
            // Continue verification only if plan is not purchased yet
            
            confirmation(password: password)
            return SignupHumanVerificationRobot().verify.isHumanVerificationRequired()
        }
        
        public func verifyPayment(password: String?) -> PaymentsUIRobot {
            Wait().wait(timeInterval: 3)
            confirmation(password: password)
            return PaymentsUIRobot()
        }
        
        private func confirmation(password: String?) {
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
    
    public func activateApp<T: CoreElements>(robot _: T.Type) -> T {
        XCUIApplication().activate()
        return T()
    }
    
    public func terminateApp<T: CoreElements>(robot _: T.Type) -> T {
        XCUIApplication().terminate()
        return T()
    }
}

extension PaymentsUIRobot {
    var getEndDateString: String {
        let today = Date()
        let date = Calendar.current.date(byAdding: .year, value: 1, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let endDateString = dateFormatter.string(from: date)
        return endDateString
    }
}

extension Wait {
    func wait(timeInterval: TimeInterval) {
        let testCase = XCTestCase()
        let waitExpectation = testCase.expectation(description: "Waiting")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) {
            waitExpectation.fulfill()
        }
        testCase.waitForExpectations(timeout: timeInterval + 0.5)
    }
}
