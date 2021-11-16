//
//  ServicePlanDataService+ExtensionsTests.swift
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
import ProtonCore_TestingToolkit
import ProtonCore_Payments
@testable import ProtonCore_PaymentsUI

final class ServicePlanDataServiceExtensionsTests: XCTestCase {

    func testEndDateStringExpiredDate() {
        // simulate subscription with expired date
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: .distantPast)
        let end = out.endDateString(plan: plan)
        XCTAssertNil(end)
    }

    func testEndDateStringNoSubscription() {
        // simulate subscription with expired date
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        out.currentSubscriptionStub.fixture = nil
        let end = out.endDateString(plan: plan)
        XCTAssertNil(end)
    }

    func testEndDateStringSubscriptionNotRenewing() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate)
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString))
    }

    func testEndDateStringSubscriptionRenewingBecauseOfCoupon() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate, couponCode: "special")
        Subscription.specialCoupons.append("special")
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: CoreString._pu_plan_details_renew_auto_expired, endData.endDateString))
    }

    func testEndDateStringSubscriptionRenewingBecauseOfCredits() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.creditsStub.fixture = Credits(credit: 1000, currency: "USD")
        out.detailsOfServicePlanStub.bodyIs { _, _ in Plan.dummy.updated(pricing: ["12": 10]) }
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate)
        Subscription.specialCoupons.append("special")
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: CoreString._pu_plan_details_renew_auto_expired, endData.endDateString))
    }

    func testEndDateStringSubscriptionNotRenewingBecauseOfCredits() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.creditsStub.fixture = Credits(credit: 1000, currency: "USD")
        out.detailsOfServicePlanStub.bodyIs { _, _ in Plan.dummy.updated(pricing: ["12": 100001]) }
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate)
        Subscription.specialCoupons.append("special")
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString))
    }
}
