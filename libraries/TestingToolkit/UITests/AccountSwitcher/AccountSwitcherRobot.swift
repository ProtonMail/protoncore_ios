//
//  AccountSwitcherRobot.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
//
//  Copyright (c) 2022 Proton Technologies AG
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

#if canImport(fusion)

import fusion
import ProtonCoreAccountSwitcher

private let switcherComponentManageLabelValue = ASTranslation.manage_accounts.l10n
private func switcherComponentCellIdentifier(userDisplayName: String) -> String {
    "AccountSwitcherCell.\(userDisplayName.replacingOccurrences(of: " ", with: "_"))"
}

public final class AccountSwitcherComponentRobot: CoreElements {

    public let verify = Verify()

    public func goToSwitcherScreen() -> AccountSwitcherScreenRobot {
        staticText(switcherComponentManageLabelValue).tap()
        return AccountSwitcherScreenRobot()
    }

    public func switchToUser<Robot: CoreElements>(displayName: String, to: Robot.Type) -> Robot {
        cell(switcherComponentCellIdentifier(userDisplayName: displayName)).tap()
        return Robot()
    }

    public final class Verify: CoreElements {
        @discardableResult
        public func switcherScreenIsDisplayed() -> AccountSwitcherScreenRobot {
            staticText(switcherComponentManageLabelValue).waitUntilExists().checkExists()
            return AccountSwitcherScreenRobot()
        }
    }

}

private let switcherScreenTitleLabelID = "AccountManagerVC.titleLabel"
private let switcherScreenCloseButton = "UINavigationItem.leftBarButtonItem"
private let switcherScreenAddButton = "UINavigationItem.rightBarButtonItem"
private func switcherCellIdentifier(userDisplayName: String) -> String {
    "AccountmanagerUserCell.\(userDisplayName.replacingOccurrences(of: " ", with: "_"))"
}
private func switcherCellMoreButtonIdentifier(userDisplayName: String) -> String {
    "\(userDisplayName).moreBtn"
}

public final class AccountSwitcherScreenRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func switcherScreenIsDisplayed() -> AccountSwitcherScreenRobot {
            staticText(switcherScreenTitleLabelID).waitUntilExists().checkExists()
            return AccountSwitcherScreenRobot()
        }
    }

    public func addAccount<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(switcherScreenAddButton).tap()
        return Robot()
    }

    public func showMoreMenu(forUserDisplayName name: String) -> AccountSwitcherMoreMenuRobot {
        button(switcherCellMoreButtonIdentifier(userDisplayName: name)).tap()
        return AccountSwitcherMoreMenuRobot()
    }

    public func switchToUser<Robot: CoreElements>(displayName: String, to: Robot.Type) -> Robot {
        cell(switcherCellIdentifier(userDisplayName: displayName)).tap()
        return Robot()
    }

    public func closeScreen<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(switcherScreenCloseButton).tap()
        return Robot()
    }
}

private let signInPopupIdentifier = ASTranslation.sign_in_screen_title.l10n
private let signOutPopupIdentifier = ASTranslation.signout.l10n
private let cancelPopupIdentifier = ASTranslation.cancel_button.l10n
private let removeAccountPopupIdentifier = ASTranslation.remove_account_from_this_device.l10n
private let removeAccountConfirmationIdentifier = ASTranslation.remove_button.l10n

public final class AccountSwitcherMoreMenuRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func signInMenuIsDisplayed() -> AccountSwitcherMoreMenuRobot {
            button(signInPopupIdentifier).waitUntilExists().checkExists()
            button(removeAccountPopupIdentifier).waitUntilExists().checkExists()
            return AccountSwitcherMoreMenuRobot()
        }
        @discardableResult
        public func signOutMenuIsDisplayed() -> AccountSwitcherMoreMenuRobot {
            button(signOutPopupIdentifier).waitUntilExists().checkExists()
            button(removeAccountPopupIdentifier).waitUntilExists().checkExists()
            return AccountSwitcherMoreMenuRobot()
        }
    }

    public func signIn<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(signInPopupIdentifier).tap()
        return Robot()
    }

    public func signOut() -> AccountSwitcherConfirmationPopupRobot {
        button(signOutPopupIdentifier).tap()
        return AccountSwitcherConfirmationPopupRobot()
    }

    public func remove() -> AccountSwitcherConfirmationPopupRobot {
        button(removeAccountPopupIdentifier).tap()
        return AccountSwitcherConfirmationPopupRobot()
    }
}

public final class AccountSwitcherConfirmationPopupRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func signOutConfirmationIsDisplayed() -> AccountSwitcherConfirmationPopupRobot {
            button(signOutPopupIdentifier).waitUntilExists().checkExists()
            button(cancelPopupIdentifier).waitUntilExists().checkExists()
            return AccountSwitcherConfirmationPopupRobot()
        }
        @discardableResult
        public func removeAccountConfirmationIsDisplayed() -> AccountSwitcherConfirmationPopupRobot {
            button(removeAccountConfirmationIdentifier).waitUntilExists().checkExists()
            button(cancelPopupIdentifier).waitUntilExists().checkExists()
            return AccountSwitcherConfirmationPopupRobot()
        }
    }

    public func signOut<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(signOutPopupIdentifier).tap()
        return Robot()
    }

    public func remove<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(removeAccountConfirmationIdentifier).tap()
        return Robot()
    }

    public func cancel() -> AccountSwitcherScreenRobot {
        button(cancelPopupIdentifier).tap()
        return AccountSwitcherScreenRobot()
    }

}

#endif
