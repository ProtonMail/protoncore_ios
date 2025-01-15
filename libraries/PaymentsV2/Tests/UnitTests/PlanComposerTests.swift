//
//  PlanComposerTests.swift
//  ProtonCore-PaymentsV2Test - Created on 15/10/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

@testable import ProtonCorePaymentsV2
import StoreKitTest
import XCTest

final class PlansComposerTests: XCTestCase, @unchecked Sendable {

    private let productsIds = ["iosvpn_bundle2022_12_usd_auto_renewing", "iosvpn_vpn2022_1_usd_auto_renewing"]
    private var mockRemoteManager: MockedRemoteManager!

    var plansComposer: PlansComposer!

    override func setUp() {
        super.setUp()
        mockRemoteManager = MockedRemoteManager()
        guard let remoteManager = mockRemoteManager.remoteManager, let paymentsAPIs = mockRemoteManager.paymentsAPI else {
            XCTFail("MockRemoteManager returned nil remoteManager or paymentsAPIs")
            return
        }

        plansComposer = PlansComposer(remoteManager: remoteManager, paymentsAPIs: paymentsAPIs)
        let url = Bundle.module.url(forResource: "StoreKit_mock", withExtension: "storekit")!
        do {
            _ = try SKTestSession(contentsOf: url)
        } catch {
            debugPrint(error)
        }
    }

    override func tearDown() {
        super.tearDown()
        plansComposer = nil
    }

    func test_composedPlan_success() async throws {
        let mockResponse = Bundle.main.loadJsonDataToDic(from: "availablePlans.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        // Fetch Proton plans
        _ = try await plansComposer.fetchProtonPlans()
        _ = try await plansComposer.getStoreProducts(["iosvpn_bundle2022_12_usd_auto_renewing", "iosvpn_vpn2022_1_usd_auto_renewing"])

        let composedPlans = try await plansComposer.fetchAvailablePlans()
        XCTAssertNotNil(composedPlans)
        XCTAssertTrue(composedPlans.count == 3)
    }

    func test_composedPlan_match_individual_StoreKit_plan() async throws {
        let mockResponse = Bundle.main.loadJsonDataToDic(from: "availablePlans.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        // Fetch Proton plans
        _ = try await plansComposer.fetchProtonPlans()
        _ = try await plansComposer.getStoreProducts(productsIds)
        let composedPlan = plansComposer.matchPlanToStoreProduct("iosvpn_bundle2022_12_usd_auto_renewing")

        XCTAssertNotNil(composedPlan)
        XCTAssertEqual(composedPlan?.plan.title, "Proton Unlimited")
    }

    func test_composedPlan_equatable() async throws {
        let mockResponse = Bundle.main.loadJsonDataToDic(from: "availablePlans.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        // Fetch Proton plans
        _ = try await plansComposer.fetchProtonPlans()
        _ = try await plansComposer.getStoreProducts(productsIds)

        let composedPlan = plansComposer.matchPlanToStoreProduct("iosvpn_bundle2022_12_usd_auto_renewing")
        let composedPlan2 = plansComposer.matchPlanToStoreProduct("iosvpn_bundle2022_12_usd_auto_renewing")

        XCTAssertEqual(composedPlan, composedPlan2)
    }

    func test_fetch_current_subscription() async throws {
        let mockResponse = Bundle.main.loadJsonDataToDic(from: "current_sub_response.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let currentSubscription = try await plansComposer.fetchCurrentSubscription()

        XCTAssertEqual(currentSubscription.name, "mail2022+drivepro2022")
        XCTAssertEqual(currentSubscription.description, "Current plan")
    }
}
