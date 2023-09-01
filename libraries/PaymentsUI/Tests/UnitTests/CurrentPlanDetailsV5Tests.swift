//
//  CurrentPlanDetailsV5Tests.swift
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
@testable import ProtonCorePayments
@testable import ProtonCorePaymentsUI

#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif


final class CurrentPlanDetailsV5Tests: XCTestCase {
    var plansDataSource: PlansDataSourceMock!
    
    override func setUp() {
        super.setUp()
        plansDataSource = .init()
    }
    
    // TODO: CP-6480
//    func test_createPlan_callsFetchIcon() async throws {
//        // Given
//        let subscription = CurrentPlan.Subscription(
//            title: "title",
//            description: "description",
//            cycleDescription: "cycleDescription",
//            entitlements: [.description(.init(type: "description", text: "text", iconName: "tick"))]
//        )
//
//        // When
//        let plan = try await CurrentPlanDetailsV5.createPlan(from: subscription, plansDataSource: plansDataSource)
//
//        // Then
//        XCTAssertTrue(plansDataSource.fetchIconStub.wasCalled)
//    }
//
    func test_createPlan() async throws {
        // Given
        let subscription = CurrentPlan.Subscription(
            title: "title",
            description: "description",
            cycleDescription: "cycleDescription",
            entitlements: [.description(.init(type: "description", text: "text", iconName: "tick"))]
        )
        
        // When
        let plan = try await CurrentPlanDetailsV5.createPlan(from: subscription, plansDataSource: plansDataSource)
        
        // Then
        XCTAssertEqual(plan.cycleDescription, "cycleDescription")
        XCTAssertEqual(plan.title, "title")
        XCTAssertEqual(plan.description, "description")
        XCTAssertEqual(plan.price, "$0")
        XCTAssertNil(plan.endDate)
        XCTAssertEqual(plan.entitlements, [.description(.init(text: "text"))])
        
    }
}

#endif
