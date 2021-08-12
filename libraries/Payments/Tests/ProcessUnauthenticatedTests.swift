//
//  ProcessAuthenticatedTests.swift
//  ProtonCore-Payments-Tests - Created on 26/12/2020.
//
//  Copyright (c) 2020 Proton Technologies AG
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
import ProtonCore_TestingToolkit
import ProtonCore_Networking
@testable import ProtonCore_Payments

final class ProcessUnauthenticatedTests: XCTestCase {

    let timeout = 1.0

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
        // Test scenario:
        // 1. Process transaction
        // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .paymentToken(let paymentToken) = returnedResult else { XCTFail(); return }
        XCTAssertEqual(paymentToken.token, "test token")
        XCTAssertEqual(paymentToken.status, .chargeable)
    }

    func testSubscriptionReceiptError() {
        // Test scenario:
        // 1. Throw error when getting the receipt
        // Expected: Error is thrown

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        processDependencies.getReceiptStub.bodyIs { _ in throw NSError(domain: "test error", code: 42, userInfo: nil) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedError: Error?
        do {
            try out.process(transaction: transaction, plan: plan) { _ in XCTFail() }
        } catch {
            returnedError = error
        }

        // then
        XCTAssertEqual((returnedError as NSError?), NSError(domain: "test error", code: 42, userInfo: nil))
    }

    func testSubscriptionTokenRequestFail() {
        // Test scenario:
        // 1. Process transaction
        // 2. Fail token request
        // Expected: transaction added to transactionsBeforeSignupStub and token storage cleared

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, ["Code": 22000], nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testSubscriptionTokenStatusRequestFail() {
        // Test scenario:
        // 1. Process transaction
        // 2. Fail token status request
        // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, ["Code": 22000], nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testSubscriptionTokenStatusConsumed() {
        // Test scenario:
        // 1. Process transaction
        // 2. Return token status consumed
        // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .consumed).toSuccessfulResponse, nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testSubscriptionTokenStatusFailed() {
        // Test scenario:
        // 1. Process transaction
        // 2. Return token status failed
        // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .failed).toSuccessfulResponse, nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testSubscriptionTokenStatusNotSupported() {
        // Test scenario:
        // 1. Process transaction
        // 2. Return token status failed
        // Expected: transaction added to transactionsBeforeSignupStub and payment token returned

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .notSupported).toSuccessfulResponse, nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .consumed).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.addTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.addTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testSubscriptionTokenStatusPending() {
        // Test scenario:
        // 1. Process transaction
        // 2. Return token status pending
        // Expected: transaction processing is retried

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        processDependencies.getReceiptStub.bodyIs { _ in "test receipt" }
        var tokenStatusToReturn = PaymentTokenStatus(status: .pending)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, tokenStatusToReturn.toSuccessfulResponse, nil)
                tokenStatusToReturn = PaymentTokenStatus(status: .chargeable)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(processDependencies.getReceiptStub.callCounter, 1)
        XCTAssertEqual(apiService.requestStub.callCounter, 3)
        guard case .paymentToken(let paymentToken) = returnedResult else { XCTFail(); return }
        XCTAssertEqual(paymentToken.token, "test token")
        XCTAssertEqual(paymentToken.status, .chargeable)
    }

    func testPurchaseContinuationWhenAmountDueIsAmount() {
        // Test scenario:
        // 1. Continue transaction after signup
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/subscription") {
                completion?(nil, testSubscriptionDict, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }
        var returnedSubscription: Subscription?
        processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual(returnedSubscription?.couponCode, "test code")
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenAmountDueIsDifferentThanAmount() {
        // Test scenario:
        // 1. Continue transaction after signup with amount due different then amount
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 10)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        var returnedParameters: Any?
        apiService.requestStub.bodyIs { _, _, path, parameters, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/credit") {
                completion?(nil, testSubscriptionDict, nil)
            } else if path.contains("/subscription") {
                returnedParameters = parameters
                completion?(nil, testSubscriptionDict, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }
        var returnedSubscription: Subscription?
        processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual(returnedSubscription?.couponCode, "test code")
        XCTAssertEqual((returnedParameters as? [String: Any])?["Amount"] as? Int, 0) // buy for zero!
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenTokenStatusFailBecauseOfNetworkError() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail token status request with network error
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, ["Code": 3500], nil) // tls
            } else { XCTFail(); completion?(nil, nil, nil) }
        }

        // when
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }

        // then
        XCTAssertTrue(alertManagerMock.showAlertStub.wasCalledExactlyOnce)
    }

    func testPurchaseContinuationWhenTokenStatusFailBecauseOfErrorOtherThanNetwork() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail token status request with non-network error
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        var tokenResponse = ["Code": 22000]
        apiService.requestStub.bodyIs { counter, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, tokenResponse, nil)
                tokenResponse = ["Code": 3500]
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestStub.callCounter, 2)
    }

    func testPurchaseContinuationWhenTokenStatusNotSupported() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status not supported
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { counter, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .notSupported).toSuccessfulResponse, nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }

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
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { counter, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .consumed).toSuccessfulResponse, nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenTokenStatusFailed() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status failed
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        var tokenStatus = PaymentTokenStatus(status: .failed)
        apiService.requestStub.bodyIs { counter, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, tokenStatus.toSuccessfulResponse, nil)
                tokenStatus = PaymentTokenStatus(status: .consumed)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.clearStub.callCounter, 2)
        XCTAssertEqual(apiService.requestStub.callCounter, 2)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenTokenStatusPending() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Return token status pending
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let expectation = self.expectation(description: "Completion block called")
        var tokenStatus = PaymentTokenStatus(status: .pending)
        apiService.requestStub.bodyIs { counter, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, tokenStatus.toSuccessfulResponse, nil)
                tokenStatus = PaymentTokenStatus(status: .consumed)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.clearStub.callCounter, 1)
        XCTAssertEqual(apiService.requestStub.callCounter, 2)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(processDependencies.pendingRetryStub.getWasCalled)
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testPurchaseContinuationWhenSubscriptionFails() {
        // Test scenario:
        // 1. Continue transaction after signup
        // 2. Fail subscription purchase
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/subscription") {
                completion?(nil, ["Code": 22000], nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestStub.callCounter, 2)
    }

    func testPurchaseContinuationWithoutStoredTokenFailure() {
        // Test scenario:
        // 1. Continue transaction after signup without stored token
        // 2. Fail token request
        // Expected: Retry

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessUnauthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, ["Code": 22000], nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }
        alertManagerMock.showAlertStub.bodyIs { _, _, _ in
            expectation.fulfill()
        }

        // when
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { _ in XCTFail() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(apiService.requestStub.callCounter, 1)
    }

    func testPurchaseContinuationWithoutStoredTokenSuccess() {
        // Test scenario:
        // 1. Continue transaction after signup without stored token
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
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
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/tokens") {
                completion?(nil, PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/subscription") {
                completion?(nil, testSubscriptionDict, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }
        var returnedSubscription: Subscription?
        processDependencies.updateSubscriptionStub.fixture = { returnedSubscription = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        try! out.processAuthenticatedBeforeSignup(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual(returnedSubscription?.couponCode, "test code")
        XCTAssertTrue(processDependencies.removeTransactionsBeforeSignupStub.wasCalledExactlyOnce)
        XCTAssertEqual(processDependencies.removeTransactionsBeforeSignupStub.lastArguments?.a1, transaction)
        XCTAssertTrue(paymentTokenStorageMock.addStub.wasCalledExactlyOnce)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished = returnedResult else { XCTFail(); return }
    }
}
