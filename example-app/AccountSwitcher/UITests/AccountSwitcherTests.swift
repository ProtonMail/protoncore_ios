//
//  AccountSwitcherTests.swift
//  CoreExample - Created on 07/06/2021.
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

import Foundation
import XCTest
import ProtonCore_TestingToolkit

final class AccountSwitcherTests: AccountSwitcherBaseTestCase {

    let signedInUserDisplayName = "😂_a"
    let signedOutUserDisplayName = "QA_👍"

    func testSwitcherComponentIsShown() {
        appRobot
            .showSwitcherComponent()
            .verify.switcherScreenIsDisplayed()
    }

    func testSwitcherComponentNavigatesToSwitcherScreen() {
        appRobot
            .showSwitcherComponent()
            .goToSwitcherScreen()
            .verify.switcherScreenIsDisplayed()
    }

    func testSwitcherComponentAllowsToSwitchUser() {
        appRobot
            .showSwitcherComponent()
            .switchToUser(displayName: signedOutUserDisplayName,
                          to: AccountSwitcherSampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenIsShown() {
        appRobot
            .showSwitcherScreen()
            .verify.switcherScreenIsDisplayed()
    }

    func testSwitcherScreenIsClosing() {
        appRobot
            .showSwitcherScreen()
            .closeScreen(to: AccountSwitcherSampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenIsAddingAccount() {
        appRobot
            .showSwitcherScreen()
            .addAccount(to: AccountSwitcherSampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenAllowsToSwitchUser() {
        appRobot
            .showSwitcherScreen()
            .switchToUser(displayName: signedOutUserDisplayName,
                          to: AccountSwitcherSampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenShowsProperMenuForSignedInUser() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedInUserDisplayName)
            .verify.signOutMenuIsDisplayed()
    }

    func testSwitcherScreenShowsProperMenuForSignedOutUser() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedOutUserDisplayName)
            .verify.signInMenuIsDisplayed()
    }

    func testSwitcherScreenMoreMenuAllowsToSignInUser() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedOutUserDisplayName)
            .signIn(to: AccountSwitcherSampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenShowsConfirmationMenuForSigningOutAccount() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedInUserDisplayName)
            .signOut()
            .verify.signOutConfirmationIsDisplayed()
    }

    func testSwitcherScreenShowsConfirmationMenuForRemovingAccount() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedInUserDisplayName)
            .remove()
            .verify.removeAccountConfirmationIsDisplayed()
    }

    func testSwitcherScreenSignsOutAfterConfirmation() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedInUserDisplayName)
            .signOut()
            .signOut(to: AccountSwitcherScreenRobot.self)
            .verify.switcherScreenIsDisplayed()
    }

    func testSwitcherScreenRemovesAfterConfirmation() {
        appRobot
            .showSwitcherScreen()
            .showMoreMenu(forUserDisplayName: signedInUserDisplayName)
            .remove()
            .remove(to: AccountSwitcherScreenRobot.self)
            .verify.switcherScreenIsDisplayed()
    }

}
