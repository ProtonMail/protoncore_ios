//
//  ServicePlanDataService+ExtensionsTests.swift
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
import ProtonCore_CoreTranslation
@testable import ProtonCore_PaymentsUI
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class ServicePlanDataServiceExtensionsTests: XCTestCase {
    
    let testApi = PMAPIService(doh: TestDoHMail.default, sessionUID: "testSessionUID")
    var userCachedStatus: UserCachedStatus!
    var servicePlan: ServicePlanDataService!
    let paymentsApiMock = PaymentsApiMock()
    var paymentsUIViewModel: PaymentsUIViewModelViewModel!
    let testAuthDelegate = TestAuthDelegate()
    let testAPIServiceDelegate = TestAPIServiceDelegate()
    let storeKitManager = StoreKitManager.default
    let timeout = 10.0
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // setup testApi
        TestDoHMail.default.status = .off
        testApi.authDelegate = testAuthDelegate
        testApi.serviceDelegate = testAPIServiceDelegate
        PMAPIService.noTrustKit = true

        // setup ServicePlanDataService
        userCachedStatus = UserCachedStatus()
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        servicePlan.paymentsApi = paymentsApiMock
        
        // setup StoreKitManager
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKitManager.updateAvailableProductsList()
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
    }
    
    func testEndDateStringExpiredDate() {
        // simulate subscription with expired date
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: -1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        
        let expectation = self.expectation(description: "Success completion block called")
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            XCTAssertEqual(self.servicePlan.endDateString(plan: .mailPlus)?.string, nil)
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testEndDateStringExpiration1Year() {
        // simulate subscription with future date
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        
        let expectation = self.expectation(description: "Success completion block called")
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])            
            XCTAssertEqual(self.servicePlan.endDateString(plan: .mailPlus)?.string, String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString))
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testEndDateStringExpiration6Months() {
        // simulate subscription with future date
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .month, value: 6)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        
        let expectation = self.expectation(description: "Success completion block called")
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            XCTAssertEqual(self.servicePlan.endDateString(plan: .mailPlus)?.string, String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString))
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testEndDateStringExpiredDateAutorenew() {
        // simulate subscription with expired date
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: -1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        // add credits to check if expiration date is autorenew
        paymentsApiMock.usersAnswer = .credit(AccountPlan.mailPlus.yearlyCost)
        
        let expectation = self.expectation(description: "Success completion block called")
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            XCTAssertEqual(self.servicePlan.endDateString(plan: .mailPlus)?.string, nil)
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testEndDateStringExpiration1YearAutorenew() {
        // simulate subscription with future date
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        // add credits to check if expiration date is autorenew
        paymentsApiMock.usersAnswer = .credit(AccountPlan.mailPlus.yearlyCost)
        
        let expectation = self.expectation(description: "Success completion block called")
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            XCTAssertEqual(self.servicePlan.endDateString(plan: .mailPlus)?.string, String(format: CoreString._pu_plan_details_renew_auto_expired, endData.endDateString))
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testEndDateStringExpiration67DaysYearAutorenew() {
        // simulate subscription with future date
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .day, value: 67)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        // add credits to check if expiration date is autorenew
        paymentsApiMock.usersAnswer = .credit(AccountPlan.mailPlus.yearlyCost)
        
        let expectation = self.expectation(description: "Success completion block called")
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            XCTAssertEqual(self.servicePlan.endDateString(plan: .mailPlus)?.string, String(format: CoreString._pu_plan_details_renew_auto_expired, endData.endDateString))
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
