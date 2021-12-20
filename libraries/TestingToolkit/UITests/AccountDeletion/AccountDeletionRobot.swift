//
//  AccountDeletionRobot.swift
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

private let accountDeletionButtonText = CoreString._ad_delete_account_button

public final class AccountDeletionButtonRobot: CoreElements {

    public let verify = Verify()

    public func openAccountDeletionWebView() -> AccountDeletionWebViewRobot {
        button(accountDeletionButtonText).tap()
        return AccountDeletionWebViewRobot()
    }

    public final class Verify: CoreElements {
        @discardableResult
        public func accountDeletionButtonIsDisplayed() -> AccountDeletionButtonRobot {
            button(accountDeletionButtonText).wait().checkExists()
            return AccountDeletionButtonRobot()
        }
    }
}

private let accountDeletionWebViewIndentifier = "AccountDeletionWebView.webView"

public final class AccountDeletionWebViewRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func accountDeletionWebViewIsOpened() -> AccountDeletionWebViewRobot {
            webView(accountDeletionWebViewIndentifier).wait().checkExists()
            return AccountDeletionWebViewRobot()
        }
    }

}
