//
//  ServicePlanDataService+ExtensionsTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
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

#if os(iOS)

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCorePayments
@testable import ProtonCorePaymentsUI

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
        XCTAssertEqual(end?.string, String(format: PUITranslations.plan_details_renew_expired.l10n, endData.endDateString))
    }

    func testEndDateStringSubscriptionRenewingBecauseOfCoupon() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate, couponCode: "special")
        Subscription.specialCoupons.append("special")
        out.willRenewAutomaticallyStub.bodyIs { _, _ in true }
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: PUITranslations.plan_details_renew_auto_expired.l10n, endData.endDateString))
    }
    
    func testEndDateStringSubscriptionRenewingBecauseOfCredits() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.creditsStub.fixture = Credits(credit: 1000, currency: "USD")
        out.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in Plan.dummy.updated(pricing: ["12": 10]) }
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate)
        out.willRenewAutomaticallyStub.bodyIs { _, _ in true }
        Subscription.specialCoupons.append("special")
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: PUITranslations.plan_details_renew_auto_expired.l10n, endData.endDateString))
    }

    func testEndDateStringSubscriptionNotRenewingBecauseOfCredits() {
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = ServicePlanDataServiceMock()
        let endData = PlansData.getEndDate(component: .year, value: 1)
        out.creditsStub.fixture = Credits(credit: 1000, currency: "USD")
        out.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in Plan.dummy.updated(pricing: ["12": 100001]) }
        out.currentSubscriptionStub.fixture = Subscription.dummy.updated(end: endData.endDate)
        Subscription.specialCoupons.append("special")
        let end = out.endDateString(plan: plan)
        XCTAssertEqual(end?.string, String(format: PUITranslations.plan_details_renew_expired.l10n, endData.endDateString))
    }
}

#endif
