//
//  Example_AccountDeletion_UITests.swift
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

import XCTest
import ProtonCore_TestingToolkit

final class AccountDeletionTests: AccountDeletionBaseTestCase {
    
    func testAccountIsDeleted() throws {
        let (robot, password) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsDisplayed(type: .button)
    }
    
    func testAccountDeletionCanBeClosed() throws {
        let (robot, _) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .tapCancelButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsDisplayed(type: .button)
    }
    
    func testAccountDeletionNeedsConfirmation() throws {
        let (robot, password) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            // no confirmation
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    
    func testAccountDeletionNeedsReason() throws {
        let (robot, password) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            // no reason
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    func testAccountDeletionNeedsExplaination() throws {
        let (robot, password) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            // no explaination
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    func testAccountDeletionNeedsEmail() throws {
        let (robot, password) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            // no email
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    func testAccountDeletionNeedsPassword() throws {
        let (robot, _) = appRobot.createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            // no password
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
}
