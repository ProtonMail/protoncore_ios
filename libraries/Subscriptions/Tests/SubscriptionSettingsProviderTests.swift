//
//  SubscriptionSettingsProviderTests.swift
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
import ProtonCorePayments
import ProtonCoreSubscriptions

final class SubscriptionSettingsProviderTests: XCTestCase {

    var subscription: CurrentPlan.Subscription!

    override func setUp() {
        subscription = CurrentPlan.Subscription(title: "bla", description: "bla", entitlements: [])
    }

    override func tearDown() {
        subscription = nil
        super.tearDown()
    }

    func testCTAforNoSubscription() {
        subscription.external = nil

        let cta = SubscriptionSettingsProvider.appropriateCTA(for: subscription)

        XCTAssertEqual(.upgrade, cta)
    }

    func testCTAforExternalSubscription() {
        subscription.external = .web

        let cta = SubscriptionSettingsProvider.appropriateCTA(for: subscription)

        XCTAssertEqual(.cannotManageSubscription, cta)
    }

    func testCTAforIAPSubscription() {
        subscription.external = .apple

        let cta = SubscriptionSettingsProvider.appropriateCTA(for: subscription)

        XCTAssertEqual(.manageSubscription, cta)
    }

}

#endif
