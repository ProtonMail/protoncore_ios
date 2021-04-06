//
//  AccountSwitcherRobot.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
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

import pmtest
import ProtonCore_CoreTranslation

private let switcherComponentManageLabelValue = CoreString._as_manage_accounts
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
            staticText(switcherComponentManageLabelValue).wait().checkExists()
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
            staticText(switcherScreenTitleLabelID).wait().checkExists()
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

private let signInPopupIdentifier = CoreString._ls_screen_title
private let signOutPopupIdentifier = CoreString._as_signout
private let cancelPopupIdentifier = CoreString._hv_cancel_button
private let removeAccountPopupIdentifier = CoreString._as_remove_account
private let removeAccountConfirmationIdentifier = CoreString._as_remove_button

public final class AccountSwitcherMoreMenuRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func signInMenuIsDisplayed() -> AccountSwitcherMoreMenuRobot {
            button(signInPopupIdentifier).wait().checkExists()
            button(removeAccountPopupIdentifier).wait().checkExists()
            return AccountSwitcherMoreMenuRobot()
        }
        @discardableResult
        public func signOutMenuIsDisplayed() -> AccountSwitcherMoreMenuRobot {
            button(signOutPopupIdentifier).wait().checkExists()
            button(removeAccountPopupIdentifier).wait().checkExists()
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
            button(signOutPopupIdentifier).wait().checkExists()
            button(cancelPopupIdentifier).wait().checkExists()
            return AccountSwitcherConfirmationPopupRobot()
        }
        @discardableResult
        public func removeAccountConfirmationIsDisplayed() -> AccountSwitcherConfirmationPopupRobot {
            button(removeAccountConfirmationIdentifier).wait().checkExists()
            button(cancelPopupIdentifier).wait().checkExists()
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
