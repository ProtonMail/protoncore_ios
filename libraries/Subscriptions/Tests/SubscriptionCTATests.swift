//
//  SubscriptionCTATests.swift
//  ProtonCore-Subscriptions - Created on 04.10.2023.
//
//  Copyright (c) 2023 Proton Technologies AG
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

#if os(iOS)

import XCTest
import ProtonCoreSubscriptions

final class SubscriptionCTATests: XCTestCase {

    var cut: SubscriptionCTA!

    override func tearDown() {
        cut = nil
        super.tearDown()
    }

    func testUpgradeProperties() {
        cut = .upgrade

        XCTAssertEqual("pmsettings-settings-system-settings-upgrade-subscription-title", cut.title)
        XCTAssertEqual("pmsettings-settings-system-settings-upgrade-subscription-description", cut.description)
        XCTAssertEqual("pmsettings-settings-system-settings-upgrade-subscription-button", cut.buttonText)
    }

    func testManageSubscriptionProperties() {
        cut = .manageSubscription

        XCTAssertEqual("pmsettings-settings-system-settings-manage-subscription-title", cut.title)
        XCTAssertEqual("pmsettings-settings-system-settings-manage-subscription-description", cut.description)
        XCTAssertEqual("pmsettings-settings-system-settings-manage-subscription-button", cut.buttonText)
    }

    func testCannotManageSubscriptionProperties() {
        cut = .cannotManageSubscription

        XCTAssertEqual("pmsettings-settings-system-settings-cannot-manage-subscription-title", cut.title)
        XCTAssertEqual("pmsettings-settings-system-settings-cannot-manage-subscription-description", cut.description)
    }
}
#endif
