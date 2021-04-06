//
//  AccountPlan+ExtensionsTests.swift
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
@testable import ProtonCore_PaymentsUI
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class AccountPlanExtensionsTests: XCTestCase {
    
    let storeKitManager = StoreKitManager.default
    
    func setup(plan: [AccountPlan]? = nil, locale: Locale = Locale(identifier: "en_US@currency=USDs"), prices: [String: String]? = nil) {
        guard let plan = plan else {
            storeKitManager.request = SKRequestMock(productIdentifiers: Set([]))
            storeKitManager.updateAvailableProductsList()
            return
        }
        let requestMock = SKRequestMock(productIdentifiers: Set(plan.map { $0.storeKitProductId! }))
        if let prices = prices {
            requestMock.setupPrices(locale: locale, prices: prices)
        }
        storeKitManager.request = requestMock
        storeKitManager.updateAvailableProductsList()
    }
    
    // MARK: MailPlus plan setup
    
    func testFreePlanPrice() {
        setup()
        for plan in AccountPlan.allCases {
            XCTAssertNil(plan.planPrice)
        }
    }

    func testMailPlusPlanPrice() {
        let planToTest: AccountPlan = .mailPlus
        setup(plan: [planToTest], prices: [ AccountPlan.mailPlus.storeKitProductId!: "60"])
        for plan in AccountPlan.allCases {
            if plan == planToTest {
                XCTAssertEqual(plan.planPrice, "$60.00")
            } else {
                XCTAssertNil(plan.planPrice)
            }
        }
    }
    
    func testMailPlusLocalePlanPrice() {
        let planToTest: AccountPlan = .mailPlus
        let locale = Locale(identifier: "rm_CH")
        setup(plan: [planToTest], locale: locale, prices: [ AccountPlan.mailPlus.storeKitProductId!: "60"])
        for plan in AccountPlan.allCases {
            if plan == planToTest {
                XCTAssertEqual(plan.planPrice, "60.00 CHF")
            } else {
                XCTAssertNil(plan.planPrice)
            }
        }
    }
    
    func testVpnBasicPlusPlanPrice() {
        let planToTest1: AccountPlan = .vpnBasic
        let planToTest2: AccountPlan = .vpnPlus
        setup(plan: [planToTest1, planToTest2], prices: [ AccountPlan.vpnBasic.storeKitProductId!: "60", AccountPlan.vpnPlus.storeKitProductId!: "120"])
        for plan in AccountPlan.allCases {
            if plan == planToTest1 {
                XCTAssertEqual(plan.planPrice, "$60.00")
            } else if plan == planToTest2 {
                XCTAssertEqual(plan.planPrice, "$120.00")
            } else {
                XCTAssertNil(plan.planPrice)
            }
        }
    }

}
