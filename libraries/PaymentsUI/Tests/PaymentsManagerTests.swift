//
//  PaymentsManagerTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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
import ProtonCore_Services
@testable import ProtonCore_PaymentsUI
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class PaymentsManagerTests: XCTestCase {
    
    let storeKitManager = StoreKitManager.default
    let testApi = PMAPIService(doh: TestDoHMail.default, sessionUID: "testSessionUID")
    let testAuthDelegate = TestAuthDelegate()
    let testAPIServiceDelegate = TestAPIServiceDelegate()
    let tokenStorage = TokenStorage.default
    var userCachedStatus = UserCachedStatus()
    var testStoreKitManagerDelegate: TestStoreKitManagerDelegate!
    var servicePlan: ServicePlanDataService!
    let paymentsApi = PaymentsApiMock()
    let alertManagerMock = AlertManagerMock()
    let paymentsQueue = SKPaymentQueueMock()

    let paymentsManager = PaymentsManager()
    let timeout = 10.0

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // setup testApi
        TestDoHMail.default.status = .off
        testApi.authDelegate = testAuthDelegate
        testApi.serviceDelegate = testAPIServiceDelegate
        PMAPIService.noTrustKit = true
        
        // setup ServicePlanDataService
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        servicePlan.paymentsApi = paymentsApi
        
        // setup StoreKitmanager
        tokenStorage.clear()
        testStoreKitManagerDelegate = TestStoreKitManagerDelegate(api: testApi, tokenStorage: tokenStorage, servicePlanDataService: servicePlan)
        testStoreKitManagerDelegate._userId = "12345"
        testStoreKitManagerDelegate._activeUsername = "Test User"
        storeKitManager.delegate = testStoreKitManagerDelegate
        configureStoreKit()
    }
    
    func testBuyFreePlanSuccess() {
        let expectation = self.expectation(description: "Success completion block called")
        
        paymentsManager.buyPlan(accountPlan: .free) { callback in
            switch callback {
            case .purchasedPlan(let plan, processingPlan: let processingPlan):
                XCTAssertEqual(plan, .free)
                XCTAssertEqual(processingPlan, nil)
                expectation.fulfill()
            case .purchaseError:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyUnavailablePlanSuccess() {
        let expectation = self.expectation(description: "Success completion block called")
        
        paymentsManager.buyPlan(accountPlan: .visionary) { callback in
            switch callback {
            case .purchasedPlan:
                XCTFail()
            case .purchaseError(let error, let processingPlan):
                XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.unavailableProduct)
                XCTAssertEqual(processingPlan, nil)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlusPlanSuccess() {
        let expectation = self.expectation(description: "Success completion block called")
        
        paymentsManager.buyPlan(accountPlan: .mailPlus) { callback in
            switch callback {
            case .purchasedPlan(let plan, processingPlan: let processingPlan):
                XCTAssertEqual(plan, .mailPlus)
                XCTAssertEqual(processingPlan, .mailPlus)
                expectation.fulfill()
            case .purchaseError:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlusPlanError() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // Sumulate payment error
        paymentsApi.tokenStatusAnswer = .failed()
        
        paymentsManager.buyPlan(accountPlan: .mailPlus) { callback in
            switch callback {
            case .purchasedPlan:
                XCTFail()
            case .purchaseError(let error, let processingPlan):
                XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.wrongTokenStatus(.failed))
                XCTAssertEqual(processingPlan, .mailPlus)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyUnfinishedPlan() {
        let expectation1 = self.expectation(description: "Success completion block called")
        
        XCTAssertEqual(paymentsManager.unfinishedPurchasePlan, nil)
        
        // Sumulate payment error
        paymentsApi.tokenStatusAnswer = .failed()
        
        paymentsManager.buyPlan(accountPlan: .mailPlus) { callback in
            switch callback {
            case .purchasedPlan:
                XCTFail()
            case .purchaseError(let error, let processingPlan):
                XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.wrongTokenStatus(.failed))
                XCTAssertEqual(processingPlan, .mailPlus)
                expectation1.fulfill()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        XCTAssertEqual(paymentsManager.unfinishedPurchasePlan, .mailPlus)
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // Sumulate payment ok
        paymentsApi.tokenStatusAnswer = .chargeable
        
        paymentsManager.buyPlan(accountPlan: .mailPlus) { callback in
            switch callback {
            case .purchasedPlan(let plan, processingPlan: let processingPlan):
                XCTAssertEqual(plan, .mailPlus)
                XCTAssertEqual(processingPlan, nil)
                expectation2.fulfill()
            case .purchaseError:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testunfinishedPurchasePlanNil() {
        XCTAssertEqual(paymentsManager.unfinishedPurchasePlan, nil)
    }
}

extension PaymentsManagerTests {
    func configureStoreKit() {
        paymentsQueue.transactionState = .purchased
        storeKitManager.paymentQueue = paymentsQueue
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKitManager.updateAvailableProductsList()
        storeKitManager.paymentsAlertManager = PaymentsAlertManager(alertManager: alertManagerMock)
        storeKitManager.paymentsApi = paymentsApi
        paymentsApi.subscriptionRequestAnswer = .free
        paymentsApi.creditAnswer = .success
        paymentsApi.tokenAnswer = .success
        paymentsApi.tokenStatusAnswer = .chargeable
        paymentsApi.validateSubscription = .success(amountDue: 4800)
        paymentsApi.subscriptionAnswer = .success
    }
}
