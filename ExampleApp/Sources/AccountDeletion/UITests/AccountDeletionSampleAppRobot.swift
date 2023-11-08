//
//  AccountDeletionSampleAppRobot.swift
//  Example-AccountDeletion-UITests - Created on 20/12/2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation
import fusion
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsAccountDeletion
#else
import ProtonCoreTestingToolkit
#endif
import XCTest
import ProtonCoreQuarkCommands

let createAccountButton = "AccountDeletionViewController.createAccountButton"
let accountDetailsLabel = "AccountDeletionViewController.accountDetailsLabel"
let useRandomButton = "Random"
let useCredentialsButton = "Custom"
let credentialsUsernameTextField = "AccountDeletionViewController.credentialsUsernameTextField"
let credentialsPasswordTextField = "AccountDeletionViewController.credentialsPasswordTextField"
let credentialsOwnerIdTextField = "AccountDeletionViewController.credentialsOwnerIdTextField"
let credentialsOwnerPasswordTextField = "AccountDeletionViewController.credentialsOwnerPasswordTextField"
let planTextField = "AccountDeletionViewController.planTextField"
let pickerView = "AccountDeletionViewController.pickerView"
let successfulAlertText = "Account deletion success"
let failureAlertText = "Account deletion failure"
let successfulAlertButton = "OK"
let environmentPaymentsBlackText = "payments"

final class AccountDeletionSampleAppRobot: CoreElements {

    let verify = Verify()

    final class Verify: CoreElements {
        @discardableResult
        func sampleAppScreenIsDisplayed() -> AccountDeletionSampleAppRobot {
            button(createAccountButton).waitUntilExists().checkExists()
            return AccountDeletionSampleAppRobot()
        }

        @discardableResult
        func successAlertIsDisplayed() -> AccountDeletionSampleAppRobot {
            alert(successfulAlertText).waitUntilExists().checkExists()
            return AccountDeletionSampleAppRobot()
        }

        @discardableResult
        func failureAlertIsDisplayed() -> AccountDeletionSampleAppRobot {
            alert(failureAlertText).waitUntilExists().checkExists()
            return AccountDeletionSampleAppRobot()
        }
    }

    func createAccount() -> (AccountDeletionButtonRobot, String, String, String) {
        button(createAccountButton).tap()
        guard let detailsString = staticText(accountDetailsLabel).waitUntilExists().checkExists().label() else {
            XCTFail("Couldn't find the details string in newly created account details")
            return (AccountDeletionButtonRobot(), "", "", "")
        }
        guard let passwordRange = detailsString.range(of: "Password:\\s.*", options: .regularExpression) else {
            XCTFail("Couldn't find the password in newly created account details")
            return (AccountDeletionButtonRobot(), "", "", "")
        }
        let passwordString = detailsString[passwordRange].dropFirst(10)
        guard let nameRange = detailsString.range(of: "Name:\\s.*", options: .regularExpression) else {
            return (AccountDeletionButtonRobot(), String(passwordString), "", "")
        }
        let nameString = detailsString[nameRange].dropFirst(6)
        guard let idRange = detailsString.range(of: "ID\\s\\(decrypt\\):\\s.*", options: .regularExpression) else {
            return (AccountDeletionButtonRobot(), String(passwordString), String(nameString), "")
        }
        let idString = detailsString[idRange].dropFirst(14)
        return (AccountDeletionButtonRobot(), String(passwordString), String(nameString), String(idString))
    }

    func createPaidAccount() -> AccountDeletionButtonRobot {
        button(createAccountButton).tap()
        return AccountDeletionButtonRobot()
    }

    @discardableResult
    public func changeEnvironmentToPaymentsBlack() -> AccountDeletionSampleAppRobot {
        button(environmentPaymentsBlackText).tap()
        return self
    }

    func switchPickerToAccount(_ account: AccountAvailableForCreation) -> AccountDeletionSampleAppRobot {
        pickerWheel().byIndex(0).adjust(to: account.description).checkHasValue(account.description)
        return self
    }

    func fillInCustomCredentials(
        username: String = "", password: String = "",
        ownerId: String = "", ownerPassword: String = "",
        plan: String = ""
    ) -> AccountDeletionSampleAppRobot {
        switchToCustomCredentials()
        if !username.isEmpty { insertUsername(username) }
        if !password.isEmpty { insertPassword(password) }
        if !ownerId.isEmpty { insertOwnerId(ownerId) }
        if !ownerPassword.isEmpty { insertOwnerPassword(ownerPassword) }
        if !plan.isEmpty { insertPlan(plan) }
        return self
    }

    @discardableResult
    func switchToCustomCredentials() -> AccountDeletionSampleAppRobot {
        button(useCredentialsButton).tap()
        return self
    }

    @discardableResult
    func insertUsername(_ name: String) -> AccountDeletionSampleAppRobot {
        textField(credentialsUsernameTextField).tap().typeText(name).typeText(XCUIKeyboardKey.return.rawValue)
        return self
    }

    @discardableResult
    func insertPassword(_ password: String) -> AccountDeletionSampleAppRobot {
        textField(credentialsPasswordTextField).tap().typeText(password).typeText(XCUIKeyboardKey.return.rawValue)
        return self
    }

    @discardableResult
    func insertOwnerId(_ ownerId: String) -> AccountDeletionSampleAppRobot {
        textField(credentialsOwnerIdTextField).tap().typeText(ownerId).typeText(XCUIKeyboardKey.return.rawValue)
        return self
    }

    @discardableResult
    func insertOwnerPassword(_ ownerPassword: String) -> AccountDeletionSampleAppRobot {
        textField(credentialsOwnerPasswordTextField).tap().typeText(ownerPassword).typeText(XCUIKeyboardKey.return.rawValue)
        return self
    }

    @discardableResult
    func insertPlan(_ plan: String) -> AccountDeletionSampleAppRobot {
        textField(planTextField).tap().typeText(plan).typeText(XCUIKeyboardKey.return.rawValue)
        return self
    }

    func confirmPopup() -> AccountDeletionSampleAppRobot {
        button(successfulAlertButton).tap()
        return self
    }

    func verifyAccountDeletionWasSuccessful() {
        self
            .verify.successAlertIsDisplayed()
            .confirmPopup()
            .verify.sampleAppScreenIsDisplayed()
    }

    func verifyAccountDeletionFailed() {
        self
            .verify.failureAlertIsDisplayed()
            .confirmPopup()
            .verify.sampleAppScreenIsDisplayed()
    }
}
