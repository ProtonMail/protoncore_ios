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

final class ProcessAuthenticatedTests: XCTestCase {

    let timeout = 1.0

    let queue = DispatchQueue.global(qos: .userInitiated)

    var apiService: APIServiceMock!
    var paymentsApi: PaymentsApiMock!
    var processDependencies: ProcessDependenciesMock!
    // swiftlint:disable:next weak_delegate
    var storeKitManagerDelegate: StoreKitManagerDelegateMock!
    var paymentTokenStorageMock: PaymentTokenStorageMock!

    let payment = SKPayment(product: SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: .current))

    var testSubscriptionDict: [String: Any] {
        [
            "Code": 1000,
            "Subscription": [
                "PeriodStart": 0,
                "PeriodEnd": 0,
                "CouponCode": "test code",
                "Cycle": 12,
                "Plans": []
            ]
        ]
    }

    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
        paymentsApi = PaymentsApiMock()
        storeKitManagerDelegate = StoreKitManagerDelegateMock()
        paymentTokenStorageMock = PaymentTokenStorageMock()
        processDependencies = ProcessDependenciesMock()
        processDependencies.apiServiceStub.fixture = apiService
        processDependencies.paymentsApiProtocolStub.fixture = paymentsApi
        processDependencies.storeKitDelegateStub.fixture = storeKitManagerDelegate
        processDependencies.tokenStorageStub.fixture = paymentTokenStorageMock
    }

    func testBuyAlreadyConsumed() {
        // Test scenario:
        // 1. Do purchase with already consumed token
        // Expected: Finished, purchase already processed

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(PaymentTokenStatus(status: .consumed).toSuccessfulResponse))
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
        guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }
    }

    func testBuyFailed() {
        // Test scenario:
        // 1. Do purchase with failed token
        // Expected: Error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(PaymentTokenStatus(status: .failed).toSuccessfulResponse))
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.finishTransactionStub.getCallCounter == 0)
        guard case .errored(.wrongTokenStatus(.failed)) = returnedResult else { XCTFail(); return }
    }

    func testBuyNotSupported() {
        // Test scenario:
        // 1. Do purchase with not supported token
        // Expected: Error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(PaymentTokenStatus(status: .notSupported).toSuccessfulResponse))
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.finishTransactionStub.getCallCounter == 0)
        guard case .errored(.wrongTokenStatus(.notSupported)) = returnedResult else { XCTFail(); return }
    }

    func testBuyChargeableWhenAmountDueIsTheSameAsAmount() {
        // Test scenario:
        // 1. Do purchase chargeable token when amountDue is amount
        // Expected: Finished, resolved to subscription

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in
            return success()
        }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(testSubscriptionDict))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished(.resolvingIAPToSubscription) = returnedResult else { XCTFail(); return }
        guard case .finished(.resolvingIAPToSubscription) = processCompletionResult else { XCTFail(); return }
    }

    func testBuyChargeableWhenAmountDueIsTheSameAsAmountUpdateSubscriptionFailed() {
        // Test scenario:
        // 1. Do purchase chargeable token when amountDue is amount, but updateCurrentSubscription fails
        // Expected: Finished, resolving to IAP Subscription. Apparently refreshing the subscription is not important

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in
            let error = NSError(domain: "error", code: 2500, userInfo: nil)
            return fail(error)
        }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(testSubscriptionDict))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
        var returnedSubscription: Subscription?
        processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual(returnedSubscription?.couponCode, "test code")
        guard case .finished(.resolvingIAPToSubscription) = returnedResult else { XCTFail(); return }
        guard case .finished(.resolvingIAPToSubscription) = processCompletionResult else { XCTFail(); return }
    }

    func testBuyChargeableWhenAmountDueIsDifferentThanAmount_CausesError() {
        // Test scenario:
        // 1. Do purchase chargeable token when amountDue is not amount
        // Expected: Success .resolvingIAPToSubscription (why??)

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 80)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        var returnedParameters: Any?
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in
            return success()
        }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(testSubscriptionDict))
            } else if path.contains("/subscription") {
                returnedParameters = parameters
                completion(nil, .failure(NSError(domain: "error", code: 2500, userInfo: nil)))
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) {
                returnedResult = $0; expectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual((returnedParameters as? [String: Any])?["Amount"] as? Int, 0) // buy for zero!
        guard case .erroredWithUnspecifiedError = returnedResult else { XCTFail(); return }
        guard case .erroredWithUnspecifiedError = processCompletionResult else { XCTFail(); return }
    }

    func testRetryProcessForPending() {
        // Test scenario:
        // 1. Do purchase pending token
        // Expected: Success .withPurchaseAlreadyProcessed

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 80)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .pending) }
        var processCompletionResult: ProcessCompletionResult?
                processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
        var tokenToReturn = PaymentTokenStatus(status: .pending)
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(tokenToReturn.toSuccessfulResponse))
                tokenToReturn = PaymentTokenStatus(status: .consumed)
            } else {
                XCTFail(); completion(nil, .success([:]))
            }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
        guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }

    }

    // Remove with CP-6369
    func testBuyPlanSubscriptionOldTokenErrorSandbox() {
        withFeatureSwitches([]){
            // Test scenario:
            // 1. Token answer - errorSandboxReceipt
            // 2. Do purchase
            // Expected: Error: errorSandboxReceipt

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22914]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }

            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            guard case .erroredWithUnspecifiedError(let returnedError) = returnedResult else { XCTFail(); return }
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22914)
            guard case .erroredWithUnspecifiedError(let returnedError) = processCompletionResult else { XCTFail(); return }
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22914)
        }
    }

    func testBuyPlanSubscriptionTokenErrorSandbox() {
        withFeatureSwitches([.subscriptions]) { // Remove enclosure with CP-6369
            // Test scenario:
            // 1. Token answer - errorSandboxReceipt
            // 2. Do purchase
            // Expected: Error: errorSandboxReceipt

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22914]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }

            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            guard case .erroredWithUnspecifiedError(let returnedError) = returnedResult else { XCTFail(); return }
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22914)
            guard case .erroredWithUnspecifiedError(let returnedError) = processCompletionResult else { XCTFail(); return }
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22914)
        }
    }

    // Remove with CP-6369
    func testBuyPlanSubscriptionOldTokenErrorAlreadyRegistered() {
        withFeatureSwitches([]){
            // Test scenario:
            // 1. Token answer - errorAlreadyRegistered
            // 2. Do purchase
            // Expected: Success .withPurchaseAlreadyProcessed

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22916]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }

            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
            guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionTokenErrorAlreadyRegistered() {
        withFeatureSwitches([.subscriptions]){ // Remove enclosure with CP-6369
            // Test scenario:
            // 1. Token answer - errorAlreadyRegistered
            // 2. Do purchase
            // Expected: Success .withPurchaseAlreadyProcessed

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22916]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }

            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
            guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
            guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }
        }
    }

    // Remove with CP-6369
    func testBuyPlanSubscriptionOldTokenError() {
        withFeatureSwitches([]){
            // Test scenario:
            // 1. Token answer - error
            // 2. Do purchase
            // Expected: Error: error

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }

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
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22000)
        }
    }

    func testBuyPlanSubscriptionTokenError() {
        withFeatureSwitches([.subscriptions]){ // remove enclosure with CP-6369
            // Test scenario:
            // 1. Token answer - error
            // 2. Do purchase
            // Expected: Error: error

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }

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
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22000)
        }
    }

    func testBuyPlanSubscriptionError() {
        // Test scenario:
        // 1. SubscriptionAnswer set error
        // 2. Do purchase
        // Expected: Error: error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .success(["Code": 22000]))
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)

        guard case .erroredWithUnspecifiedError = processCompletionResult else { XCTFail(); return }
        guard case .erroredWithUnspecifiedError(let error) = returnedResult else { XCTFail(); return }
        XCTAssertEqual((error as? ResponseError)?.responseCode, 22000)
    }

    func testBuyPlanSubscriptionApiIsBlockedError() {
        // Test scenario:
        // 1. SubscriptionAnswer set error
        // 2. Do purchase
        // Expected: Error: error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/subscription") {
                completion(nil, .failure(.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: PSTranslation._core_api_might_be_blocked_message.l10n)))
            } else { XCTFail(); completion(nil, .success([:])) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        guard case .erroredWithUnspecifiedError(StoreKitManagerErrors.apiMightBeBlocked) = returnedResult else { XCTFail(); return }
    }

    func testBuyPlanSubscriptionPaymentAmmountMismatchSuccess() {
        // Test scenario:
        // 1. SubscriptionAnswer set error
        // 2. Do purchase
        // Expected: Success .resolvingIAPToCreditsCausedByError
        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            let testSubscriptionDict = self.testSubscriptionDict
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/credit") {
                    completion(nil, .success(testSubscriptionDict))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .finished(.resolvingIAPToCreditsCausedByError) = returnedResult else { XCTFail(); return }
            guard case .finished(.resolvingIAPToCreditsCausedByError) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionPaymentAmountMismatchErrorRegisteredWithDynamicPlans() {
        // Test scenario:
        // 1. SubscriptionAnswer set error
        // 2. Do purchase
        // Expected: Success .resolvingIAPToCreditsCausedByError

        withFeatureFlags([.dynamicPlans]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = returnedResult else { XCTFail(); return }
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionCreditErrorAmountMismatchErrorRegistered() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - errorAmountMismatchCode (22101)
        // 3. Do purchase
        // 4. CreditAnswer - errorAlredyRegistered (22916)
        // Expected: Success .withPurchaseAlreadyProcessed

        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 22916]))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
            guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionCreditErrorAmountMismatchErrorRegisteredWithDynamicPlans() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - errorAmountMismatchCode (22101)
        // 3. Do purchase
        // 4. CreditAnswer - errorAlredyRegistered (22916)
        // Expected: Success .withPurchaseAlreadyProcessed
        withFeatureFlags([.dynamicPlans]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = returnedResult else { XCTFail(); return }
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionCreditErrorAmountMismatchSuccess() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - errorAmountMismatchCode (22101)
        // 3. Do purchase
        // 4. CreditAnswer - success
        // Expected: Success .resolvingIAPToCreditsCausedByError

        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 1000]))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .finished(.resolvingIAPToCreditsCausedByError) = returnedResult else { XCTFail(); return }
            guard case .finished(.resolvingIAPToCreditsCausedByError) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionCreditErrorAmountMismatchSuccessWithDynamicPlans() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - errorAmountMismatchCode (22101)
        // 3. Do purchase
        // 4. CreditAnswer - success
        // Expected: error

        withFeatureFlags([.dynamicPlans]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 22101]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = returnedResult else { XCTFail(); return }
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionAddCreditsOnPlanUnavailableAlreadyRegistered() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - plan unavailable (2001)
        // 3. Do purchase
        // 4. CreditAnswer - errorAlredyRegistered (22916)
        // Expected: success .withPurchaseAlreadyProcessed

        withFeatureSwitches([]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 22916]))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 2001]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
            guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionAddCreditsOnPlanUnavailableAlreadyRegisteredWithDynamicPlans() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - plan unavailable (2001)
        // 3. Do purchase
        // 4. CreditAnswer - errorAlredyRegistered (22916)
        // Expected: success .withPurchaseAlreadyProcessed

        withFeatureFlags([.dynamicPlans]) {
            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 2001]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = returnedResult else { XCTFail(); return }
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionAddCreditsOnPlanUnavailableSuccess() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - plan unavailable (2001)
        // 3. Do purchase
        // 4. CreditAnswer - success
        // Expected: success .resolvingIAPToCreditsCausedByError

        // given
        withFeatureSwitches([]) {
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/credit") {
                    completion(nil, .success(["Code": 1000]))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 2001]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .finished(.resolvingIAPToCreditsCausedByError) = returnedResult else { XCTFail(); return }
            guard case .finished(.resolvingIAPToCreditsCausedByError) = processCompletionResult else { XCTFail(); return }
        }
    }

    func testBuyPlanSubscriptionAddCreditsOnPlanUnavailableSuccessWithDynamicPlans() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - plan unavailable (2001)
        // 3. Do purchase
        // 4. CreditAnswer - success
        // Expected: success .resolvingIAPToCreditsCausedByError

        // given
        withFeatureFlags([.dynamicPlans]) {
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
            let out = ProcessAuthenticated(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
            var processCompletionResult: ProcessCompletionResult?
            processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/subscription") {
                    completion(nil, .success(["Code": 2001]))
                } else { XCTFail(); completion(nil, .success([:])) }
            }
            var returnedTransaction: SKPaymentTransaction?
            processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

            // when
            var returnedResult: ProcessCompletionResult?
            queue.async {
                try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(returnedTransaction, transaction)
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = returnedResult else { XCTFail(); return }
            guard case .errored(.noNewSubscriptionInSuccessfulResponse) = processCompletionResult else { XCTFail(); return }
        }
    }
}
