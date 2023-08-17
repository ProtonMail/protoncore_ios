//
//  PurchaseManagerTests.swift
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
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCorePayments

final class PurchaseManagerTests: XCTestCase {

    let timeout = 1.0

    var planServiceMock: ServicePlanDataServiceMock!
    var storeKitManager: StoreKitManagerMock!
    var paymentsApi: PaymentsApiMock!
    var apiService: APIServiceMock!

    override func setUp() {
        super.setUp()
        planServiceMock = ServicePlanDataServiceMock()
        storeKitManager = StoreKitManagerMock()
        paymentsApi = PaymentsApiMock()
        apiService = APIServiceMock()
    }

    func testShouldAcceptFreePlan() {
        // given
        let plan = InAppPurchasePlan.freePlan
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        var boughtPlan: InAppPurchasePlan?
        let expectation = expectation(description: "Should accept free plan")

        // when
        out.buyPlan(plan: plan) { result in
            switch result {
            case .purchasedPlan(let accountPlan):
                boughtPlan = accountPlan
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(plan, boughtPlan)
    }

    func testShouldNotAllowPurchaseIfUnfinishedTransaction() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        storeKitManager.hasUnfinishedPurchaseStub.bodyIs { _ in true }
        storeKitManager.currentTransactionStub.bodyIs { _ in
            final class SKPaymentTransactionMock: SKPaymentTransaction {
                override var payment: SKPayment {
                    SKPayment(product: SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: .current))
                }
            }
            return SKPaymentTransactionMock()
        }
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        var unfinishedPlan: InAppPurchasePlan?
        let expectation = expectation(description: "Should accept free plan")

        // when
        out.buyPlan(plan: plan) { result in
            switch result {
            case .planPurchaseProcessingInProgress(let unfinishedPurchasePlan):
                unfinishedPlan = unfinishedPurchasePlan
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(plan, unfinishedPlan)
    }

    func testShouldFetchAmountDueForPlanWithGivenIdAndReturnUnknownErrorOnLackOfResponse() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success([:])) }
        let expectation = expectation(description: "Should call completion block")

        // when
        var returnedError: Error?
        var failedPlan: InAppPurchasePlan? = plan
        out.buyPlan(plan: plan) { result in
            switch result {
            case let .purchaseError(error, processingPlan):
                returnedError = error
                failedPlan = processingPlan
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentsApi.validateSubscriptionRequestStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.transactionFailedByUnknownReason)
        XCTAssertNil(failedPlan)
    }

    func testShouldFetchAmountDueForPlanWithGivenIdAndReturnNetworkErrorOnFailedRequest() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        let underlyingError = NSError(domain: "test_domain", code: 1234, userInfo: nil)
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .failure(underlyingError)) }
        let expectation = expectation(description: "Should call completion block")

        // when
        var returnedError: Error?
        out.buyPlan(plan: plan) { result in
            switch result {
            case let .purchaseError(error, _):
                returnedError = error
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual((returnedError as? ResponseError)?.underlyingError, underlyingError)
    }

    func testShouldNotCallStoreKitIfAmountDueIsZero() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success(ValidateSubscription(amountDue: 0).toJsonDict)) }
        let expectation = expectation(description: "Should call completion block")

        // when
        out.buyPlan(plan: plan) { result in
            expectation.fulfill()
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentsApi.buySubscriptionForZeroRequestStub.wasCalledExactlyOnce)
        XCTAssertTrue(storeKitManager.purchaseProductStub.wasNotCalled)
    }

    func testShouldSuccessfullyBuySubscriptionForZeroUpdateSubscriptionSuccess() {
        let expectation1 = expectation(description: "Should call completion block")
        let expectation2 = expectation(description: "Should call refresh handler")
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(couponCode: "test code")
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, errorCallback in successCallback() }
        storeKitManager.refreshHandlerStub.fixture = { _ in expectation2.fulfill() }
        let subscription: [String: Any] = [
            "Code": 1000,
            "Subscription": [
                "PeriodStart": 0,
                "PeriodEnd": 0,
                "CouponCode": "test code",
                "Cycle": 12,
                "Plans": []
            ]
        ]
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("subscription/check") {
                completion(nil, .success(ValidateSubscription(amountDue: 0).toSuccessfulResponse))
            } else if path.contains("subscription") {
                completion(nil, .success(subscription))
            } else {
                XCTFail()
            }
        }

        // when
        var purchasedPlan: InAppPurchasePlan?
        out.buyPlan(plan: plan) { result in
            switch result {
            case .purchasedPlan(let accountPlan):
                purchasedPlan = accountPlan
                expectation1.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(purchasedPlan, plan)
        XCTAssertEqual(planServiceMock.currentSubscription?.couponCode, "test code")
        XCTAssertTrue(paymentsApi.buySubscriptionForZeroRequestStub.wasCalledExactlyOnce)
        XCTAssertTrue(storeKitManager.purchaseProductStub.wasNotCalled)
    }

    func testShouldSuccessfullyBuySubscriptionForZeroUpdateSubscriptionError() {
        let expectation1 = expectation(description: "Should call completion block")
        let expectation2 = expectation(description: "Should call refresh handler")
        
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, errorCallback in errorCallback(NSError(domain: "test_domain", code: 1234, userInfo: nil)) }
        storeKitManager.refreshHandlerStub.fixture = { _ in expectation2.fulfill() }
        let subscription: [String: Any] = [
            "Code": 1000,
            "Subscription": [
                "PeriodStart": 0,
                "PeriodEnd": 0,
                "CouponCode": "test code",
                "Cycle": 12,
                "Plans": []
            ]
        ]
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("subscription/check") {
                completion(nil, .success(ValidateSubscription(amountDue: 0).toSuccessfulResponse))
            } else if path.contains("subscription") {
                completion(nil, .success(subscription))
            } else {
                XCTFail()
            }
        }

        // when
        var purchasedPlan: InAppPurchasePlan?
        out.buyPlan(plan: plan) { result in
            switch result {
            case .purchasedPlan(let accountPlan):
                purchasedPlan = accountPlan
                expectation1.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(purchasedPlan, plan)
        XCTAssertEqual(planServiceMock.currentSubscriptionStub.setLastArguments?.a1?.couponCode, "test code")
        XCTAssertTrue(paymentsApi.buySubscriptionForZeroRequestStub.wasCalledExactlyOnce)
        XCTAssertTrue(storeKitManager.purchaseProductStub.wasNotCalled)
    }
    
    func testShouldPassProductPurchasingToStoreKitIfAmountDueNonZero() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success(ValidateSubscription(amountDue: 100).toJsonDict)) }
        storeKitManager.purchaseProductStub.bodyIs { _, _, _, completion, _, _ in completion(.resolvingIAPToSubscription) }
        let expectation = expectation(description: "Should call completion block")

        // when
        var purchasedPlan: InAppPurchasePlan?
        out.buyPlan(plan: plan) { result in
            switch result {
            case .purchasedPlan(let accountPlan):
                purchasedPlan = accountPlan
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(storeKitManager.purchaseProductStub.wasCalledExactlyOnce)
        XCTAssertEqual(purchasedPlan, plan)
        XCTAssertEqual(storeKitManager.purchaseProductStub.lastArguments?.a1, plan)
        XCTAssertEqual(storeKitManager.purchaseProductStub.lastArguments?.a2, 100)
    }
    
    func testShouldPassApiIsBlockedError() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success(ValidateSubscription(amountDue: 100).toJsonDict)) }
        storeKitManager.purchaseProductStub.bodyIs { _, _, _, _, errorCompletion, _ in errorCompletion(StoreKitManagerErrors.apiMightBeBlocked(message: "test message", originalError: NSError.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: PSTranslation._core_api_might_be_blocked_message.l10n))) }
        let expectation = expectation(description: "Should call completion block")

        // when
        var returnedError: Error?
        out.buyPlan(plan: plan) { result in
            switch result {
            case let .apiMightBeBlocked(_, originalError, _):
                returnedError = originalError
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? NSError, NSError.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: PSTranslation._core_api_might_be_blocked_message.l10n))
    }

    func testShouldPassErrorFromStoreKit() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success(ValidateSubscription(amountDue: 100).toJsonDict)) }
        storeKitManager.purchaseProductStub.bodyIs { _, _, _, _, errorCompletion, _ in errorCompletion(StoreKitManagerErrors.haveTransactionOfAnotherUser) }
        let expectation = expectation(description: "Should call completion block")

        // when
        var returnedError: Error?
        out.buyPlan(plan: plan) { result in
            switch result {
            case let .purchaseError(error, _):
                returnedError = error
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.haveTransactionOfAnotherUser)
    }

    func testShouldPassCancellationFromStoreKit() {
        // given
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let out = PurchaseManager(planService: planServiceMock, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success(ValidateSubscription(amountDue: 100).toJsonDict)) }
        storeKitManager.purchaseProductStub.bodyIs { _, _, _, successCompletion, _, _ in successCompletion(.cancelled) }
        let expectation = expectation(description: "Should call completion block")

        // when
        out.buyPlan(plan: plan) { result in
            switch result {
            case .purchaseCancelled:
                expectation.fulfill()
            default:
                XCTFail()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
    }

}
