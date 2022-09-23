//
//  CurrentPlanDetailsTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 23/08/2022.
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
import ProtonCore_DataModel
import ProtonCore_TestingToolkit
@testable import ProtonCore_Payments
@testable import ProtonCore_PaymentsUI

final class CurrentPlanDetailsTests: XCTestCase {

    var servicePlan: ServicePlanDataServiceMock!
    var storeKitManager: StoreKitManagerMock!
    
    override func setUp() {
        super.setUp()
        servicePlan = ServicePlanDataServiceMock()
        storeKitManager = StoreKitManagerMock()
    }
    
    func testCurrentPlanUsedSpaceMaxSpace() {
        let plan = Plan(name: "free", iD: "", maxAddresses: 5, maxMembers: 6, pricing: nil, maxDomains: 7, maxSpace: 5368709120, maxRewardsSpace: 5368709120, type: 0, title: "", maxVPN: 7, maxTier: 9, features: 0, maxCalendars: nil, state: nil, cycle: nil)
        
        let inAppPurchasePlan: InAppPurchasePlan! = InAppPurchasePlan(protonName: "free", listOfIAPIdentifiers: [])
        
        let testUser = User(ID: "12345", name: "test", usedSpace: 3072, currency: "CHF", credit: 12300, maxSpace: 1073741824, maxUpload: 100000, role: 0, private: 1, subscribed: 0, services: 0, delinquent: 0, orgPrivateKey: nil, email: "test@user.ch", displayName: "test", keys: [])
        
        servicePlan.userStub.fixture = testUser
        
        var subscription = Subscription(start: nil, end: nil, planDetails: nil, amount: nil, currency: nil)
        let organization = Organization(maxDomains: 0, maxAddresses: 0, maxSpace: 100, maxMembers: 0, maxVPN: 0, maxCalendars: 0, usedDomains: 0, usedAddresses: 0, usedSpace: 0, usedMembers: 0, usedCalendars: 0)
        
        subscription.organization = organization
        servicePlan.currentSubscriptionStub.fixture = subscription
        
        let currentPlan = CurrentPlanDetails.createPlan(from: plan, plan: inAppPurchasePlan, servicePlan: servicePlan, countriesCount: nil, clientApp: .mail, storeKitManager: storeKitManager, isMultiUser: false, protonPrice: nil, hasPaymentMethods: false, endDate: NSAttributedString(string: ""))
        
        XCTAssertEqual(currentPlan.name, "Free")
        XCTAssert(currentPlan.usedSpaceDescription!.contains("3 KB of 1 GB"))
        XCTAssertEqual(currentPlan.usedSpace, 3072)
        XCTAssertEqual(currentPlan.maxSpace, 1073741824)
    }
}
