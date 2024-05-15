//
//  PaymentsTests.swift
//  ProtonCore-Payments-Tests - Created on 07/09/2021.
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

import XCTest
import StoreKit
import ProtonCoreServices
import ProtonCoreNetworking
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCorePayments

final class PaymentsTests: XCTestCase {

    var storageMock: ServicePlanDataStorageMock!
    var storeKitManager: StoreKitManagerMock!
    var storeKitDelegate: StoreKitManagerDelegateMock!
    var apiService: APIServiceMock!
    var alertManagerMock: AlertManagerMock!
    var plansDataSourceMock: PlansDataSourceMock!

    override func setUp() {
        super.setUp()
        storageMock = ServicePlanDataStorageMock()
        storeKitManager = StoreKitManagerMock()
        storeKitDelegate = StoreKitManagerDelegateMock()
        apiService = APIServiceMock()
        alertManagerMock = AlertManagerMock()
        plansDataSourceMock = PlansDataSourceMock()
    }

    override func tearDown() {
        storageMock = nil
        storeKitManager = nil
        storeKitDelegate = nil
        apiService = nil
        alertManagerMock = nil
        plansDataSourceMock = nil
        super.tearDown()
    }

    @MainActor
    func testPaymentsActivation_StartObservingPaymentsQueue() async throws {
        await withFeatureFlags([.dynamicPlans]) {
            let payments = Payments(inAppPurchaseIdentifiers: [],
                                    apiService: apiService,
                                    localStorage: storageMock,
                                    alertManager: alertManagerMock,
                                    reportBugAlertHandler: { _ in })

            plansDataSourceMock.fetchAvailablePlansStub.bodyIs { _ in }
            payments.storeKitManager = storeKitManager

            payments.planService = .right(plansDataSourceMock)

            await payments.startObservingPaymentQueue(delegate: storeKitDelegate)

            XCTAssertTrue(storeKitManager.updateAvailableProductsListStub.wasNotCalled)
            XCTAssertTrue(storeKitManager.subscribeToPaymentQueueStub.wasCalledExactlyOnce)
            XCTAssertTrue(storeKitManager.delegateStub.setWasCalledExactlyOnce)
            XCTAssertIdentical(storeKitManager.delegateStub.setLastArguments?.value, storeKitDelegate)
        }
    }

    func testPaymentsActivation_WithoutDynamicPlans_Success() async throws {
        try await withFeatureFlags([]) {
            let payments = Payments(inAppPurchaseIdentifiers: [],
                                    apiService: apiService,
                                    localStorage: storageMock,
                                    alertManager: alertManagerMock,
                                    reportBugAlertHandler: { _ in })
            payments.storeKitManager = storeKitManager
            storeKitManager.updateAvailableProductsListStub.bodyIs { _, completion in
                completion(nil)
            }

            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                payments.activate(delegate: storeKitDelegate) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }

            XCTAssertTrue(storeKitManager.updateAvailableProductsListStub.wasCalledExactlyOnce)
            XCTAssertTrue(storeKitManager.subscribeToPaymentQueueStub.wasCalledExactlyOnce)
            XCTAssertTrue(storeKitManager.delegateStub.setWasCalledExactlyOnce)
            XCTAssertIdentical(storeKitManager.delegateStub.setLastArguments?.value, storeKitDelegate)
        }
    }

    func testPaymentsActivation_WithoutDynamicPlans_Failure() async throws {
        await withFeatureFlags([]) {
            let payments = Payments(inAppPurchaseIdentifiers: [],
                                    apiService: apiService,
                                    localStorage: storageMock,
                                    alertManager: alertManagerMock,
                                    reportBugAlertHandler: { _ in })
            payments.storeKitManager = storeKitManager
            enum TestError: Error, Comparable { case test }
            storeKitManager.updateAvailableProductsListStub.bodyIs { _, completion in
                completion(TestError.test)
            }

            do {
                _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    payments.activate(delegate: storeKitDelegate) { error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
                }
                XCTFail("expected to throw error")
            } catch {
                XCTAssertEqual(error as? TestError, TestError.test)
            }

            XCTAssertTrue(storeKitManager.updateAvailableProductsListStub.wasCalledExactlyOnce)
            XCTAssertTrue(storeKitManager.subscribeToPaymentQueueStub.wasCalledExactlyOnce)
            XCTAssertTrue(storeKitManager.delegateStub.setWasCalledExactlyOnce)
            XCTAssertIdentical(storeKitManager.delegateStub.setLastArguments?.value, storeKitDelegate)
        }
    }

    func testPaymentsDeactivation() async throws {
        let payments = Payments(inAppPurchaseIdentifiers: [],
                                apiService: apiService,
                                localStorage: storageMock,
                                alertManager: alertManagerMock,
                                reportBugAlertHandler: { _ in })
        payments.storeKitManager = storeKitManager

        payments.deactivate()

        XCTAssertTrue(storeKitManager.unsubscribeFromPaymentQueueStub.wasCalledExactlyOnce)
        XCTAssertTrue(storeKitManager.refreshHandlerStub.setWasCalledExactlyOnce)
        XCTAssertTrue(storeKitManager.delegateStub.setWasCalledExactlyOnce)
        XCTAssertNil(storeKitManager.delegateStub.setLastArguments?.value)
    }

}
