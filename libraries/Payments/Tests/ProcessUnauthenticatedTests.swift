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
// swiftlint:disable weak_delegate

import XCTest

import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class ProcessUnauthenticatedTests: XCTestCase {

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
        tokenStorage.clear()
        testStoreKitManagerDelegate = TestStoreKitManagerDelegate(api: testApi, tokenStorage: tokenStorage, servicePlanDataService: servicePlan)
        testStoreKitManagerDelegate._userId = "12345"
        testStoreKitManagerDelegate._activeUsername = "Test User"
        storeKitManager.delegate = testStoreKitManagerDelegate
        
        // Payment API configuration
        configureStoreKit()
        testStoreKitManagerDelegate._userId = nil
        testStoreKitManagerDelegate._activeUsername = nil
    }
    
    func configureStoreKit() {
        paymentsQueue.transactionState = .purchased
        storeKitManager.paymentQueue = paymentsQueue
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKitManager.updateAvailableProductsList()
        storeKitManager.paymentsAlertManager = PaymentsAlertManager(alertManager: alertManagerMock)
        storeKitManager.pendingRetryIn = 0.2
        
        storeKitManager.paymentsApi = paymentsApi
        paymentsApi.subscriptionRequestAnswer = .free
        paymentsApi.creditAnswer = .success
        paymentsApi.tokenAnswer = .success
        paymentsApi.tokenStatusAnswer = .chargeable
        paymentsApi.validateSubscription = .success(amountDue: 4800)
        paymentsApi.subscriptionAnswer = .success
    }

    // MARK: Diagram: Sign-up payment flow (starting with iOS 2.3.2)
    
    func testSubscriptionSuccess() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Continue payment
        /// Expected: Success purchase

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"
        
        let expectation2 = self.expectation(description: "Finish completion block called")
        
        // continue purchase (3)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionPurchasingPurchasedSuccess() throws {
        /// Test scenario:
        /// 1. Change transactionState to purchasing (show Apple dialog)
        /// 2. Get payment token
        /// 3. On deferredCompletion change state to purchased and continue purchasing (confirm Apple dialog)
        /// 4. Login
        /// 5. Continue payment
        /// Expected: Success purchase

        let expectation1 = self.expectation(description: "Success completion block called")
        let expectation2 = self.expectation(description: "Deferred completion block called")
        
        // SKPaymentQueue configuration
        paymentsQueue.transactionState = .purchasing // (1)
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        } deferredCompletion: {
            self.paymentsQueue.continueWithOtherState(state: .purchased) // (3)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        // user info after login (4)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"
        
        let expectation3 = self.expectation(description: "Finish completion block called")
        
        // continue purchase (5)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation3.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionSuccessRemovedToken() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Remove token
        /// 4. Continue payment
        /// Expected: Success purchase

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"
        
        // remove token (3)
        tokenStorage.clear()
        
        let expectation2 = self.expectation(description: "Finish completion block called")
        
        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionTransactionStateFailed() throws {
        /// Test scenario:
        /// 1. Change transactionState to failed
        /// 2. Get payment token
        /// Expected: Errors.transactionFailedByUnknownReason

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // SKPaymentQueue configuration
        paymentsQueue.transactionState = .failed // (1)
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.transactionFailedByUnknownReason)
            expectation1.fulfill()
        } deferredCompletion: {
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
   
    func testSubscriptionTokenError() throws {
        /// Test scenario:
        /// 1. Change tokenAnswer to error
        /// 2. Get payment token
        /// Sucess: Success with nil token

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenAnswer = .error(22123) // (1)
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testSubscriptionTokenStatusPendingPendingChargable() throws {
        /// Test scenario:
        /// 1. Change tokenStatusAnswer to pending
        /// 2. Get payment token
        /// 3. Change tokenStatusAnswer to pending
        /// 4. Change tokenStatusAnswer to chargable
        /// Sucess: Success with token

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .pending(nextState: .pending(nextState: .chargeable)) // (1, 3, 4)
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionTokenErrorContinuePurchaseError5xSuccessRetryDialog() throws {
        /// Test scenario:
        /// 1. Change tokenAnswer to error
        /// 2. Get payment token
        /// 3. Login
        /// 4. Continue purchase
        /// 5. Get payment token error
        /// 6. When Retry Alert View is shown 5th time change get payment token to success
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // Payment API configuration
        paymentsApi.tokenAnswer = .error(22123) // (1)

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (3)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // continue purchase (4, 5)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        var counter = 0
        alertManagerMock.confirmActionClosure = {
            if counter == 5 {
                self.paymentsApi.tokenAnswer = .success // (6)
            }
            counter += 1
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testSubscriptionTokenErrorContinueCancelRetryDialog() throws {
        /// Test scenario:
        /// 1. Change tokenAnswer to error
        /// 2. Get payment token (nil in this case)
        /// 3. Login
        /// 4. Continue purchase
        /// 5. Get payment token error
        /// 6. When Retry Alert View is shown simulate pressing cancel button
        /// Result: continueRegistrationPurchase -> currentSubscription = nil

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenAnswer = .error(22123) // (1)
        
        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)
        
        // get payment token (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        // user info after login (3)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"
        
        let expectation2 = self.expectation(description: "Finish completion block called")
        
        // continue purchase (4, 5, 6)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertNil(self.paymentsApi.lastAmount)
            XCTAssertNil(self.servicePlan.currentSubscription)
            expectation2.fulfill()
        }
        
        alertManagerMock.confirmButton = .cancel

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionTokenStatusPendingPendingChargeable() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change token status to pending
        /// 4. Continue purchase
        /// 5. Change token status to pending
        /// 6. Change token status to chargeable
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .pending(nextState: .pending(nextState: .chargeable)) // (3, 5, 6)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testSubscriptionTokenStatusFailedChargeable() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change token status to failed
        /// 4. Continue purchase
        /// 5. Change token status to chargeable
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .failed(nextState: .chargeable) // (3, 5)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionTokenStatusNotSupportedChargeableSuccessRetryDialog() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change token status to notSupported
        /// 4. Continue purchase
        /// 5. Change token status to chargeable
        /// 6. When Retry Alert View is shown change get payment token to success
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .notSupported(nextState: .chargeable) // (3, 5)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        alertManagerMock.confirmActionClosure = {
            self.paymentsApi.tokenAnswer = .success // (6)
        }
        
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionTokenStatusNotSupportedChargeableCancelRetryDialog() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change token status to notSupported
        /// 4. Continue purchase
        /// 5. Change token status to chargeable
        /// 6. When Retry Alert View is shown simulate cancel button
        /// Sucess: continueRegistrationPurchase (no new subscription)

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .notSupported(nextState: .chargeable) // (3, 5)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertNil(self.paymentsApi.lastAmount)
            XCTAssertNil(self.servicePlan.currentSubscription)
            expectation2.fulfill()
        }

        alertManagerMock.confirmButton = .cancel // (6)
        
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionTokenStatusConsumedChargeable() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change token status to failed
        /// 4. Continue purchase
        /// Exit: continueRegistrationPurchase (no new subscription expected)

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .consumed() // (3)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertNil(self.paymentsApi.lastAmount)
            // no new subscription expected
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionValidateSubscriptionErrorSuccessRetryDialog() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change validateSubscription to error
        /// 4. Continue purchase
        /// 6. When Retry Alert View is shown change validateSubscription to success
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.validateSubscription = .error(20889) // (3)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }
        
        alertManagerMock.confirmActionClosure = {
            self.paymentsApi.validateSubscription = .success(amountDue: 4800) // (5)
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testSubscriptionValidateSubscriptionErrorCancelRetryDialog() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change validateSubscription to error
        /// 4. Continue purchase
        /// 5. When Retry Alert View is shown simulate cancel button
        /// Sucess: continueRegistrationPurchase (no new subscription)

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.validateSubscription = .error(20889) // (3)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertNil(self.paymentsApi.lastAmount)
            XCTAssertNil(self.servicePlan.currentSubscription)
            expectation2.fulfill()
        }
        
        alertManagerMock.confirmButton = .cancel // (5)

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testSubscriptionCreditSubscriptionSuccess() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. ValidateSubscription amountDue set to more than 4800
        /// 4. Continue purchase
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.validateSubscription = .success(amountDue: 9600) // (3)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 0)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testRegistrationSubscriptionErrorSuccessRetryDialog() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change subscriptionAnswer to error
        /// 4. Continue purchase
        /// 5. When Retry Alert View is shown change subscriptionAnswer to success
        /// Sucess: continueRegistrationPurchase

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.subscriptionAnswer = .error(22000) // (3)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        }

        // change BE subscriptionAnswer when Retry Alert View is shown
        alertManagerMock.confirmActionClosure = {
            self.paymentsApi.subscriptionAnswer = .success // (5)
        }

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testRegistrationSubscriptionErrorCancelRetryDialog() throws {
        /// Test scenario:
        /// 1. Get payment token
        /// 2. Login
        /// 3. Change subscriptionAnswer to error
        /// 4. Continue purchase
        /// 5. When Retry Alert View is shown simulate cancel button
        /// Sucess: continueRegistrationPurchase (no new subscription)

        let expectation1 = self.expectation(description: "Success completion block called")

        // check current subscription and processing type
        XCTAssertNil(self.servicePlan.currentSubscription)
        XCTAssertEqual(storeKitManager.processingType, .registration)

        // get payment token (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNotNil(token)
            expectation1.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        // user info after login (2)
        testStoreKitManagerDelegate._userId = "1234567890"
        testStoreKitManagerDelegate._activeUsername = "abc"

        let expectation2 = self.expectation(description: "Finish completion block called")

        // Payment API configuration
        paymentsApi.subscriptionAnswer = .error(22000) // (3)

        // continue purchase (4)
        storeKitManager.continueRegistrationPurchase {
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertNil(self.servicePlan.currentSubscription)
            expectation2.fulfill()
        }

        alertManagerMock.confirmButton = .cancel // (5)

        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
