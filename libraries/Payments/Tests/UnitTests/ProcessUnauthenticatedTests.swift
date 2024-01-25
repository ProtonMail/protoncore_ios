//
//  ProcessAuthenticatedTests.swift
//  ProtonCore-Payments-Tests - Created on 26/12/2020.
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
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreNetworking
@testable import ProtonCorePayments

final class ProcessUnauthenticatedTests: XCTestCase {

    let timeout = 1.0

    let queue = DispatchQueue.global(qos: .userInitiated)

    var apiService: APIServiceMock!
    var paymentsApi: PaymentsApiMock!
    var processDependencies: ProcessDependenciesMock!
    // swiftlint:disable:next weak_delegate
    var storeKitManagerDelegate: StoreKitManagerDelegateMock!
    var paymentTokenStorageMock: PaymentTokenStorageMock!
    var alertManagerMock: AlertManagerMock!
    var paymentsAlertManager: PaymentsAlertManager!

    let payment = SKPayment(product: SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: .current))

    var testSubscriptionDict: [String: Any] {
        [
            "Code": 1000,
            "Subscription": [
                "PeriodStart": 0,
                "PeriodEnd": 0,
                "CouponCode": "test code",
                "Cycle": 12,
                "Plans": [String]()
            ] as [String: Any]
        ]
    }

    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
        paymentsApi = PaymentsApiMock()
        storeKitManagerDelegate = StoreKitManagerDelegateMock()
        paymentTokenStorageMock = PaymentTokenStorageMock()
        alertManagerMock = AlertManagerMock()
        paymentsAlertManager = PaymentsAlertManager(alertManager: alertManagerMock)
        processDependencies = ProcessDependenciesMock()
        processDependencies.alertManagerStub.fixture = paymentsAlertManager
        processDependencies.apiServiceStub.fixture = apiService
        processDependencies.paymentsApiProtocolStub.fixture = paymentsApi
        processDependencies.storeKitDelegateStub.fixture = storeKitManagerDelegate
        processDependencies.tokenStorageStub.fixture = paymentTokenStorageMock
    }

    func testSubscriptionSuccess() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 1)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutExchangingToken(let paymentToken)) = returnedResult else { XCTFail(); return }
            XCTAssertEqual(paymentToken.token, "test token")
            XCTAssertEqual(paymentToken.status, .chargeable)
        }
    }

    func testSubscriptionReceiptError() {
        // Test scenario:
        // 1. Throw error when getting the receipt
        // Expected: Error is thrown

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 3)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        processDependencies.getReceiptStub.bodyIs { _ in throw NSError(domain: "test error", code: 42, userInfo: nil) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }
        let expectation = self.expectation(description: "Completion block called")

        // when
        var returnedError: Error?
        queue.async {
            do {
                try out.process(transaction: transaction, plan: plan) { _ in XCTFail() }
            } catch {
                returnedError = error
                expectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual((returnedError as NSError?), NSError(domain: "test error", code: 42, userInfo: nil))
    }

    func testSubscriptionTokenRequestFail() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // 2. Fail token request
            // Expected: transaction added to transactionsBeforeSignupStub and token storage cleared

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 2)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusRequestFail() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // 2. Fail token status request
            // Expected: transaction added to transactionsBeforeSignupStub and payment token cleared

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 4)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(["Code": 22000]))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusConsumed() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status consumed
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .consumed).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusFailed() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status failed
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .failed).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusNotSupported() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status failed
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 15)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .notSupported).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusPending() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status pending
            // Expected: transaction processing is retried

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 2)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            var tokenStatusToReturn = PaymentTokenStatus(status: .pending)
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(tokenStatusToReturn.toSuccessfulResponse))
                    tokenStatusToReturn = PaymentTokenStatus(status: .chargeable)
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(processDependencies.getReceiptStub.callCounter, 1)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
            guard case .finished(.withoutExchangingToken(let paymentToken)) = returnedResult else { XCTFail(); return }
            XCTAssertEqual(paymentToken.token, "test token")
            XCTAssertEqual(paymentToken.status, .chargeable)
        }
    }

    func testPurchaseContinuationWhenAmountDueIsAmount() {
        // Test scenario:
        // 1. Continue transaction after signup
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 18)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(testSubscriptionDict))
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
        var returnedSubscription: Subscription?
        processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual(returnedSubscription?.couponCode, "test code")
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished(.resolvingIAPToSubscription) = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenAmountDueIsDifferentThanAmount() {
        // Test scenario:
        // 1. Continue transaction after signup with amount due different then amount
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 10, cycle: 24)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        var returnedParameters: Any?
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(testSubscriptionDict))
            } else if path.contains("/subscription") {
                returnedParameters = parameters
                completion(nil, .success(testSubscriptionDict))
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
        var returnedSubscription: Subscription?
        processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual(returnedSubscription?.couponCode, "test code")
        XCTAssertEqual((returnedParameters as? [String: Any])?["Amount"] as? Int, 0) // buy for zero!
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished(.resolvingIAPToSubscription) = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenTokenStatusFailBecauseOfNetworkError() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail token status request with network error
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 48)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(["Code": 3500])) // tls
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        let expectation = self.expectation(description: "Completion block called")

        // when
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
            expectation.fulfill()
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(alertManagerMock.showAlertStub.wasCalledExactlyOnce)
    }

    func testPurchaseContinuationWhenTokenStatusFailBecauseOfErrorOtherThanNetwork() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail token status request with non-network error
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 1)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        var tokenResponse = ["Code": 22000]
        apiService.requestJSONStub.bodyIs { counter, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(tokenResponse))
                tokenResponse = ["Code": 3500]
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestJSONStub.callCounter, 2)
    }

    func testPurchaseContinuationWhenTokenStatusNotSupported() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status not supported
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 2)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestJSONStub.bodyIs { counter, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .notSupported).toSuccessfulResponse))
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
    }

    func testPurchaseContinuationWhenTokenStatusConsumed() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status consumed
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 2)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestJSONStub.bodyIs { counter, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .consumed).toSuccessfulResponse))
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenTokenStatusFailed() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status failed
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 3)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        var tokenStatus = PaymentTokenStatus(status: .failed)
        apiService.requestJSONStub.bodyIs { counter, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(tokenStatus.toSuccessfulResponse))
                tokenStatus = PaymentTokenStatus(status: .consumed)
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.clearStub.callCounter, 2)
        XCTAssertEqual(apiService.requestJSONStub.callCounter, 2)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenTokenStatusPending() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status pending
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 4)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        var tokenStatus = PaymentTokenStatus(status: .pending)
        apiService.requestJSONStub.bodyIs { counter, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(tokenStatus.toSuccessfulResponse))
                tokenStatus = PaymentTokenStatus(status: .consumed)
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.clearStub.callCounter, 1)
        XCTAssertEqual(apiService.requestJSONStub.callCounter, 2)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.pendingRetryStub.getWasCalled)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenSubscriptionFails() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(["Code": 22000]))
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestJSONStub.callCounter, 2)
    }

    func testPurchaseContinuationWhenApiMightBeBlocked() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .failure(.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: PSTranslation._core_api_might_be_blocked_message.l10n)))
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestJSONStub.callCounter, 2)
    }

    func testPurchaseContinuationWhenSubscriptionFailsAmountMismatchCreditsAppliedSuccess() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with amount mismatch 22101
        // Expected: Success

        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 1000]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.resolvingIAPToCreditsCausedByError) = returnedResult else { XCTFail(); return }
        }
    }

    func testPurchaseContinuationWhenSubscriptionFailsAmountMismatchCreditsAppliedAlreadyPurchased() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with amount mismatch 22101
        // 3. Fail credits with already purchased 22916
        // Expected: Success

        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 15)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 22916]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = {
                returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
        }
    }

    func testPurchaseContinuationWhenSubscriptionFailsAmountMismatchCreditsAppliedError() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with amount mismatch 22101
        // 2. Fail credits call with random error
        // Expected: Retry

        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 18)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 424242]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            alertManagerMock.showAlertStub.bodyIs { _, _, _ in
                expectation.fulfill()
            }

            // when
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
        }
    }

    func testPurchaseContinuationWhenSubscriptionFailsAmountMismatchCreditsAppliedErrorWithDynamicPlans() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with amount mismatch 22101
        // 2. Fail credits call with random error
        // Expected: Retry

        withFeatureFlags([.dynamicPlans]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 24)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 424242]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            alertManagerMock.showAlertStub.bodyIs { _, _, _ in
                expectation.fulfill()
            }

            // when
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 2)
        }
    }

    func testPurchaseContinuationWhenSubscriptionFailsPlanUnavailableCreditsAppliedSuccess() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with plan unavailable 2001
        // Expected: Success

        withFeatureSwitches([]) {

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 1)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 2001]))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 1000]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.resolvingIAPToCreditsCausedByError) = returnedResult else { XCTFail(); return }
        }
    }

    func testPurchaseContinuationWhenSubscriptionFailsPlanUnavailableCreditsAppliedAlreadyPurchased() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with plan unavailable 2001
        // 3. Fail credits with already purchased 22916
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(["Code": 2001]))
            } else if path.contains("/credit") {
                completion(nil, .success(["Code": 22916]))
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenSubscriptionFailsPlanUnavailableCreditsAppliedError() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase with plan unavailable 2001
        // 2. Fail credits with random error
        // Expected: Retry
        withFeatureSwitches([]) {

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 2001]))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 424242]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }
            alertManagerMock.showAlertStub.bodyIs { _, _, _ in
                expectation.fulfill()
            }

            // when
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
        }
    }

    func testPurchaseContinuationWithoutStoredTokenFailure() {
        withFeatureFlags([.dynamicPlans]){ // remove enclosure with CP-6369
            // Test scenario:
            // 1. Continue transaction after signup without stored token
            // 2. Fail token request
            // Expected: Retry

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }
            alertManagerMock.showAlertStub.bodyIs { _, _, _ in
                expectation.fulfill()
            }

            // when
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 1)
        }
    }

    func testPurchaseContinuationWithoutStoredTokenSuccess() {
        withFeatureFlags([.dynamicPlans]){ // remove enclosure with CP-6369
            // Test scenario:
            // 1. Continue transaction after signup without stored token
            // Expected: Success

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 9)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            let testSubscriptionDict = self.testSubscriptionDict
            paymentTokenStorageMock.getStub.bodyIs { counter in
                switch counter {
                case 1: return nil
                case 2...3: return PaymentToken(token: "test token", status: .chargeable)
                default: XCTFail(); return nil
                }
            }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(testSubscriptionDict))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
            var returnedSubscription: Subscription?
            processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertEqual(returnedSubscription?.couponCode, "test code")
            XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            XCTAssertTrue(paymentTokenStorageMock.addStub.wasCalledExactlyOnce)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            guard case .finished(.resolvingIAPToSubscription) = returnedResult else { XCTFail(); return }
        }
    }

    // Remove the following tests when CP-6369 comes around

    func testSubscriptionSuccessWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 5)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutExchangingToken(let paymentToken)) = returnedResult else { XCTFail(); return }
            XCTAssertEqual(paymentToken.token, "test token")
            XCTAssertEqual(paymentToken.status, .chargeable)
        }
    }

    func testSubscriptionTokenRequestFailWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // 2. Fail token request
            // Expected: transaction added to transactionsBeforeSignupStub and token storage cleared

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 1)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusRequestFailWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // 2. Fail token status request
            // Expected: transaction added to transactionsBeforeSignupStub and payment token cleared

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 2)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(["Code": 22000]))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusConsumedWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status consumed
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .consumed).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusFailedWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status failed
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .failed).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusNotSupportedWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status failed
            // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 2)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .notSupported).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }

    func testSubscriptionTokenStatusPendingWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Process transaction
            // 2. Return token status pending
            // Expected: transaction processing is retried

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 9)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            var tokenStatusToReturn = PaymentTokenStatus(status: .pending)
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(tokenStatusToReturn.toSuccessfulResponse))
                    tokenStatusToReturn = PaymentTokenStatus(status: .chargeable)
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(processDependencies.getReceiptStub.callCounter, 1)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 3)
            guard case .finished(.withoutExchangingToken(let paymentToken)) = returnedResult else { XCTFail(); return }
            XCTAssertEqual(paymentToken.token, "test token")
            XCTAssertEqual(paymentToken.status, .chargeable)
        }
    }

    func testPurchaseContinuationWithoutStoredTokenFailureWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Continue transaction after signup without stored token
            // 2. Fail token request
            // Expected: Retry

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }
            alertManagerMock.showAlertStub.bodyIs { _, _, _ in
                expectation.fulfill()
            }

            // when
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(apiService.requestJSONStub.callCounter, 1)
        }
    }

    func testPurchaseContinuationWithoutStoredTokenSuccessWithoutSubscriptionsFF() {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Continue transaction after signup without stored token
            // Expected: Success

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            let testSubscriptionDict = self.testSubscriptionDict
            paymentTokenStorageMock.getStub.bodyIs { counter in
                switch counter {
                case 1: return nil
                case 2: return PaymentToken(token: "test token", status: .chargeable)
                default: XCTFail(); return nil
                }
            }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(testSubscriptionDict))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
            var returnedSubscription: Subscription?
            processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertEqual(returnedSubscription?.couponCode, "test code")
            XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
            XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
            XCTAssertTrue(paymentTokenStorageMock.addStub.wasCalledExactlyOnce)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            guard case .finished(.resolvingIAPToSubscription) = returnedResult else { XCTFail(); return }
        }
    }

    func testExistingTokenIsChargableNoNewTokenIsFetched() {
        withFeatureFlags([.dynamicPlans]) {
            // Remove enclosure with CP-6369
            // Test scenario:
            // 1. Stored token is chargable
            // 2. Existing token is used.
            // Expected: No API call to get new token is made.

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
            let out = ProcessUnauthenticated(dependencies: processDependencies)
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "existing test token", status: .chargeable) }
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(["Code": 22000]))
                } else if path.contains("/tokens") {
                    XCTFail("New token should not be fetched")
                    completion(nil, .success(PaymentToken(token: "new test token", status: .chargeable).toSuccessfulResponse))
                } else {
                    XCTFail(); completion(nil, .success([:]))
                }
            }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertTrue(paymentTokenStorageMock.getStub.wasCalled)
            guard case .finished(.withoutObtainingToken) = returnedResult else { XCTFail(); return }
        }
    }
}
