//
//  PlansDataSourceTests.swift
//  ProtonCorePayments-Tests - Created on 28.07.23.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.

import XCTest
@testable import ProtonCorePayments

#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif

final class PlansDataSourceTests: XCTestCase {
    var sut: PlansDataSource!
    var apiServiceMock: APIServiceMock!
    var storeKitDataSourceMock: StoreKitDataSourceMock!
    var servicePlanDataStorageMock: ServicePlanDataStorageMock!

    override func setUp() {
        super.setUp()
        apiServiceMock = .init()
        storeKitDataSourceMock = .init()
        servicePlanDataStorageMock = .init()
        sut = .init(
            apiService: apiServiceMock,
            storeKitDataSource: storeKitDataSourceMock,
            localStorage: servicePlanDataStorageMock
        )
    }

    // MARK: - fetchIAPAvailability

    func test_fetchIAPAvailability_succeeds() async throws {
        // Given
        try await withFeatureFlags([.dynamicPlans]) {
            apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(["InApp": 1]))
            }

            // When
            try await sut.fetchIAPAvailability()

            // Then
            XCTAssertTrue(sut.isIAPAvailable)
        }
    }

    func test_fetchIAPAvailability_fails_onFalse() async throws {
        // Given
        try await withFeatureFlags([.dynamicPlans]) {
            apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(["InApp": 0]))
            }

            // When
            try await sut.fetchIAPAvailability()

            // Then
            XCTAssertFalse(sut.isIAPAvailable)
        }
    }

    func test_fetchIAPAvailability_fails_onBadJSON() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(["bad": "json"]))
        }

        // When
        try await sut.fetchIAPAvailability()

        // Then
        XCTAssertFalse(sut.isIAPAvailable)
    }

    func test_fetchIAPAvailability_throws() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.badResponse()))
        }

        // When
        do {
            try await sut.fetchIAPAvailability()
            XCTFail("should throw an error")
        } catch {
            // successfully thrown an error
        }
    }

    func test_isIAPAvailable_isTrueWhenSettingPaymentsBackendStatusAcceptsIAPToTrue() {
        // Given
        withFeatureFlags([.dynamicPlans]) {
            servicePlanDataStorageMock.paymentsBackendStatusAcceptsIAPStub.fixture = true
            sut = .init(
                apiService: apiServiceMock,
                storeKitDataSource: storeKitDataSourceMock,
                localStorage: servicePlanDataStorageMock
            )

            // Then
            XCTAssertTrue(sut.paymentsBackendStatusAcceptsIAP)
            XCTAssertTrue(sut.isIAPAvailable)
        }
    }

    func test_isIAPAvailable_isFalseWhenSettingPaymentsBackendStatusAcceptsIAPToFalse() {
        // Given
        withFeatureFlags([.dynamicPlans]) {
            servicePlanDataStorageMock.paymentsBackendStatusAcceptsIAPStub.fixture = false
            sut = .init(
                apiService: apiServiceMock,
                storeKitDataSource: storeKitDataSourceMock,
                localStorage: servicePlanDataStorageMock
            )

            // Then
            XCTAssertFalse(sut.paymentsBackendStatusAcceptsIAP)
            XCTAssertFalse(sut.isIAPAvailable)
        }
    }

    func test_isIAPAvailable_isFalseWhenCreditsAreAvailable() {
        // Given
        withFeatureFlags([.dynamicPlans]) {
            servicePlanDataStorageMock.paymentsBackendStatusAcceptsIAPStub.fixture = true
            servicePlanDataStorageMock.creditsStub.fixture = Credits(credit: 50, currency: "USD")
            sut = .init(
                apiService: apiServiceMock,
                storeKitDataSource: storeKitDataSourceMock,
                localStorage: servicePlanDataStorageMock
            )

            // Then
            XCTAssertFalse(sut.isIAPAvailable)
        }
    }
    // MARK: - fetchCurrentPlan

    func test_fetchCurrentPlan_succeeds() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(currentPlanResponse))
        }

        // When
        try await sut.fetchCurrentPlan()

        // Then
        XCTAssertEqual(sut.currentPlan, currentPlanToCompare)
    }

    func test_fetchCurrentPlan_fails() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success([:]))
        }

        // When
        try await sut.fetchCurrentPlan()

        // Then
        XCTAssertNil(sut.currentPlan)
    }

    func test_fetchCurrentPlan_throws() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.badResponse()))
        }

        // When
        do {
            try await sut.fetchCurrentPlan()
            XCTFail("should throw an error")
        } catch {
            // successfully thrown an error
        }
    }

    // MARK: - fetchAvailablePlans

    func test_fetchAvailablePlans_succeeds() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(availablePlansResponse))
        }
        storeKitDataSourceMock.filterAccordingToAvailableProductsStub.bodyIs { _, plans in
            plans
        }

        // When
        try await sut.fetchAvailablePlans()

        // Then
        XCTAssertEqual(sut.availablePlans, availablePlansToCompare)
        XCTAssertTrue(storeKitDataSourceMock.fetchAvailableProductsForPlansStub.wasCalledExactlyOnce)
        XCTAssertTrue(storeKitDataSourceMock.filterAccordingToAvailableProductsStub.wasCalledExactlyOnce)
    }

    func test_fetchAvailablePlans_success_filterPlans() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(availablePlansResponse))
        }
        storeKitDataSourceMock.filterAccordingToAvailableProductsStub.bodyIs { _, plans in
            AvailablePlans(plans: Array(plans.plans.dropFirst()))
        }
        let filteredPlansToCompare = AvailablePlans(plans: Array(availablePlansToCompare.plans.dropFirst()))

        // When
        try await sut.fetchAvailablePlans()

        // Then
        XCTAssertEqual(sut.availablePlans, filteredPlansToCompare)
        XCTAssertTrue(storeKitDataSourceMock.fetchAvailableProductsForPlansStub.wasCalledExactlyOnce)
        XCTAssertTrue(storeKitDataSourceMock.filterAccordingToAvailableProductsStub.wasCalledExactlyOnce)
    }

    func test_fetchAvailablePlans_fails() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success([:]))
        }

        // When
        try await sut.fetchAvailablePlans()

        // Then
        XCTAssertNil(sut.availablePlans)
        XCTAssertTrue(storeKitDataSourceMock.fetchAvailableProductsForPlansStub.wasNotCalled)
        XCTAssertTrue(storeKitDataSourceMock.filterAccordingToAvailableProductsStub.wasNotCalled)
    }

    func test_fetchAvailablePlans_throws() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.badResponse()))
        }

        // When
        do {
            try await sut.fetchAvailablePlans()
            XCTFail("should throw an error")
        } catch {
            XCTAssertTrue(storeKitDataSourceMock.fetchAvailableProductsForPlansStub.wasNotCalled)
            XCTAssertTrue(storeKitDataSourceMock.filterAccordingToAvailableProductsStub.wasNotCalled)
        }
    }

    // MARK: - fetchPaymentMethods

    func test_fetchPaymentMethods_succeeds() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(paymentMethodsResponse))
        }

        // When
        try await sut.fetchPaymentMethods()

        // Then
        XCTAssertEqual(sut.paymentMethods, paymentMethodsToCompare)
    }

    func test_fetchPaymentMethods_fails() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success([:]))
        }

        // When
        try await sut.fetchPaymentMethods()

        // Then
        XCTAssertNil(sut.paymentMethods)
    }

    func test_fetchPaymentMethods_throws() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.badResponse()))
        }

        // When
        do {
            try await sut.fetchPaymentMethods()
            XCTFail("should throw an error")
        } catch {
            // successfully thrown an error
        }
    }

    // MARK: - willRenewAutomatically

    func test_willRenewAutomatically_isTrue() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(currentPlanResponse))
        }

        // When
        try await sut.fetchCurrentPlan()

        // Then
        XCTAssertTrue(sut.willRenewAutomatically)
    }

    func test_willRenewAutomatically_isFalse() async throws {
        // Given
        apiServiceMock.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success([:]))
        }

        // When
        try await sut.fetchCurrentPlan()

        // Then
        XCTAssertFalse(sut.willRenewAutomatically)
    }
}
