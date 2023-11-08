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

    func test_createCurrentPlan_free_success() async throws {
        // Given
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        let plansDataSource = PlansDataSourceMock()

        let subscription = CurrentPlan.Subscription(
            title: "title",
            description: "description",
            cycleDescription: "cycleDescription",
            entitlements: []
        )

        // When
        sut = try await CurrentPlanPresentation.createCurrentPlan(from: subscription, plansDataSource: plansDataSource)

        // Then
        XCTAssertEqual(sut.details.title, "title")
        XCTAssertEqual(sut.details.description, "description")
        XCTAssertEqual(sut.details.cycleDescription, "cycleDescription")
        XCTAssertEqual(sut.details.price, "Free")
        XCTAssertNil(sut.details.endDate)
        XCTAssertTrue(sut.details.entitlements.isEmpty)
        XCTAssertFalse(sut.details.hidePriceDetails)
    }

    func test_createCurrentPlan_paidOnWeb_success() async throws {
        // Given
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        let plansDataSource = PlansDataSourceMock()

        let subscription = CurrentPlan.Subscription(
            title: "title",
            description: "description",
            cycleDescription: "cycleDescription",
            currency: "USD",
            amount: 123,
            external: .web,
            entitlements: []
        )

        // When
        sut = try await CurrentPlanPresentation.createCurrentPlan(from: subscription, plansDataSource: plansDataSource)

        // Then
        XCTAssertEqual(sut.details.title, "title")
        XCTAssertEqual(sut.details.description, "description")
        XCTAssertEqual(sut.details.cycleDescription, "cycleDescription")
        XCTAssertEqual(sut.details.price, "$1.23")
        XCTAssertNil(sut.details.endDate)
        XCTAssertTrue(sut.details.entitlements.isEmpty)
        XCTAssertFalse(sut.details.hidePriceDetails)
    }

    func test_createCurrentPlan_paidOnAppStore_success() async throws {
        // Given
        let storeKitManager = StoreKitManagerMock()
        storeKitManager.priceLabelForProductStub.bodyIs { _, _ in
            (NSDecimalNumber(value: 60.0), Locale(identifier: "en_US@currency=USDs"))
        }
        let plansDataSource = PlansDataSourceMock()

        let subscription = CurrentPlan.Subscription(
            title: "title",
            description: "description",
            cycleDescription: "cycleDescription",
            currency: "USD",
            amount: 123,
            external: .apple,
            entitlements: []
        )

        // When
        sut = try await CurrentPlanPresentation.createCurrentPlan(from: subscription, plansDataSource: plansDataSource)

        // Then
        XCTAssertEqual(sut.details.title, "title")
        XCTAssertEqual(sut.details.description, "description")
        XCTAssertEqual(sut.details.cycleDescription, "cycleDescription")
        XCTAssertEqual(sut.details.price, "")
        XCTAssertNil(sut.details.endDate)
        XCTAssertTrue(sut.details.entitlements.isEmpty)
        XCTAssertTrue(sut.details.hidePriceDetails)
    }
}

#endif
