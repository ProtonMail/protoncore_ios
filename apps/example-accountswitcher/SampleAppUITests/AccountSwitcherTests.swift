//
//  AccountSwitcherTests.swift
//  SampleAppUITests
//
//  Created by Krzysztof Siejkowski on 07/06/2021.
//

import Foundation
import XCTest
import ProtonCore_TestingToolkit

final class AccountSwitcherTests: BaseTestCase {

    let signedInUserDisplayName = "😂_a"
    let signedOutUserDisplayName = "QA_👍"

    let appRobot = SampleAppRobot()

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
            .switchToUser(displayName: signedOutUserDisplayName, to: SampleAppRobot.self)
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
            .closeScreen(to: SampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenIsAddingAccount() {
        appRobot
            .showSwitcherScreen()
            .addAccount(to: SampleAppRobot.self)
            .verify.sampleAppScreenIsDisplayed()
    }

    func testSwitcherScreenAllowsToSwitchUser() {
        appRobot
            .showSwitcherScreen()
            .switchToUser(displayName: signedOutUserDisplayName, to: SampleAppRobot.self)
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
            .signIn(to: SampleAppRobot.self)
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
