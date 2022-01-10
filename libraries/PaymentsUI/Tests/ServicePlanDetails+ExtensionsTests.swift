//
//  ServicePlanDetailsExtensionsTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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
import ProtonCore_CoreTranslation
import ProtonCore_Payments
import ProtonCore_TestingToolkit
@testable import ProtonCore_PaymentsUI

final class PlanTests: XCTestCase {

    // MARK: titleDescription tests

    func testName() {
        let plan = Plan.empty.updated(title: "test title")
        XCTAssertEqual(plan.titleDescription, "test title")
    }

    func testNameEmpty() {
        let plan = Plan.empty
        XCTAssertEqual(plan.titleDescription, .empty)
    }

    // MARK: XGBStorageDescription tests
    func testStorageDescriptionHalf() {
        let plan = Plan.empty.updated(maxSpace: 524288000)
        XCTAssertEqual(plan.XGBStorageDescription, String(format: CoreString._pu_plan_details_storage, "0.5 GB"))
    }

    func testStorageDescription1() {
        let plan = Plan.empty.updated(maxSpace: 1073741824)
        XCTAssertEqual(plan.XGBStorageDescription, String(format: CoreString._pu_plan_details_storage, "1 GB"))
    }

    func testStorageDescription1point3() {
        let plan = Plan.empty.updated(maxSpace: 1395864371)
        XCTAssertEqual(plan.XGBStorageDescription, String(format: CoreString._pu_plan_details_storage, "1.3 GB"))
    }

    // MARK: XGBStoragePerUserDescription tests
    func testStoragePerUserDescriptionHalf() {
        let plan = Plan.empty.updated(maxSpace: 524288000)
        XCTAssertEqual(plan.XGBStoragePerUserDescription, String(format: CoreString._pu_plan_details_storage_per_user, "0.5 GB"))
    }

    func testStoragePerUserDescription1() {
        let plan = Plan.empty.updated(maxSpace: 1073741824)
        XCTAssertEqual(plan.XGBStoragePerUserDescription, String(format: CoreString._pu_plan_details_storage_per_user, "1 GB"))
    }

    func testStoragePerUserDescription1point3() {
        let plan = Plan.empty.updated(maxSpace: 1395864371)
        XCTAssertEqual(plan.XGBStoragePerUserDescription, String(format: CoreString._pu_plan_details_storage_per_user, "1.3 GB"))
    }
    
    // MARK: YAddressesDescription tests
    func testAddressesDescription1() {
        let plan = Plan.empty.updated(maxAddresses: 1)
        XCTAssertEqual(plan.YAddressesDescription, String(format: CoreString._pu_plan_details_n_addresses, 1))
    }

    func testAddressesDescription0() {
        let plan = Plan.empty.updated(maxAddresses: 0)
        XCTAssertEqual(plan.YAddressesDescription, String(format: CoreString._pu_plan_details_n_addresses, 0))
    }

    func testAddressesDescription2() {
        let plan = Plan.empty.updated(maxAddresses: 2)
        XCTAssertEqual(plan.YAddressesDescription, String(format: CoreString._pu_plan_details_n_addresses, 2))
    }

    // MARK: YAddressesPerUserDescription tests
    func testAddressesPerUserDescription1() {
        let plan = Plan.empty.updated(maxAddresses: 1)
        XCTAssertEqual(plan.YAddressesPerUserDescription, String(format: CoreString._pu_plan_details_n_addresses_per_user, 1))
    }

    func testAddressesPerUserDescription0() {
        let plan = Plan.empty.updated(maxAddresses: 0)
        XCTAssertEqual(plan.YAddressesPerUserDescription, String(format: CoreString._pu_plan_details_n_addresses_per_user, 0))
    }

    func testAddressesPerUserDescription2() {
        let plan = Plan.empty.updated(maxAddresses: 2)
        XCTAssertEqual(plan.YAddressesPerUserDescription, String(format: CoreString._pu_plan_details_n_addresses_per_user, 2))
    }

    // MARK: ZCalendarsDescription tests
    func testCalendarsDescription1() {
        let plan = Plan.empty.updated(maxCalendars: 1)
        XCTAssertEqual(plan.ZCalendarsDescription, String(format: CoreString._pu_plan_details_n_calendars, 1))
    }

    func testCalendarsDescription0() {
        let plan = Plan.empty.updated(maxCalendars: 0)
        XCTAssertEqual(plan.ZCalendarsDescription, String(format: CoreString._pu_plan_details_n_calendars, 0))
    }

    func testCalendarsDescription2() {
        let plan = Plan.empty.updated(maxCalendars: 2)
        XCTAssertEqual(plan.ZCalendarsDescription, String(format: CoreString._pu_plan_details_n_calendars, 2))
    }

    func testCalendarsDescriptionNil() {
        let plan = Plan.empty.updated(maxCalendars: nil)
        XCTAssertEqual(plan.ZCalendarsDescription, nil)
    }

    // MARK: ZCalendarsPerUserDescription tests
    func testCalendarsPerUserDescription1() {
        let plan = Plan.empty.updated(maxCalendars: 1)
        XCTAssertEqual(plan.ZCalendarsPerUserDescription, String(format: CoreString._pu_plan_details_n_calendars_per_user, 1))
    }

    func testCalendarsPerUserDescription0() {
        let plan = Plan.empty.updated(maxCalendars: 0)
        XCTAssertEqual(plan.ZCalendarsPerUserDescription, String(format: CoreString._pu_plan_details_n_calendars_per_user, 0))
    }

    func testCalendarsPerUserDescription2() {
        let plan = Plan.empty.updated(maxCalendars: 2)
        XCTAssertEqual(plan.ZCalendarsPerUserDescription, String(format: CoreString._pu_plan_details_n_calendars_per_user, 2))
    }

    func testCalendarsPerUserDescriptionNil() {
        let plan = Plan.empty.updated(maxCalendars: nil)
        XCTAssertEqual(plan.ZCalendarsPerUserDescription, nil)
    }

    // MARK: UVPNConnectionsDescription tests
    func testVPNConnectionsDescription1() {
        let plan = Plan.empty.updated(maxVPN: 1)
        XCTAssertEqual(plan.UConnectionsDescription, String(format: CoreString._pu_plan_details_n_connections, 1))
    }

    func testVPNConnectionsDescription0() {
        let plan = Plan.empty.updated(maxVPN: 0)
        XCTAssertEqual(plan.UConnectionsDescription, String(format: CoreString._pu_plan_details_n_connections, 0))
    }

    func testVPNConnectionsDescription2() {
        let plan = Plan.empty.updated(maxVPN: 2)
        XCTAssertEqual(plan.UConnectionsDescription, String(format: CoreString._pu_plan_details_n_connections, 2))
    }

    // MARK: UHighSpeedVPNConnectionsDescription tests
    func testHighSpeedVPNConnectionsDescription1() {
        let plan = Plan.empty.updated(maxVPN: 1)
        XCTAssertEqual(plan.UHighSpeedVPNConnectionsDescription, String(format: CoreString._pu_plan_details_n_high_speed_connections, 1))
    }

    func testHighSpeedVPNConnectionsDescription0() {
        let plan = Plan.empty.updated(maxVPN: 0)
        XCTAssertEqual(plan.UHighSpeedVPNConnectionsDescription, String(format: CoreString._pu_plan_details_n_high_speed_connections, 0))
    }

    func testHighSpeedVPNConnectionsDescription2() {
        let plan = Plan.empty.updated(maxVPN: 2)
        XCTAssertEqual(plan.UHighSpeedVPNConnectionsDescription, String(format: CoreString._pu_plan_details_n_high_speed_connections, 2))
    }

    // MARK: UHighSpeedVPNConnectionsPerUserDescription tests
    func testHighSpeedVPNConnectionsPerUserDescription1() {
        let plan = Plan.empty.updated(maxVPN: 1)
        XCTAssertEqual(plan.UHighSpeedVPNConnectionsPerUserDescription, String(format: CoreString._pu_plan_details_n_high_speed_connections_per_user, 1))
    }

    func testHighSpeedVPNConnectionsPerUserDescription0() {
        let plan = Plan.empty.updated(maxVPN: 0)
        XCTAssertEqual(plan.UHighSpeedVPNConnectionsPerUserDescription, String(format: CoreString._pu_plan_details_n_high_speed_connections_per_user, 0))
    }

    func testHighSpeedVPNConnectionsPerUserDescription2() {
        let plan = Plan.empty.updated(maxVPN: 2)
        XCTAssertEqual(plan.UHighSpeedVPNConnectionsPerUserDescription, String(format: CoreString._pu_plan_details_n_high_speed_connections_per_user, 2))
    }

    // MARK: VCustomDomainDescription tests
    func testCustomDomainDescription1() {
        let plan = Plan.empty.updated(maxDomains: 1)
        XCTAssertEqual(plan.VCustomDomainDescription, String(format: CoreString._pu_plan_details_n_custom_domains, 1))
    }

    func testCustomDomainDescription0() {
        let plan = Plan.empty.updated(maxDomains: 0)
        XCTAssertEqual(plan.VCustomDomainDescription, String(format: CoreString._pu_plan_details_n_custom_domains, 0))
    }

    func testCustomDomainDescription2() {
        let plan = Plan.empty.updated(maxDomains: 2)
        XCTAssertEqual(plan.VCustomDomainDescription, String(format: CoreString._pu_plan_details_n_custom_domains, 2))
    }

    // MARK: WUsersDescription tests
    func testUsersDescription1() {
        let plan = Plan.empty.updated(maxMembers: 1)
        XCTAssertEqual(plan.WUsersDescription, String(format: CoreString._pu_plan_details_n_users, 1))
    }

    func testUsersDescription0() {
        let plan = Plan.empty.updated(maxMembers: .zero)
        XCTAssertEqual(plan.WUsersDescription, String(format: CoreString._pu_plan_details_n_users, 0))
    }

    func testUsersDescription2() {
        let plan = Plan.empty.updated(maxMembers: 2)
        XCTAssertEqual(plan.WUsersDescription, String(format: CoreString._pu_plan_details_n_users, 2))
    }

    // MARK: YAddressesAndZCalendars tests
    func testAddressesAndCalendarsDescription11() {
        let plan = Plan.empty.updated(maxAddresses: 1, maxCalendars: 1)
        XCTAssertEqual(plan.YAddressesAndZCalendars, String(format: CoreString._pu_plan_details_n_addresses_and_calendars, 1))
    }

    func testAddressesAndCalendarsDescription22() {
        let plan = Plan.empty.updated(maxAddresses: 2, maxCalendars: 2)
        XCTAssertEqual(plan.YAddressesAndZCalendars, String(format: CoreString._pu_plan_details_n_addresses_and_calendars, 2))
    }

    // MARK: YAddressesAndZCalendars tests
    func testAddressesAndCalendarsDescription1nil() {
        let plan = Plan.empty.updated(maxAddresses: 1, maxCalendars: nil)
        XCTAssertEqual(plan.YAddressesAndZCalendars, plan.YAddressesDescription)
    }

    // MARK: YAddressesAndZCalendars tests
    func testAddressesAndCalendarsDescription21() {
        let plan = Plan.empty.updated(maxAddresses: 2, maxCalendars: 1)
        XCTAssertEqual(plan.YAddressesAndZCalendars, String(format: CoreString._pu_plan_details_n_uneven_amounts_of_addresses_and_calendars, plan.YAddressesDescription, plan.ZCalendarsDescription!))
    }
}
