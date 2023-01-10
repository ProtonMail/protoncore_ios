//
//  PMAccountSwitcherSnapshotTests.swift
//  ProtonCore-AccountSwitcher-Tests - Created on 06/01/2023.
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

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_UIFoundations
@testable import ProtonCore_AccountSwitcher

@available(iOS 13, *)
class PMAccountSwitcherSnapshotTests: SnapshotTestCase {
        
    func testAccountSwitcherScreen() {
        let list: [AccountSwitcher.AccountData] = [
            .init(userID: "userID_a", name: "", mail: "ooo@pm.me", isSignin: true, unread: 100),
            .init(userID: "userID_b", name: "QA 👍", mail: "user_b_with_super_long_address@pm.me", isSignin: false, unread: 0),
            .init(userID: "userID_c", name: "W W", mail: "user_c@protonmail.com", isSignin: true, unread: 1000),
            .init(userID: "userID_d", name: "", mail: "user_c@protonmail.com", isSignin: true, unread: 1000),
            .init(userID: "userID_e", name: "😂 a", mail: "user_c@protonmail.com", isSignin: true, unread: 1000)
        ]
        
        let viewController = AccountManagerVC.instance()
        let viewModel = AccountManagerViewModel(accounts: list, uiDelegate: viewController)
        viewController.set(viewModel: viewModel)
        guard let navigationController = viewController.navigationController else {
            XCTFail("navigationController doesn't exist")
            return
        }
        checkSnapshots(controller: navigationController, perceptualPrecision: 0.98)
    }

}
