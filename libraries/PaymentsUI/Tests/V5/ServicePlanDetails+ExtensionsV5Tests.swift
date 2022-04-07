//
//  ServicePlanDetailsExtensionsV5Tests.swift
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
import ProtonCore_CoreTranslation_V5
import ProtonCore_Payments
@testable import ProtonCore_PaymentsUI

final class ServicePlanDetailsExtensionsV5: XCTestCase {

    // MARK: upToXGBStorageDescription tests
    func testUpToXGBStorageDescription1() {
        let plan = Plan.empty.updated(maxSpace: 1024 * 100)
        XCTAssertEqual(plan.upToXGBStorageDescription, String(format: CoreString_V5._new_plans_details_up_to_storage, "100 KB"))
    }
    
    func testUpToXGBStorageDescription2() {
        let plan = Plan.empty.updated(maxSpace: 1024 * 1024 * 500)
        XCTAssertEqual(plan.upToXGBStorageDescription, String(format: CoreString_V5._new_plans_details_up_to_storage, "500 MB"))
    }
    
    func testUpToXGBStorageDescription3() {
        let plan = Plan.empty.updated(maxSpace: 1024 * 1024 * 1024)
        XCTAssertEqual(plan.upToXGBStorageDescription, String(format: CoreString_V5._new_plans_details_up_to_storage, "2 GB"))
    }
    
    // MARK: VCustomEmailDomainDescription tests
    func testVCustomEmailDomainDescription() {
        let plan = Plan.empty.updated(maxDomains: 88)
        XCTAssertEqual(plan.VCustomEmailDomainDescription, String(format: CoreString_V5._new_plans_details_n_custom_email_domains, 88))
    }

    // MARK: ZPersonalCalendarsDescription tests
    func testZPersonalCalendarsDescription() {
        let plan = Plan.empty.updated(maxCalendars: 30)
        XCTAssertEqual(plan.ZPersonalCalendarsDescription, String(format: CoreString_V5._new_plans_details_n_personal_calendars, 30))
    }

    // MARK: VPNUDevicesDescription tests
    func testVPNUDevicesDescription() {
        let plan = Plan.empty.updated(maxVPN: 55)
        XCTAssertEqual(plan.VPNUDevicesDescription, String(format: CoreString_V5._new_plans_details_vpn_on_n_devices, 55))
    }
    
    // MARK: VPNServersDescription tests
    func testVPNServersDescription1() {
        let plan = Plan.empty
        XCTAssertEqual(plan.VPNServersDescription(countries: 100), String(format: CoreString_V5._new_plans_details_vpn_servers, 1500, 100))
    }
    
    func testVPNServersDescription2() {
        let plan = Plan.empty
        XCTAssertEqual(plan.VPNServersDescription(countries: nil), String(format: CoreString_V5._new_plans_details_vpn_servers, 1500, 63))
    }
    
    // MARK: VPNFreeServersDescription tests
    func testVPNFreeServersDescription1() {
        let plan = Plan.empty
        XCTAssertEqual(plan.VPNFreeServersDescription(countries: 123), String(format: CoreString_V5._new_plans_details_vpn_free_servers, 24, 123))
    }
    
    func testVPNFreeServersDescription2() {
        let plan = Plan.empty
        XCTAssertEqual(plan.VPNFreeServersDescription(countries: nil), String(format: CoreString_V5._new_plans_details_vpn_free_servers, 24, 3))
    }
    
    // MARK: VPNFreeSpeedDescription tests
    func testVPNFreeSpeedDescription() {
        let plan = Plan.empty.updated(maxVPN: 11)
        XCTAssertEqual(plan.VPNFreeSpeedDescription, String(format: CoreString_V5._new_plans_details_vpn_free_speed_n_connections, 11))
    }
    
    // MARK: RSGBUsedStorageSpaceDescription tests
    func testRSGBUsedStorageSpaceDescription1() {
        let plan = Plan.empty.updated(maxSpace: 524288000)
        XCTAssertEqual(plan.RSGBUsedStorageSpaceDescription(usedSpace: 524288000), String(format: CoreString_V5._new_plans_details_used_storage_space, "500 MB", "500 MB"))
    }

    func testRSGBUsedStorageSpaceDescription2() {
        let plan = Plan.empty.updated(maxSpace: 1073741824)
        XCTAssertEqual(plan.RSGBUsedStorageSpaceDescription(usedSpace: 524288000), String(format: CoreString_V5._new_plans_details_used_storage_space, "500 MB", "1 GB"))
    }
    
    // MARK: TWUsersDescription tests
    func testTWUsersDescription1() {
        let plan = Plan.empty.updated(maxMembers: 1)
        XCTAssertEqual(plan.TWUsersDescription(usedMembers: 1), String(format: CoreString._pu_plan_details_n_users, 1))
    }
    
    func testTWUsersDescription2() {
        let plan = Plan.empty.updated(maxMembers: 10)
        XCTAssertEqual(plan.TWUsersDescription(usedMembers: 3), String(format: CoreString_V5._new_plans_details_n_of_m_users, 3, 10))
    }

    // MARK: PYAddressesDescription
    func testPYAddressesDescription1() {
        let plan = Plan.empty.updated(maxAddresses: 1)
        XCTAssertEqual(plan.PYAddressesDescription(usedAddresses: 1), String(format: CoreString._pu_plan_details_n_addresses, 1))
    }
    
    func testPYAddressesDescription2() {
        let plan = Plan.empty.updated(maxAddresses: 1)
        XCTAssertEqual(plan.PYAddressesDescription(usedAddresses: 0), String(format: CoreString._pu_plan_details_n_addresses, 1))
    }
    
    func testPYAddressesDescription3() {
        let plan = Plan.empty.updated(maxAddresses: 88)
        XCTAssertEqual(plan.PYAddressesDescription(usedAddresses: 23), String(format: CoreString_V5._new_plans_details_n_of_m_addresses, 23, 88))
    }

    // MARK: QZPersonalCalendarsDescription
    func testQZPersonalCalendarsDescription1() {
        let plan = Plan.empty.updated(maxCalendars: 1)
        XCTAssertEqual(plan.QZPersonalCalendarsDescription(usedCalendars: 1), String(format: CoreString_V5._new_plans_details_n_personal_calendars, 1))
    }
    
    func testQZPersonalCalendarsDescription2() {
        let plan = Plan.empty.updated(maxCalendars: 99)
        XCTAssertEqual(plan.QZPersonalCalendarsDescription(usedCalendars: 33), String(format: CoreString_V5._new_plans_details_n_of_m_personal_calendars, 33, 99))
    }
    
    // MARK: YAddressesPerUserDescriptionV5
    func testYAddressesPerUserDescriptionV5_1() {
        let plan = Plan.empty.updated(maxAddresses: 77, maxMembers: 0)
        XCTAssertEqual(plan.YAddressesPerUserDescriptionV5, String(format: CoreString_V5._new_plans_details_n_addresses_per_user, 77))
    }
    
    func testYAddressesPerUserDescriptionV5_2() {
        let plan = Plan.empty.updated(maxAddresses: 200, maxMembers: 10)
        XCTAssertEqual(plan.YAddressesPerUserDescriptionV5, String(format: CoreString_V5._new_plans_details_n_addresses_per_user, 200 / 10))
    }
    
    // MARK: ZPersonalCalendarsPerUserDescription
    func testZPersonalCalendarsPerUserDescription() {
        let plan = Plan.empty.updated(maxCalendars: 69)
        XCTAssertEqual(plan.ZPersonalCalendarsPerUserDescription, String(format: CoreString_V5._new_plans_details_n_personal_calendars_per_user, 69))
    }
    
    // MARK: UConnectionsPerUserDescription
    func testUConnectionsPerUserDescription1() {
        let plan = Plan.empty.updated(maxMembers: 0, maxVPN: 80)
        XCTAssertEqual(plan.UConnectionsPerUserDescription, String(format: CoreString_V5._new_plans_details_n_connections_per_user, 80))
    }
    
    func testUConnectionsPerUserDescription2() {
        let plan = Plan.empty.updated(maxMembers: 10, maxVPN: 80)
        XCTAssertEqual(plan.UConnectionsPerUserDescription, String(format: CoreString_V5._new_plans_details_n_connections_per_user, 80 / 10))
    }
    
    // MARK: vpnPaidCountriesDescriptionV5
    func vpnPaidCountriesDescriptionV5_2() {
        let plan = Plan.empty
        XCTAssertEqual(plan.vpnPaidCountriesDescriptionV5(countries: 123), String(format: CoreString._pu_plan_details_countries, 123))
    }
    
    func vpnPaidCountriesDescriptionV5_1() {
        let plan = Plan.empty
        XCTAssertEqual(plan.vpnPaidCountriesDescriptionV5(countries: nil), String(format: CoreString._pu_plan_details_countries, 63))
    }
}
