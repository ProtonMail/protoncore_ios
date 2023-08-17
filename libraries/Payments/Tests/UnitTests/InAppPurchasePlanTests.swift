//
//  InAppPurchasePlanTests.swift
//  ProtonCorePaymentsTests - Created on 13.07.23.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
@testable import ProtonCorePayments

final class InAppPurchasePlanTests: XCTestCase {
    var sut: InAppPurchasePlan!
    
    func test_init_with_availablePlanInstance() {
        // Given
        let instance = AvailablePlans.AvailablePlan.Instance(
            month: 12,
            ID: "id",
            description: "description",
            periodEnd: 1,
            price: [],
            vendors: .init(
                google: .init(
                    ID: "bla",
                    customerID: "bla"
                ),
                apple: .init(
                    ID: "ioscore_core2023_12_usd_non_renewing",
                    customerID: "bla"
                )
            )
        )
        
        // When
        sut = .init(availablePlanInstance: instance)
        
        // Then
        XCTAssertEqual(sut.storeKitProductId, "ioscore_core2023_12_usd_non_renewing")
        XCTAssertEqual(sut.protonName, "core2023")
        XCTAssertNil(sut.offer)
        XCTAssertEqual(sut.period, "12")
    }

    func test_init_with_currentPlanSubscription() {
        // Given
        let subscription = CurrentPlan.Subscription(name: "core2023",
            description: "",
            ID: "",
            parentMetaPlanID: "",
            type: 1,
            title: "",
            cycle: 12,
            cycleDescription: "",
            currency: "usd",
            amount: 1,
            offer: "",
            quantity: 1,
            periodStart: 1,
            periodEnd: 1,
            createTime: 1,
            discount: 1,
            renewDiscount: 1,
            renewAmount: 1,
            renew: 1,
            external: 1,
            entitlements: [],
            decorations: []
        )
        
        // When
        sut = .init(currentPlanSubscription: subscription)
        
        // Then
        XCTAssertEqual(sut.storeKitProductId, "ioscore_core2023_12_usd_non_renewing")
        XCTAssertEqual(sut.protonName, "core2023")
        XCTAssertNil(sut.offer)
        XCTAssertEqual(sut.period, "12")
    }
}
