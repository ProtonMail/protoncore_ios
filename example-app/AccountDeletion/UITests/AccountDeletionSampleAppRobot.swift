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
import pmtest
import ProtonCore_TestingToolkit
import XCTest

let createAccountButton = "AccountDeletionViewController.createAccountButton"
let accountDetailsLabel = "AccountDeletionViewController.accountDetailsLabel"

final class AccountDeletionSampleAppRobot: CoreElements {
    
    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func sampleAppScreenIsDisplayed() -> AccountDeletionSampleAppRobot {
            button(createAccountButton).wait().checkExists()
            return AccountDeletionSampleAppRobot()
        }
    }

    func createAccount() -> (AccountDeletionButtonRobot, String) {
        button(createAccountButton).tap()
        let detailsString = staticText(accountDetailsLabel).wait().checkExists().label()
        guard let passwordRange = detailsString.range(of: "Password:\\s.*", options: .regularExpression) else {
            XCTFail("Couldn't find the password in newly created account details")
            return (AccountDeletionButtonRobot(), "")
        }
        let passwordString = detailsString[passwordRange].dropFirst(10)
        return (AccountDeletionButtonRobot(), String(passwordString))
    }
}
