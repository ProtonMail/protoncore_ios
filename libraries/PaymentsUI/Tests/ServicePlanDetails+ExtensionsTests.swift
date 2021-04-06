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
@testable import ProtonCore_PaymentsUI
@testable import ProtonCore_Payments

class ServicePlanDetailsExtensionsTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()

    }
    
    // MARK: nameDescription tests
    
    func testName() {
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "name", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.nameDescription, "Name")
    }
    
    func testNameAbc() {
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "name abc", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.nameDescription, "Name abc")
    }
    
    func testNameEmpty() {
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.nameDescription, "")
    }
    
    // MARK: usersDescription tests
    
    func testUsersDescription1() {
        let maxMembers = 1
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: maxMembers, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.usersDescription, String(format: CoreString._pu_plan_details_n_user, maxMembers))
    }
    
    func testUsersDescription2() {
        let maxMembers = 2
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: maxMembers, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.usersDescription, String(format: CoreString._pu_plan_details_n_users, maxMembers))
    }
    
    func testUsersDescription10() {
        let maxMembers = 10
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: maxMembers, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.usersDescription, String(format: CoreString._pu_plan_details_n_users, maxMembers))
    }
    
    func testUsersDescription0() {
        let maxMembers = 0
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: maxMembers, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.usersDescription, String(format: CoreString._pu_plan_details_n_users, maxMembers))
    }
    
    // MARK: storageDescription tests
    
    func testStorageDescriptionFree512kB() {
        let name = "free"
        let maxSpace: Int64 = 524288
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: maxSpace, maxVPN: 1, name: name, quantity: 1, services: 1, title: "title", type: 1)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        XCTAssertEqual(details.storageDescription, String(format: CoreString._pu_plan_details_free_storage, formatter.string(fromByteCount: Int64(maxSpace))))
    }
    
    func testStorageDescriptionFree1MB() {
        let name = "free"
        let maxSpace: Int64 = 1048576
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: maxSpace, maxVPN: 1, name: name, quantity: 1, services: 1, title: "title", type: 1)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        XCTAssertEqual(details.storageDescription, String(format: CoreString._pu_plan_details_free_storage, formatter.string(fromByteCount: Int64(maxSpace))))
    }
    
    func testStorageDescriptionFree2_5MB() {
        let name = "free"
        let maxSpace: Int64 = 2621440
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: maxSpace, maxVPN: 1, name: name, quantity: 1, services: 1, title: "title", type: 1)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        XCTAssertEqual(details.storageDescription, String(format: CoreString._pu_plan_details_free_storage, formatter.string(fromByteCount: Int64(maxSpace))))
    }
    
    func testStorageDescriptionFree100MB() {
        let name = "free"
        let maxSpace: Int64 = 104857600
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: maxSpace, maxVPN: 1, name: name, quantity: 1, services: 1, title: "title", type: 1)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        XCTAssertEqual(details.storageDescription, String(format: CoreString._pu_plan_details_free_storage, formatter.string(fromByteCount: Int64(maxSpace))))
    }
    
    func testStorageDescriptionFree10MB() {
        let name = "other"
        let maxSpace: Int64 = 10485760
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: maxSpace, maxVPN: 1, name: name, quantity: 1, services: 1, title: "title", type: 1)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        XCTAssertEqual(details.storageDescription, String(format: CoreString._pu_plan_details_storage, formatter.string(fromByteCount: Int64(maxSpace))))
    }
    
    func testStorageDescriptionFree1GB() {
        let name = "other"
        let maxSpace: Int64 = 1073741824
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: maxSpace, maxVPN: 1, name: name, quantity: 1, services: 1, title: "title", type: 1)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        XCTAssertEqual(details.storageDescription, String(format: CoreString._pu_plan_details_storage, formatter.string(fromByteCount: Int64(maxSpace))))
    }
    
    // MARK: addressesDescription tests
    
    func testAdressesDescription1() {
        let maxAddresses = 1
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.addressesDescription, String(format: CoreString._pu_plan_details_n_address, maxAddresses))
    }
    
    func testAdressesDescription3() {
        let maxAddresses = 3
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: maxAddresses, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.addressesDescription, String(format: CoreString._pu_plan_details_n_addresses, maxAddresses))
    }
    
    func testAdressesDescription9() {
        let maxAddresses = 9
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: maxAddresses, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.addressesDescription, String(format: CoreString._pu_plan_details_n_addresses, maxAddresses))
    }
    
    func testAdressesDescription0() {
        let maxAddresses = 0
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: maxAddresses, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: "", quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.addressesDescription, String(format: CoreString._pu_plan_details_n_addresses, maxAddresses))
    }

    // MARK: additionalDescription tests
    
    func testadditionalDescriptionFree() {
        let plan = AccountPlan.free
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [])
    }
    
    func testadditionalDescriptionMailPlus() {
        let plan = AccountPlan.mailPlus
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [CoreString._pu_plan_details_unlimited_data, CoreString._pu_plan_details_custom_email])
    }
    
    func testadditionalDescriptionVpnBasic() {
        let plan = AccountPlan.vpnBasic
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [])
    }
    
    func testadditionalDescriptionVpnPlus() {
        let plan = AccountPlan.vpnPlus
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [])
    }
    
    func testadditionalDescriptionPro() {
        let plan = AccountPlan.pro
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [CoreString._pu_plan_details_unlimited_data, CoreString._pu_plan_details_custom_email])
    }
    
    func testadditionalDescriptionVisionary() {
        let plan = AccountPlan.visionary
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [CoreString._pu_plan_details_unlimited_data, CoreString._pu_plan_details_custom_email])
    }
    
    func testadditionalDescriptionTrial() {
        let plan = AccountPlan.trial
        let details = ServicePlanDetails(features: 0, iD: "ID", maxAddresses: 1, maxDomains: 1, maxMembers: 1, maxSpace: 100, maxVPN: 1, name: plan.rawValue, quantity: 1, services: 1, title: "title", type: 1)
        XCTAssertEqual(details.additionalDescription, [])
    }
}
