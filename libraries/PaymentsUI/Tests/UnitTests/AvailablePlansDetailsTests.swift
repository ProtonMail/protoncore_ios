//
//  AvailablePlansDetailsTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 31.08.23.
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

final class AvailablePlansDetailsTests: XCTestCase {
    
    // TODO: CP-6480
//    func test_createPlan_callsFetchIcon() async throws {
//        // Given
//        let plansDataSource = PlansDataSourceMock()
//        let availablePlan = AvailablePlans.AvailablePlan(
//            name: "name",
//            title: "title",
//            instances: [],
//            entitlements: [
//                .description(.init(type: "description", iconName: "tick", text: "text"))
//            ],
//            decorations: []
//        )
//
//        // When
//        _ = try await AvailablePlansDetails.createPlan(from: availablePlan, plansDataSource: plansDataSource)
//
//        // Then
//        XCTAssertTrue(plansDataSource.fetchIconStub.wasCalled)
//    }
    
    func test_createPlan_withStoreKitManagerAndInstance() async throws {
        // Given
        let iapPlan = InAppPurchasePlan(storeKitProductId: "ioscore_core2023_12_usd_non_renewing")
        let plansDataSource = PlansDataSourceMock()
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        
        let availablePlan = AvailablePlans.AvailablePlan(
            ID: "ID",
            name: "name",
            title: "title",
            description: "description",
            instances: [
                .init(ID: "ID",
                      cycle: 1,
                      description: "12 months",
                      periodEnd: 123,
                      price: [
                        .init(current: 123, default: 123, currency: "USD")
                      ],
                      vendors: .init(apple: .init(productID: "ioscore_core2023_12_usd_non_renewing")
                ))
            ],
            entitlements: [
                .description(.init(type: "description", iconName: "tick", text: "text"))
            ],
            decorations: []
        )
        
        // When
        let plan = try await AvailablePlansDetails.createPlan(
            from: availablePlan,
            for: availablePlan.instances[0],
            iapPlan: iapPlan,
            plansDataSource: plansDataSource,
            storeKitManager: storeKitManager
        )
        
        // Then
        XCTAssertEqual(plan?.cycleDescription, "12 months")
        XCTAssertEqual(plan?.title, "title")
        XCTAssertEqual(plan?.iapID, "ioscore_core2023_12_usd_non_renewing")
        XCTAssertEqual(plan?.description, "description")
        XCTAssertEqual(plan?.price, "$60.00")
        XCTAssertEqual(plan?.decorations.isEmpty, true)
        XCTAssertEqual(plan?.entitlements[0], .init(text: "text", icon: nil))
    }
    
    func test_createPlan_withoutStoreKitManagerNorInstance() async throws {
        // Given
        let plansDataSource = PlansDataSourceMock()
        let availablePlan = AvailablePlans.AvailablePlan(
            ID: "ID",
            name: "name",
            title: "title",
            instances: [],
            entitlements: [
                .description(.init(type: "description", iconName: "tick", text: "text"))
            ],
            decorations: []
        )
        
        // When
        let plan = try await AvailablePlansDetails.createPlan(from: availablePlan, plansDataSource: plansDataSource)
        
        // Then
        XCTAssertNil(plan?.cycleDescription)
        XCTAssertEqual(plan?.title, "title")
        XCTAssertNil(plan?.iapID)
        XCTAssertNil(plan?.description)
        XCTAssertEqual(plan?.price, "$0")
        XCTAssertEqual(plan?.decorations.isEmpty, true)
        XCTAssertEqual(plan?.entitlements[0], .init(text: "text", icon: nil))
    }

}

#endif
