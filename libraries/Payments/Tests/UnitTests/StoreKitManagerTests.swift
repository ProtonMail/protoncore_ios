//
//  StoreKitManagerTests.swift
//  ProtonCore-Payments-Tests - Created on 21/12/2020.
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
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

@testable import ProtonCorePayments

final class StoreKitManagerTests: XCTestCase {

    let timeout = 1.0

    var planServiceMock: ServicePlanDataServiceMock!
    var plansDataSourceMock: PlansDataSourceMock!
    var paymentsApi: PaymentsApiMock!
    var apiService: APIServiceMock!
    var alertManagerMock: AlertManagerMock!
    var paymentsAlertMock: PaymentsAlertManager!
    var paymentsQueue: SKPaymentQueueMock!
    // swiftlint:disable:next weak_delegate
    var storeKitManagerDelegate: StoreKitManagerDelegateMock!
    var paymentTokenStorageMock: PaymentTokenStorageMock!

    override func setUp() {
        super.setUp()
        planServiceMock = ServicePlanDataServiceMock()
        plansDataSourceMock = PlansDataSourceMock()
        paymentsApi = PaymentsApiMock()
        apiService = APIServiceMock()
        alertManagerMock = AlertManagerMock()
        paymentsAlertMock = PaymentsAlertManager(alertManager: alertManagerMock)
        paymentsQueue = SKPaymentQueueMock()
        storeKitManagerDelegate = StoreKitManagerDelegateMock()
        paymentTokenStorageMock = PaymentTokenStorageMock()
    }

    override func tearDown() {
        planServiceMock = nil
        plansDataSourceMock = nil
        paymentsApi = nil
        apiService = nil
        alertManagerMock = nil
        paymentsAlertMock = nil
        paymentsQueue = nil
        storeKitManagerDelegate = nil
        paymentTokenStorageMock = nil
        super.tearDown()
    }

    // MARK: Static one-time plans tests

    func testPurchaseWithoutAvailableProducts() throws {
        // Test scenario:
        // 1. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { [] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (1)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 1000) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWithoutAvailableIAPs() throws {
        // Test scenario:
        // 1. Have no IAP available
        // 2. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given: no IAP (1)
        planServiceMock.isIAPAvailableStub.fixture = false
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWhenNoPlanDetails() throws {
        // Test scenario:
        // 1. Plan has not details (like it wasn't returned from API)
        // 2. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given: Plan has no details (1)
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in nil }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWhenPlanInNotPurchasable() throws {
           // Test scenario:
           // 1. Plan is not purchasable
           // 2. Do purchase
           // Expected: Error: Errors.unavailableProduct

           // given: Plan is not purchasable (1)
           planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 0) }
           let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                     inAppPurchaseIdentifiersSet: { _ in },
                                     planService: .left(planServiceMock),
                                     storeKitDataSource: nil,
                                     paymentsApi: paymentsApi,
                                     apiService: apiService,
                                     canExtendSubscription: false,
                                     paymentsAlertManager: paymentsAlertMock,
                                     reportBugAlertHandler: nil,
                                     refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                     reachability: nil)
           out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
           planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
           let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

           // when: purchase (2)
           var returnedError: Error?
           out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

           // then
           XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
       }

    func testPurchaseWhenThereIsAlreadyActiveSubscription() throws {
        // Test scenario:
        // 1. User has subscription
        // 2. Attempt purchase
        // Expected: Error: Errors.invalidPurchase

        // given: User has subscription (1)
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 1)
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(planDetails: [planDetails])
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in planDetails }
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
        }

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.invalidPurchase)
    }

    func testPurchaseWhenThereIsAlreadyActiveSubscription_CanAddCredits_WillRenewAutomatically() throws {
        // Test scenario:
        // 1. User has subscription
        // 2. Do purchase
        // Expected: Error: Errors.invalidPurchase

        // given: User has subscription (1)
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 1)
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(planDetails: [planDetails])
        planServiceMock.willRenewAutomaticallyStub.bodyIs { _, _  in
            true
        }
        planServiceMock.paymentMethodsStub.fixture = []
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: true,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in planDetails }
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.invalidPurchase)
    }

    func testPurchaseWhenThereIsAlreadyActiveSubscription_purchasedOnWeb_CanAddCredits_WillNotRenewAutomatically() throws {
        // Test scenario:
        // 1. User has subscription purchased on web
        // 2. Do purchase
        // Expected: Error: Errors.invalidPurchase

        // given: User has subscription (1)
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 1)
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(planDetails: [planDetails])
        planServiceMock.willRenewAutomaticallyStub.bodyIs { _, _  in
            false
        }
        planServiceMock.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: true,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in planDetails }
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.invalidPurchase)
    }

    func testPurchaseWhenThereIsAlreadyActiveSubscription_CanAddCredits_WillNotRenewAutomatically() throws {
        // Test scenario:
        // 1. User has subscription
        // 2. Do purchase
        // Expected: returnedError = nil, because we can stil add credits

        // given: User has subscription (1)
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 1)
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(planDetails: [planDetails])
        planServiceMock.willRenewAutomaticallyStub.bodyIs { _, _  in
            false
        }
        planServiceMock.paymentMethodsStub.fixture = []
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: true,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in planDetails }
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in returnedError = error }

        // then
        XCTAssertNil(returnedError)
    }

    func testPurchaseIsAddedtoPaymentQueueWhenTheresNoLoggedInUser() throws {
        // Test scenario:
        // 1. There's no logged in user
        // 2. Do purchase
        // Expected: Payment without applicationUsername added to queue

        // given: There's no logged in user (1)
        storeKitManagerDelegate.userIdStub.fixture = nil
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.paymentQueue = paymentsQueue
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 1)
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in planDetails }
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }

        // then
        XCTAssertEqual(paymentsQueue.payments.first?.productIdentifier, "ios_test_12_usd_non_renewing")
        XCTAssertEqual(paymentsQueue.payments.first?.quantity, 1)
        XCTAssertEqual(paymentsQueue.payments.first?.applicationUsername, nil)
    }

    // This test is suspect, it finishes before purchaseProduct has a chance to return
    func disabledTestPurchaseIsAddedtoPaymentQueueWhenUserIsLoggedIn() throws {
        // Test scenario:
        // 1. User is logged in but has not subscription
        // 2. Do purchase
        // Expected: Payment with applicationUsername added to queue

        // given: User is logged in but has not subscription (1)
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        planServiceMock.currentSubscriptionStub.fixture = .dummy
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.paymentQueue = paymentsQueue
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", state: 1)
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in
            planDetails
        }
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        let expectation = XCTestExpectation()
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in
            XCTFail("Shouldn't be calling success handler") } errorCompletion: { _ in
                XCTFail("Shouldn't be calling the error handler")
        }

        wait(for: [expectation], timeout: 50)
        // then
        XCTAssertEqual(paymentsQueue.payments.first?.productIdentifier, "ios_test_12_usd_non_renewing")
        XCTAssertEqual(paymentsQueue.payments.first?.quantity, 1)
        XCTAssertEqual(paymentsQueue.payments.first?.applicationUsername, "test user".sha256)
    }

    func testTransactionStateFailed() throws {
        // Test scenario:
        // 1. Simulate transaction state = failed
        // 2. Purchase and process transaction
        // Expected: Error: Errors.transactionFailedByUnknownReason and transaction is finished

        // given: Simulate transaction state = failed (1)
        paymentsQueue.transactionState = .failed
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: Purchase and process transaction (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentsQueue.finishTransactionStub.wasCalledExactlyOnce)
        XCTAssertEqual((paymentsQueue.finishTransactionStub.lastArguments?.a1 as? SKPaymentTransactionMock)?.mockPayment.productIdentifier, "ios_test_12_usd_non_renewing")
        XCTAssertEqual((paymentsQueue.finishTransactionStub.lastArguments?.a1 as? SKPaymentTransactionMock)?.mockPayment.applicationUsername, nil)
        XCTAssertEqual((paymentsQueue.finishTransactionStub.lastArguments?.a1 as? SKPaymentTransactionMock)?.mockPayment.quantity, 1)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.transactionFailedByUnknownReason)
    }

    func testTransactionStateDeferred() throws {
        // Test scenario:
        // 1. Simulate transaction state = deferred
        // 2. Purchase and process transaction
        // Expected: deferredCompletion

        // given: Simulate transaction state = deferred (1)
        paymentsQueue.transactionState = .deferred
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") }
            errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }
            deferredCompletion: { expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTransactionStateFailedErrorPaymentCancelled() throws {
        // Test scenario:
        // 1. Simulate transaction state = faild with error SKError.paymentCancelled
        // 2. Do purchase
        // Expected: Finalize: .cancelled

        // simulate failed state (1)
        paymentsQueue.transactionState = .failed
        paymentsQueue.error = NSError(domain: "test domain", code: SKError.paymentCancelled.rawValue, localizedDescription: "test description")
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedResult: PaymentSucceeded?
        out.purchaseProduct(plan: plan, amountDue: 100) { result in
            returnedResult = result
            expectation.fulfill()
        }
            errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }
            deferredCompletion: { XCTFail("Shouldn't be calling the deferred handler")
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedResult, .cancelled)
    }

    func testTransactionStatePurchasing() throws {
        // Test scenario:
        // 1. Simulate transaction state = purchasing
        // 2. Purchase and process transaction
        // Expected: deferredCompletion

        // given: Simulate transaction state = purchasing (1)
        paymentsQueue.transactionState = .purchasing
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") }
            errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }
            deferredCompletion: { expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTransactionStateFailedErrorPaymentOther() throws {
        // Test scenario:
        // 1. Simulate transaction state = faild with error Errors.transactionFailedByUnknownReason
        // 2. Do purchase
        // Expected: Error: Errors.transactionFailedByUnknownReason

        // simulate failed state (1)
        paymentsQueue.transactionState = .failed
        paymentsQueue.error = StoreKitManager.Errors.transactionFailedByUnknownReason
        let refreshExpectation = expectation(description: "Should call refresh handler")
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: refreshExpectation)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") }
            errorCompletion: { error in
                returnedError = error
                expectation.fulfill()
            }
            deferredCompletion: { XCTFail("Shouldn't be calling the deferred handler")
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.transactionFailedByUnknownReason)
    }

    func testTransactionStatePurchasedLocked() throws {
        // Test scenario:
        // 1. Locked app
        // 2. Do purchase
        // Expected: Error: Errors.appIsLocked

        // locked app (1)
        storeKitManagerDelegate.isUnlockedStub.fixture = false
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        paymentsQueue.transactionState = .purchased
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.appIsLocked)
    }

    func testTransactionStatePurchasedSignedOut() throws {
        // Test scenario:
        // 1. App not sign in
        // 2. Do purchase
        // Expected: Error: Errors.pleaseSignIn

        // locked app (1)
        storeKitManagerDelegate.isSignedInStub.fixture = false
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        paymentsQueue.transactionState = .purchased
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.pleaseSignIn)
    }

    func testTransactionStatePurchasedNoActiveUsername() throws {
        // Test scenario:
        // 1. Do purchase for logged in user
        // 2. Set user Id to nil
        // 3. Start processing transactions
        // Expected: nothing

        // given
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        paymentsQueue.transactionState = .purchased
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: Do purchase for logged in user (1)
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }
        //       Set user Id to nil (2)
        storeKitManagerDelegate.userIdStub.fixture = nil
        //       Start processing transactions (3)
        paymentsQueue.fire = true

        // then
        // nothing should happen — the completion block was associated with the username
    }

    // Remove with CP-6369
    func testTransactionStatePurchasedNoHashedUsernameWithoutSubscriptionsFF() throws {
        withFeatureFlags([]) {
            // Test scenario:
            // 1. Do purchase for unauthorized
            // 2. Start processing transactions
            // 3. Change user Id
            // 4. Start processing transactions again
            // Expected: Seccess: Purchased product

            // given
            let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
            paymentsQueue.transactionState = .purchased
            let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
            let expectation1 = expectation(description: "Should call error completion block")
            let subscription: [String: Any] = [
                "Code": 1000,
                "Subscription": [
                    "PeriodStart": 0,
                    "PeriodEnd": 0,
                    "CouponCode": "test code",
                    "Cycle": 12,
                    "Plans": [String]()
                ] as [String: Any]
            ]
            let token = PaymentToken(token: "test token", status: .pending)
            storeKitManagerDelegate.tokenStorageStub.fixture = paymentTokenStorageMock
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("subscription/check") {
                    completion(nil, .success(ValidateSubscription(amount: 0, amountDue: 0).toSuccessfulResponse))
                } else if path.contains("tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(token.toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(subscription))
                } else {
                    XCTFail("Unexpected request: \(path)")
                }
            }

            // when: Do purchase for unauthorized (1)
            var returnedResult: PaymentSucceeded? = .none
            paymentTokenStorageMock.getStub.bodyIs { _ in token }
            out.purchaseProduct(plan: plan, amountDue: 100) { result in
                returnedResult = result
                expectation1.fulfill()
            } errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler")
            }
            //       Start processing transactions (2)
            paymentsQueue.fire = true

            // then
            waitForExpectations(timeout: timeout)
            guard case .withoutExchangingToken(let returnedToken) = returnedResult else {
                XCTFail("Unexpected result \(String(describing: returnedResult))"); return
            }
            XCTAssertEqual(returnedToken.token, token.token)
            XCTAssertTrue(paymentTokenStorageMock.addStub.wasCalledExactlyOnce)
            XCTAssertEqual(paymentTokenStorageMock.addStub.lastArguments?.a1.token, token.token)

            //       Change user Id (3)
            storeKitManagerDelegate.userIdStub.fixture = "test user"
            //       Start processing transactions again (4)
            let expectation2 = expectation(description: "Should call retryProcessingAllPendingTransactions completion block")
            out.retryProcessingAllPendingTransactions {
                expectation2.fulfill()
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertEqual(planServiceMock.currentSubscriptionStub.setLastArguments?.a1?.couponCode, "test code")
        }
    }

    func testReceiptLost() throws {
        // Test scenario:
        // 1. ReceiptError = receiptLost
        // 2. Do purchase
        // Expected: Error: Errors.appIsLocked

        // given
        let out = setupMocksToSimulateOngoingPurchase(expectRefreshHandler: nil)
        out.receiptError = StoreKitManager.Errors.receiptLost // (1)
        paymentsQueue.transactionState = .purchased
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!
        let expectation1 = expectation(description: "Should call error completion block")
        let subscription: [String: Any] = [
            "Code": 1000,
            "Subscription": [
                "PeriodStart": 0,
                "PeriodEnd": 0,
                "CouponCode": "test code",
                "Cycle": 12,
                "Plans": [String]()
            ] as [String: Any]
        ]
        let token = PaymentToken(token: "test token", status: .pending)
        storeKitManagerDelegate.tokenStorageStub.fixture = paymentTokenStorageMock
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("subscription/check") {
                completion(nil, .success(ValidateSubscription(amount: 0, amountDue: 0).toSuccessfulResponse))
            } else if path.contains("tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/tokens") {
                completion(nil, .success(token.toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(subscription))
            } else {
                XCTFail("Unexpected request: \(path)")
            }
        }

        // when: Do purchase for unauthorized (1)
        var returnedError: Error?
        paymentTokenStorageMock.getStub.bodyIs { _ in token }

        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation1.fulfill()
        }
        //       Start processing transactions (2)
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManager.Errors, StoreKitManager.Errors.receiptLost)
    }

    // MARK: Dynamic auto-renewing plans tests

    func testPurchaseWithoutAvailableRenewingProducts() throws {
        // Test scenario:
        // 1. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { [] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling a refresh handler") },
                                  reachability: nil)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_auto_renewing")!

        // when: purchase (1)
        var returnedError: Error?
        let expectation = expectation(description: "Expect the purchase to complete")
        out.purchaseProduct(plan: plan, amountDue: 1000) { _ in
            XCTFail("Shouldn't be calling a success handler")
        } errorCompletion: { error in returnedError = error
            expectation.fulfill()
        }

        // then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWithoutAvailableIAPsWithDynamicPlans() throws {
        // Test scenario:
        // 1. Have no IAP available
        // 2. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given: no IAP (1)
        plansDataSourceMock.isIAPAvailableStub.fixture = false
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_auto_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling a refresh handler") },
                                  reachability: nil)
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_auto_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        plansDataSourceMock.fetchAvailablePlansStub.bodyIs { _ in }
        plansDataSourceMock.isIAPAvailableStub(true)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        let expectation = expectation(description: "Expect the purchase to complete")
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in
            XCTFail("Shouldn't be calling the success handler")
            expectation.fulfill()
        } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }

        // then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWhenNoPlanDetailsWithDynamicPlans() throws {
        // Test scenario:
        // 1. Plan has not details (like it wasn't returned from API)
        // 2. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given: Plan has no details (1)
        plansDataSourceMock.detailsOfAvailablePlanCorrespondingToIAPStub.bodyIs { _, _ in nil }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_auto_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling the refresh handler") },
                                  reachability: nil)
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_auto_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        plansDataSourceMock.fetchAvailablePlansStub.bodyIs { _ in }
        plansDataSourceMock.isIAPAvailableStub(true)
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_auto_renewing")!

        // when: purchase (2)
        let expectation = expectation(description: "Expect the purchase to complete")
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in
            XCTFail("Shouldn't be calling the success handler")
        } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }

        // then
        waitForExpectations(timeout: 1)

        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWhenPlanIsNotPurchasableWithDynamicPlans() throws {
        // Test scenario:
        // 1. Plan is not purchasable
        // 2. Do purchase
        // Expected: Error: Errors.unavailableProduct

        // given: Plan is not purchasable (1)
        plansDataSourceMock.detailsOfAvailablePlanCorrespondingToIAPStub.bodyIs { _, _ in nil }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_auto_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling the refresh handler") },
                                  reachability: nil)
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_auto_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_non_renewing")!

        // when: purchase (2)
        let expectation = expectation(description: "Expect the purchase to complete")
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in
            XCTFail("Shouldn't be caling the success handler")
        } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.unavailableProduct)
    }

    func testPurchaseWhenThereIsAlreadyActiveSubscriptionWithDynamicPlans()  throws {
        // Test scenario:
        // 1. User has subscription
        // 2. Attempt purchase
        // Expected: Error: Errors.invalidPurchase

        // given: User has subscription (1)
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        let storeKitDataSourceMock = StoreKitDataSourceMock()
        storeKitDataSourceMock.availableProductsStub.fixture = [SKProduct(identifier: productId, price: "10.00", priceLocale: .current)]
        plansDataSourceMock.currentPlanStub.fixture = .dummy
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_auto_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling the refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: productId, price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        storeKitManagerDelegate.userIdStub.fixture = "test user"

        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Expect the purchase to complete")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { token in XCTFail("Shouldn't be calling a success handler") } errorCompletion: { error in returnedError = error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        // then
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, .invalidPurchase)
    }

    func testPurchaseIsAddedtoPaymentQueueWhenTheresNoLoggedInUserWithDynamicPlans() throws {
        // Test scenario:
        // 1. There's no logged in user
        // 2. Do purchase
        // Expected: Payment without applicationUsername added to queue

        // given: There's no logged in user (1)
        let productId = "ios_test_12_usd_auto_renewing"
        storeKitManagerDelegate.userIdStub.fixture = nil
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        let storeKitDataSourceMock = StoreKitDataSourceMock()
        storeKitDataSourceMock.availableProductsStub.fixture = [SKProduct(identifier: productId, price: "10.00", priceLocale: .current)]
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }

        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { [productId] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling the refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.paymentQueue = paymentsQueue
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_auto_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]

        let plan = InAppPurchasePlan(storeKitProductId: "ios_test_12_usd_auto_renewing")!
        let expectation = expectation(description: "Expect the purchase to complete")
        expectation.isInverted = true // need this trick because the purchase is enqueued but there's no callback that we can call fulfill() on to finish waiting

        // when: purchase (2)

        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling a success handler") }
    errorCompletion: { _ in XCTFail("Shouldn't be calling an error handler")
        }

        // then
        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(paymentsQueue.payments.first?.productIdentifier, "ios_test_12_usd_auto_renewing")
        XCTAssertEqual(paymentsQueue.payments.first?.quantity, 1)
        XCTAssertEqual(paymentsQueue.payments.first?.applicationUsername, nil)
    }

    func testPurchaseIsAddedtoPaymentQueueWhenUserIsLoggedInWithDynamicPlans() throws {
        // Test scenario:
        // 1. User is logged in but has not subscription
        // 2. Do purchase
        // Expected: Payment with applicationUsername added to queue

        // given: User is logged in but has not subscription (1)

        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        storeKitManagerDelegate.userIdStub.fixture = "test user"

        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { [productId] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: { _ in XCTFail("Shouldn't be calling the refresh handler") },
                                  reachability: nil)
        out.delegate = storeKitManagerDelegate
        out.paymentQueue = paymentsQueue
        out.availableProducts = [SKProduct(identifier: productId, price: "0.0", priceLocale: Locale(identifier: "en_US"))]

        // when: purchase (2)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Expect the purchase to complete")
        expectation.isInverted = true // need this trick because the purchase is enqueued but there's no callback that we can call fulfill() on to finish waiting

        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling a success handler") }
    errorCompletion: { _ in XCTFail("Shouldn't be calling an error handler")
        }

        // then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(paymentsQueue.payments.first?.productIdentifier, "ios_test_12_usd_auto_renewing")
        XCTAssertEqual(paymentsQueue.payments.first?.quantity, 1)
        XCTAssertEqual(paymentsQueue.payments.first?.applicationUsername, "test user".sha256)
    }

    func testTransactionStateFailedWithDynamicPlans() throws {
        // Test scenario:
        // 1. Simulate transaction state = failed
        // 2. Purchase and process transaction
        // Expected: Error: Errors.transactionFailedByUnknownReason and transaction is finished

        // given: Simulate transaction state = failed (1)
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .failed
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)

        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: Purchase and process transaction (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: 100)

        XCTAssertTrue(paymentsQueue.finishTransactionStub.wasCalledExactlyOnce)
        XCTAssertEqual((paymentsQueue.finishTransactionStub.lastArguments?.a1 as? SKPaymentTransactionMock)?.mockPayment.productIdentifier, "ios_test_12_usd_auto_renewing")
        XCTAssertEqual((paymentsQueue.finishTransactionStub.lastArguments?.a1 as? SKPaymentTransactionMock)?.mockPayment.applicationUsername, nil)
        XCTAssertEqual((paymentsQueue.finishTransactionStub.lastArguments?.a1 as? SKPaymentTransactionMock)?.mockPayment.quantity, 1)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.transactionFailedByUnknownReason)
    }

    func testTransactionStateDeferredWithDynamicPlans() throws {
        // Test scenario:
        // 1. Simulate transaction state = deferred
        // 2. Purchase and process transaction
        // Expected: deferredCompletion

        // given: Simulate transaction state = deferred (1)
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .deferred
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") }
            errorCompletion: { _ in XCTFail("Shouldn't be calling error handler") }
            deferredCompletion: { expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTransactionStateFailedErrorPaymentCancelledWithDynamicPlans() throws {
        // Test scenario:
        // 1. Simulate transaction state = faild with error SKError.paymentCancelled
        // 2. Do purchase
        // Expected: Finalize: .cancelled

        // simulate failed state (1)
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }

        paymentsQueue.transactionState = .failed
        paymentsQueue.error = NSError(domain: "test domain", code: SKError.paymentCancelled.rawValue, localizedDescription: "test description")
        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedResult: PaymentSucceeded?
        out.purchaseProduct(plan: plan, amountDue: 100) { result in
            returnedResult = result
            expectation.fulfill()
        }
    errorCompletion: { _ in XCTFail("Shouldn't be calling error handler") }
    deferredCompletion: { XCTFail("Shouldn't be calling deferred handler")
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedResult, .cancelled)
    }

    func testTransactionStatePurchasingWithDynamicPlans() throws {
        // Test scenario:
        // 1. Simulate transaction state = purchasing
        // 2. Purchase and process transaction
        // Expected: deferredCompletion

        // given: Simulate transaction state = purchasing (1)
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .purchasing
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") }
            errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }
            deferredCompletion: { expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTransactionStateFailedErrorPaymentOtherWithDynamicPlans() throws {
        // Test scenario:
        // 1. Simulate transaction state = faild with error Errors.transactionFailedByUnknownReason
        // 2. Do purchase
        // Expected: Error: Errors.transactionFailedByUnknownReason

        // simulate failed state (1)
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .failed
        paymentsQueue.error = StoreKitManager.Errors.transactionFailedByUnknownReason
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        let refreshExpectation = expectation(description: "Should call refresh handler")
        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: refreshExpectation)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") }
            errorCompletion: { error in
                returnedError = error
                expectation.fulfill()
            }
            deferredCompletion: { XCTFail("Shouldn't be calling the deferred handler")
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.transactionFailedByUnknownReason)
    }

    func testTransactionStatePurchasedLockedWithDynamicPlans() throws {
        // Test scenario:
        // 1. Locked app
        // 2. Do purchase
        // Expected: Error: Errors.appIsLocked

        // locked app (1)
        storeKitManagerDelegate.isUnlockedStub.fixture = false

        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .purchased
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }

        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.appIsLocked)
    }

    func testTransactionStatePurchasedSignedOutWithDynamicPlans() throws {
        // Test scenario:
        // 1. App not sign in
        // 2. Do purchase
        // Expected: Error: Errors.pleaseSignIn

        // locked app (1)
        storeKitManagerDelegate.isSignedInStub.fixture = false
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .purchased
        paymentsQueue.error = StoreKitManager.Errors.transactionFailedByUnknownReason
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }

        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")

        // when: purchase (2)
        var returnedError: Error?
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
            returnedError = error
            expectation.fulfill()
        }
        paymentsQueue.fire = true

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedError as? StoreKitManagerErrors, StoreKitManagerErrors.pleaseSignIn)
    }

    func testTransactionStatePurchasedNoActiveUsernameWithDynamicPlans() throws {
        // Test scenario:
        // 1. Do purchase for logged in user
        // 2. Set user Id to nil
        // 3. Start processing transactions
        // Expected: nothing

        // given
        let productId = "ios_test_12_usd_auto_renewing"
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(ID: productId)
        paymentsQueue.transactionState = .purchased
        plansDataSourceMock.isIAPAvailableStub.fixture = true
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _  in planDetails.instances.first }
        plansDataSourceMock.lastFetchedProductsStub.fixture = [SKProduct(identifier: productId, price: "1299", priceLocale: Locale(identifier: "fr_CH"))]

        let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
        out.availableProducts = [SKProduct(identifier: productId, price: "0.0", priceLocale: Locale(identifier: "en_US"))]

        let plan = InAppPurchasePlan(storeKitProductId: productId)!
        let expectation = expectation(description: "Should call error completion block")
        expectation.isInverted = true

        // when: Do purchase for logged in user (1)
        storeKitManagerDelegate.userIdStub.fixture = "test user"
        out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler") }
        //       Set user Id to nil (2)
        storeKitManagerDelegate.userIdStub.fixture = nil
        //       Start processing transactions (3)
        paymentsQueue.fire = true
        waitForExpectations(timeout: timeout)

        // then
        // nothing should happen — the completion block was associated with the username
    }

    func testTransactionStatePurchasedNoHashedUsername() throws {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Do purchase for unauthenticated
            // 2. Start processing transactions
            // 3. Change user Id
            // 4. Start processing transactions again
            // Expected: Seccess: Purchased product

            // given
            let productId = "ios_test_12_usd_auto_renewing"
            plansDataSourceMock.lastFetchedProductsStub.fixture = [SKProduct(identifier: productId, price: "1299", priceLocale: Locale(identifier: "fr_CH"))]

            let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
            paymentsQueue.transactionState = .purchased
            let plan = InAppPurchasePlan(storeKitProductId: productId)!
            let expectation1 = expectation(description: "Should call error completion block")
            let subscription: [String: Any] = [
                "Code": 1000,
                "Subscription": [
                    "PeriodStart": 0,
                    "PeriodEnd": 0,
                    "CouponCode": "test code",
                    "Cycle": 12,
                    "Plans": [String]()
                ] as [String: Any]
            ]
            let token = PaymentToken(token: "test token", status: .pending)
            plansDataSourceMock.isIAPAvailableStub.fixture = true
            storeKitManagerDelegate.tokenStorageStub.fixture = paymentTokenStorageMock
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("subscription/check") {
                    completion(nil, .success(ValidateSubscription(amount: 0, amountDue: 0).toSuccessfulResponse))
                } else if path.contains("tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(token.toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(subscription))
                } else {
                    XCTFail("Unexpected request")
                }
            }

            // when: Do purchase for unauthorized (1)
            var returnedResult: PaymentSucceeded? = .none
            paymentTokenStorageMock.getStub.bodyIs { _ in token }
            out.purchaseProduct(plan: plan, amountDue: 100) { result in
                returnedResult = result
                expectation1.fulfill()
            } errorCompletion: { _ in XCTFail("Shouldn't be calling the error handler")
            }
            //       Start processing transactions (2)
            paymentsQueue.fire = true

            // then
            waitForExpectations(timeout: timeout)
            guard case .withoutExchangingToken(let returnedToken) = returnedResult else {
                XCTFail("Unexpected result \(String(describing: returnedResult))"); return
            }
            XCTAssertEqual(returnedToken.token, token.token)
            XCTAssertTrue(paymentTokenStorageMock.addStub.wasCalledExactlyOnce)
            XCTAssertEqual(paymentTokenStorageMock.addStub.lastArguments?.a1.token, token.token)

            //       Change user Id (3)
            storeKitManagerDelegate.userIdStub.fixture = "test user"
            //       Start processing transactions again (4)
            let expectation2 = expectation(description: "Should call retryProcessingAllPendingTransactions completion block")
            out.retryProcessingAllPendingTransactions {
                expectation2.fulfill()
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        }
    }

    func testReceiptLostWithDynamicPlans() throws {
        // Test scenario:
        // 1. ReceiptError = receiptLost
        // 2. Do purchase
        // Expected: Error: Errors.appIsLocked
        withFeatureFlags([.dynamicPlans]) {
            // given
            let productId = "ios_test_12_usd_auto_renewing"
            plansDataSourceMock.isIAPAvailableStub.fixture = true
            plansDataSourceMock.availablePlansStub.fixture = .init(plans: [AvailablePlans.AvailablePlan(ID: productId,
                                                                                                        type: 0,
                                                                                                        name: "Bundle2022", title: "Bundle Title", instances: [.init(cycle: 12, description: "description", periodEnd: 12, price: [.init(ID: "price", current: 1299, currency: "CHF")])], entitlements:
                                                                                                          [.description(.init(type: "description", iconName: "tick", text: "text", hint: "hint"))],
                                                                                                        decorations: [.starred(.init(type: "starred", iconName: "tick"))]
                                                                                                       )
                                          ])
            plansDataSourceMock.lastFetchedProductsStub.fixture = [SKProduct(identifier: productId, price: "1299", priceLocale: Locale(identifier: "fr_CH"))]

            let out = setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: nil)
            out.receiptError = StoreKitManager.Errors.receiptLost // (1)
            paymentsQueue.transactionState = .purchased
            let plan = InAppPurchasePlan(storeKitProductId: productId)!
            let expectation1 = expectation(description: "Should call error completion block")
            let subscription: [String: Any] = [
                "Code": 1000,
                "Subscription": [
                    "PeriodStart": 0,
                    "PeriodEnd": 0,
                    "CouponCode": "test code",
                    "Cycle": 12,
                    "Plans": ["vpn2022"],
                ] as [String: Any]
            ]
            let token = PaymentToken(token: "test token", status: .pending)
            storeKitManagerDelegate.tokenStorageStub.fixture = paymentTokenStorageMock
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("subscription/check") {
                    completion(nil, .success(ValidateSubscription(amount: 0, amountDue: 0).toSuccessfulResponse))
                } else if path.contains("tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(token.toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(subscription))
                } else {
                    XCTFail("Unexpected request")
                }
            }

            // when: Do purchase for unauthorized (1)
            var returnedError: Error?
            paymentTokenStorageMock.getStub.bodyIs { _ in token }
            out.purchaseProduct(plan: plan, amountDue: 100) { _ in XCTFail("Shouldn't be calling success handler") } errorCompletion: { error in
                returnedError = error
                expectation1.fulfill()
            }
            //       Start processing transactions (2)
            paymentsQueue.fire = true

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedError as? StoreKitManager.Errors, StoreKitManager.Errors.receiptLost)
        }
    }

    // MARK: Private helpers

    private func setupMocksToSimulateOngoingPurchase(expectRefreshHandler: XCTestExpectation?) -> StoreKitManager {
        let refreshHandler: (ProcessCompletionResult) -> Void = { _ in
            if let expectRefreshHandler = expectRefreshHandler {
                expectRefreshHandler.fulfill()
            } else {
                XCTFail("Shouldn't be calling the refresh handler")
            }
        }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_non_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .left(planServiceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: refreshHandler,
                                  reachability: nil)
        out.paymentQueue = paymentsQueue
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        let planDetails = Plan.empty.updated(name: "ios_test_12_usd_non_renewing", iD: "test plan id", pricing: ["12": 100], state: 1)
        planServiceMock.updateServicePlansSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in planDetails }
        planServiceMock.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, successCallback, _ in successCallback() }
        planServiceMock.currentSubscriptionStub.fixture = .dummy
        out.subscribeToPaymentQueue()
        return out
    }

    private func setupMocksToSimulateOngoingPurchaseWithDynamicPlans(expectRefreshHandler: XCTestExpectation?) -> StoreKitManager {
        let refreshHandler: (ProcessCompletionResult) -> Void = { _ in
            if let expectRefreshHandler = expectRefreshHandler {
                expectRefreshHandler.fulfill()
            } else {
                XCTFail("Shouldn't be calling refresh handler")
            }
        }
        let out = StoreKitManager(inAppPurchaseIdentifiersGet: { ["ios_test_12_usd_auto_renewing"] },
                                  inAppPurchaseIdentifiersSet: { _ in },
                                  planService: .right(plansDataSourceMock),
                                  storeKitDataSource: nil,
                                  paymentsApi: paymentsApi,
                                  apiService: apiService,
                                  canExtendSubscription: false,
                                  paymentsAlertManager: paymentsAlertMock,
                                  reportBugAlertHandler: nil,
                                  refreshHandler: refreshHandler,
                                  reachability: nil)
        out.paymentQueue = paymentsQueue
        out.delegate = storeKitManagerDelegate
        out.availableProducts = [SKProduct(identifier: "ios_test_12_usd_auto_renewing", price: "0.0", priceLocale: Locale(identifier: "en_US"))]
        let instance = AvailablePlans.AvailablePlan.Instance(
            cycle: 12,
            description: "test",
            periodEnd: 100,
            price: [.init(ID: "id", current: 79, currency: "USD")]
        )
        let planDetails = AvailablePlans.AvailablePlan.dummy.updated(
            ID: "test plan id",
            name: "ios_test_12_usd_auto_renewing",
            instances: [ instance ]
        )
        plansDataSourceMock.fetchAvailablePlansStub.bodyIs { _ in }
        plansDataSourceMock.detailsOfAvailablePlanInstanceCorrespondingToIAPStub.bodyIs { _, _ in instance }
        plansDataSourceMock.detailsOfAvailablePlanCorrespondingToIAPStub.bodyIs { _, _  in planDetails }
        out.subscribeToPaymentQueue()
        return out
    }

}
