//
//  CurrentPlanPresentationTests.swift
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

#if os(iOS)

import XCTest

#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif

@testable import ProtonCorePaymentsUI
@testable import ProtonCorePayments

final class CurrentPlanPresentationTests: XCTestCase {
    var sut: CurrentPlanPresentation!
    
    func test_createCurrentPlan_success() {
        // Given
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        
        let subscription = CurrentPlan.Subscription(
            vendorName: "ioscore_core2023_testpromo_12_usd_non_renewing",
            title: "",
            description: "",
            cycleDescription: "",
            entitlements: []
        )
        
        // When
        sut = CurrentPlanPresentation.createCurrentPlan(
            from: subscription,
            storeKitManager: storeKitManager,
            price: "price"
        )
        
        // Then
        XCTAssertEqual(sut.currentPlan.storeKitProductId, "ioscore_core2023_testpromo_12_usd_non_renewing")
        XCTAssertEqual(sut.currentPlan.protonName, "core2023")
        XCTAssertEqual(sut.currentPlan.offer, "testpromo")
        XCTAssertEqual(sut.currentPlan.period, "12")
        XCTAssertEqual(sut.storeKitProductId, "ioscore_core2023_testpromo_12_usd_non_renewing")
    }
    
    func test_createCurrentPlan_failure() {
        // Given
        let subscription = CurrentPlan.Subscription(
            vendorName: "bad name",
            title: "",
            description: "",
            cycleDescription: "",
            entitlements: []
        )
        
        // When
        sut = CurrentPlanPresentation.createCurrentPlan(
            from: subscription,
            storeKitManager: StoreKitManagerMock(),
            price: "price"
        )
        
        // Then
        XCTAssertNil(sut)
    }
}

#endif
