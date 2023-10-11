//
//  AvailablePlansPresentationTests.swift
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

final class AvailablePlansPresentationTests: XCTestCase {
    var sut: AvailablePlansPresentation!
    
    func test_createAvailablePlans_success() async throws {
        // Given
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        let plansDataSource = PlansDataSourceMock()
        
        let instance = AvailablePlans.AvailablePlan.Instance(
            cycle: 1,
            description: "description",
            periodEnd: 1755445843,
            price: [.init(ID: "id", current: 19176, currency: "USD")],
            vendors: .init(apple: .init(productID: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        )
        
        let plan = AvailablePlans.AvailablePlan(
            ID: "ID",
            type: 1,
            name: "name",
            title: "title",
            description: "description",
            instances: [instance],
            entitlements: [],
            decorations: []
        )

        // When
        sut = try await AvailablePlansPresentation.createAvailablePlans(
            from: plan,
            for: instance,
            defaultCycle: 12,
            plansDataSource: plansDataSource,
            storeKitManager: storeKitManager
        )
        
        // Then
        XCTAssertFalse(sut.details.isFreePlan)
        XCTAssertEqual(sut.details.defaultCycle, 12)
        XCTAssertEqual(sut.availablePlan?.storeKitProductId, "ioscore_core2023_testpromo_12_usd_non_renewing")
        XCTAssertEqual(sut.availablePlan?.protonName, "core2023")
        XCTAssertEqual(sut.availablePlan?.offer, "testpromo")
        XCTAssertEqual(sut.availablePlan?.period, "12")
        XCTAssertEqual(sut.storeKitProductId, "ioscore_core2023_testpromo_12_usd_non_renewing")
        XCTAssertFalse(sut.isCurrentlyProcessed)
        XCTAssertFalse(sut.isExpanded)
    }
    
    func test_createAvailablePlans_failure() async throws {
        // Given
        let instance = AvailablePlans.AvailablePlan.Instance(
            cycle: 1,
            description: "description",
            periodEnd: 1755445843,
            price: [.init(ID: "id", current: 19176, currency: "USD")],
            vendors: .init(apple: .init(productID: "bad id"))
        )
        
        let plan = AvailablePlans.AvailablePlan(
            ID: "ID",
            type: nil,
            name: "name",
            title: "title",
            description: "description",
            instances: [instance],
            entitlements: [],
            decorations: []
        )
        
        // When
        sut = try await AvailablePlansPresentation.createAvailablePlans(
            from: plan,
            for: instance,
            plansDataSource: PlansDataSourceMock(),
            storeKitManager: StoreKitManagerMock()
        )
        
        // Then
        XCTAssertNil(sut)
    }
    
    func test_createFreePlan() async throws {
        // Given
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        let plansDataSource = PlansDataSourceMock()
        
        let instance = AvailablePlans.AvailablePlan.Instance(
            cycle: 1,
            description: "description",
            periodEnd: 1755445843,
            price: [.init(ID: "id", current: 19176, currency: "USD")],
            vendors: .init(apple: .init(productID: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        )
        
        let plan = AvailablePlans.AvailablePlan(
            ID: "ID",
            type: nil,
            name: "name",
            title: "title",
            description: "description",
            instances: [instance],
            entitlements: [],
            decorations: []
        )

        // When
        sut = try await AvailablePlansPresentation.createAvailablePlans(
            from: plan,
            for: instance,
            defaultCycle: 12,
            plansDataSource: plansDataSource,
            storeKitManager: storeKitManager
        )
        
        // Then
        XCTAssertTrue(sut.details.isFreePlan)
    }
}

#endif
