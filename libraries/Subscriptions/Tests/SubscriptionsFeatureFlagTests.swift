//
//  SubscriptionsFeatureFlagTests.swift
//  ProtonCore-Subscriptions-Tests - Created on 28/8/23.
//
//  Copyright (c) 2023 Proton AG
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
import ProtonCoreFeatureSwitch
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
import ProtonCoreSubscriptions

final class SubscriptionsFeatureFlagTests: XCTestCase {

    func testFeatureIsEnabled() {
        withFeatureSwitches([.subscriptions]) {
            XCTAssert(FeatureFactory.shared.isEnabled(.subscriptions))
        }
    }

    func testFeatureIsDisabled() {
        withFeatureSwitches([]) {
            XCTAssertFalse(FeatureFactory.shared.isEnabled(.subscriptions))
        }
    }

    func testDefaultSwitches() {
        XCTAssertFalse(FeatureFactory.shared.isEnabled(.subscriptions))
    }
}
