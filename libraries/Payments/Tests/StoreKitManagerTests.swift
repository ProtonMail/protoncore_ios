//
//  StoreKitManagerTests.swift
//  ProtonCore-Payments-Tests - Created on 21/12/2020.
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
// swiftlint:disable weak_delegate

import XCTest
import StoreKit

import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class StoreKitManagerTests: XCTestCase {

    var storeKitManager: StoreKitManager!
    let testApi = PMAPIService(doh: TestDoHMail.default, sessionUID: "testSessionUID")
    var authCredential: AuthCredential?
    var userInfo: UserInfo?
    let testAuthDelegate = TestAuthDelegate()
    let testAPIServiceDelegate = TestAPIServiceDelegate()
    let tokenStorage = TokenStorage.default
    let userCachedStatus = UserCachedStatus()
    var testStoreKitManagerDelegate: TestStoreKitManagerDelegate!
    var servicePlan: ServicePlanDataService!
    let servicePlansMock = ServicePlansMock()
    let paymentsApi = PaymentsApiMock()
    let alertManagerMock = AlertManagerMock()
    let paymentsQueue = SKPaymentQueueMock()
    let timeout = 10.0
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // setup testApi
        TestDoHMail.default.status = .off
        testApi.authDelegate = testAuthDelegate
        testApi.serviceDelegate = testAPIServiceDelegate
        PMAPIService.noTrustKit = true
        
        // Setup Service plan data service
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        servicePlan.paymentsApi = paymentsApi
        servicePlan.updateServicePlans {
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        // setup StoreKitmanager
        storeKitManager = StoreKitManager.default
        storeKitManager.alertViewDelay = 0.1
        tokenStorage.clear()
        testStoreKitManagerDelegate = TestStoreKitManagerDelegate(api: testApi, tokenStorage: tokenStorage, servicePlanDataService: servicePlan)
        testStoreKitManagerDelegate._userId = "12345"
        testStoreKitManagerDelegate._activeUsername = "Test User"
        storeKitManager.receiptError = nil
        storeKitManager.delegate = testStoreKitManagerDelegate
        
        // Payment API configuration
        configureStoreKit()
    }
    
    func configureStoreKit() {
        storeKitManager.paymentQueue = paymentsQueue
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKitManager.updateAvailableProductsList()
        storeKitManager.paymentsAlertManager = PaymentsAlertManager(alertManager: alertManagerMock)
        storeKitManager.pendingRetryIn = 0.1
        
        storeKitManager.paymentsApi = paymentsApi
        paymentsApi.subscriptionRequestAnswer = .free
        paymentsApi.creditAnswer = .success
        paymentsApi.tokenAnswer = .success
        paymentsApi.tokenStatusAnswer = .chargeable
        paymentsApi.validateSubscription = .success(amountDue: 4800)
        paymentsApi.subscriptionAnswer = .success
    }
    
    func testPurchaseWithoutAvailableProducts() throws {
        /// Test scenario:
        /// 1. Do purchase
        /// Expected: Error: Errors.unavailableProduct

        // remove available products
        storeKitManager.availableProducts = []
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // purchase (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.unavailableProduct)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTransactionStateFailed() throws {
        /// Test scenario:
        /// 1. Simulate transaction state = failed
        /// 2. Do purchase
        /// Expected: Error: Errors.transactionFailedByUnknownReason

        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate failed state (1)
        paymentsQueue.transactionState = .failed

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.transactionFailedByUnknownReason)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTransactionStateDeferred() throws {
        /// Test scenario:
        /// 1. Simulate transaction state = deferred
        /// 2. Do purchase
        /// Expected: deferredCompletion

        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate deferred state (1)
        paymentsQueue.transactionState = .deferred

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTFail()
        } deferredCompletion: {
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTransactionStatePurchasing() throws {
        /// Test scenario:
        /// 1. Simulate transaction state = purchasing
        /// 2. Do purchase
        /// Expected: deferredCompletion

        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate purchasing state (1)
        paymentsQueue.transactionState = .purchasing

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTFail()
        } deferredCompletion: {
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTransactionStateFailedErrorPaymentCancelled() throws {
        /// Test scenario:
        /// 1. Simulate transaction state = faild with error SKError.paymentCancelled
        /// 2. Do purchase
        /// Expected: Error: Errors.cancelled

        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate failed state (1)
        paymentsQueue.transactionState = .failed
        paymentsQueue.error = NSError(domain: "test domain", code: SKError.paymentCancelled.rawValue, localizedDescription: "test description")

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.cancelled)
            expectation2.fulfill()
        } deferredCompletion: {
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testTransactionStateFailedErrorPaymentOther() throws {
        /// Test scenario:
        /// 1. Simulate transaction state = faild with error Errors.transactionFailedByUnknownReason
        /// 2. Do purchase
        /// Expected: Error: Errors.transactionFailedByUnknownReason

        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate failed state (1)
        paymentsQueue.transactionState = .failed
        paymentsQueue.error = StoreKitManager.Errors.transactionFailedByUnknownReason

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.transactionFailedByUnknownReason)
            expectation2.fulfill()
        } deferredCompletion: {
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTransactionStatePurchasedLocked() throws {
        /// Test scenario:
        /// 1. Locked app
        /// 2. Do purchase
        /// Expected: Error: Errors.appIsLocked

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // StoreKitManagerDelegate configuration
        testStoreKitManagerDelegate._isUnlocked = false // (1)

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate failed state
        paymentsQueue.transactionState = .purchased

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.appIsLocked)
            expectation2.fulfill()
        } deferredCompletion: {
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testTransactionStatePurchasedSignedOut() throws {
        /// Test scenario:
        /// 1.App not sign in
        /// 2. Do purchase
        /// Expected: Error: Errors.pleaseSignIn

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // StoreKitManagerDelegate configuration
        testStoreKitManagerDelegate._isSignedIn = false // (1)

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")
        
        // simulate failed state
        paymentsQueue.transactionState = .purchased

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.pleaseSignIn)
            expectation2.fulfill()
        } deferredCompletion: {
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testTransactionStatePurchasedNoHashedUsername() throws {
        /// Test scenario:
        /// 1. Don't allow to launch SKPaymentTransactionObserver
        /// 2. Do purchase
        /// 3. Change user Id
        /// 4. Launch SKPaymentTransactionObserver
        /// Expected: Seccess: Purchased product

        let expectation1 = self.expectation(description: "Success completion block called")

        // SKPaymentQueue configuration
        paymentsQueue.transactionState = .purchased
        paymentsQueue.fire = false // (1)

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        testStoreKitManagerDelegate._userId = "232434" // (3)
        paymentsQueue.fire = true // (4)
        
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTransactionStatePurchasedNoActiveUsername() throws {
        /// Test scenario:
        /// 1. Don't allow to launch SKPaymentTransactionObserver
        /// 2. Do purchase
        /// 3. Set user Id to nil
        /// 4. Launch SKPaymentTransactionObserver
        /// Expected: Error: noActiveUsername

        let expectation1 = self.expectation(description: "Success completion block called")

        // SKPaymentQueue configuration
        paymentsQueue.transactionState = .purchased
        paymentsQueue.fire = false // (1)

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.noActiveUsername)
            expectation2.fulfill()
        }
        storeKitManager.paymentInternalCompletionStarted = {
            self.testStoreKitManagerDelegate._userId = nil // (3)
            self.paymentsQueue.fire = true // (4)
        }
        
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testReceiptLost() throws {
        /// Test scenario:
        /// 1. ReceiptError = receiptLost
        /// 2. Do purchase
        /// Expected: Error: Errors.appIsLocked

        let expectation1 = self.expectation(description: "Success completion block called")

        // SKPaymentQueue, StoreKitManager configuration
        paymentsQueue.transactionState = .purchased
        storeKitManager.receiptError = StoreKitManager.Errors.receiptLost // (1)

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.receiptLost)
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testNoNewSubscriptionInSuccessfullResponse() throws {
        /// Test scenario:
        /// 1. subscriptionAnswer = successWithNoSubscription
        /// 2. Do purchase
        /// Expected: Error: Errors.noNewSubscriptionInSuccessfullResponse

        let expectation1 = self.expectation(description: "Success completion block called")

        // SKPaymentQueue, PaymentsApiProtocol, StoreKitManager configuration
        paymentsQueue.transactionState = .purchased
        paymentsApi.subscriptionAnswer = .successWithNoSubscription // (1)
        storeKitManager.receiptError = nil

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let expectation2 = self.expectation(description: "Success completion block called")

        // purchase (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.noNewSubscriptionInSuccessfullResponse)
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

}
