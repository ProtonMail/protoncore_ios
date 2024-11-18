//
//  AccountPlan+ExtensionsTests.swift
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
import ProtonCorePayments
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCorePaymentsUI

final class AccountPlanExtensionsTests: XCTestCase {

    func testPlanPriceIsReturned() {
        let storeMock = StoreKitManagerMock()
        storeMock.priceLabelForProductStub.bodyIs { _, name in (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs")) }
        let out = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let price = out.planPrice(from: storeMock)
        XCTAssertEqual(price, "$60.00")
    }

    func testPlanPriceIsNilBecausePlanHasNoIAPId() {
        let storeMock = StoreKitManagerMock()
        storeMock.priceLabelForProductStub.bodyIs { _, name in (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs")) }
        let out = InAppPurchasePlan(protonPlan: .dummy.updated(name: "test"), listOfIAPIdentifiers: [])!
        let price = out.planPrice(from: storeMock)
        XCTAssertNil(price)
    }

    func testPlanPriceIsNilBecauseStoreKitReturnsNoPrice() {
        let storeMock = StoreKitManagerMock()
        storeMock.priceLabelForProductStub.bodyIs { _, _ in nil }
        let out = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let price = out.planPrice(from: storeMock)
        XCTAssertNil(price)
    }
}

#endif
