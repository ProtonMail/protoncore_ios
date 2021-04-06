//
//  PaymentsUIViewModelTests.swift
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

class PaymentsUIViewModelTests: XCTestCase {
    
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
    }
    
    // MARK: Signup plans mode
    
    func testFetchSignupPlansNoBacendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .signup, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: false) { result in
            switch result {
            case .success((let plans, let isAnyPlanToPurchase)):
                XCTAssertTrue(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans, plans)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 2)
                XCTAssertEqual(plans[0], PlansData.planFree())
                XCTAssertEqual(plans[1], PlansData.planPlus())
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchSignupPlans() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .signup, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((let plans, let isAnyPlanToPurchase)):
                XCTAssertTrue(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans, plans)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 2)
                XCTAssertEqual(plans[0], PlansData.planFree())
                XCTAssertEqual(plans[1], PlansData.planPlus())
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchSignupPlansMailPlanProcessing() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .signup, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            self.paymentsUIViewModel.processingAccountPlan = .mailPlus
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertTrue(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 2)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planFree(isSelectable: false))
                XCTAssertEqual(self.paymentsUIViewModel.plans[1], PlansData.planPlus())
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchSignupPlansFreePlanProcessing() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .signup, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            self.paymentsUIViewModel.processingAccountPlan = .free
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertTrue(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 2)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planFree())
                XCTAssertEqual(self.paymentsUIViewModel.plans[1], PlansData.planPlus(isSelectable: false))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    // MARK: Current plan mode
    
    func testFetchCurrentPlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: false) { result in
            switch result {
            case .success((let plans, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans, plans)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 0)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansFreeSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertTrue(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 2)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planFree(isSelectable: false, title: .current))
                XCTAssertEqual(self.paymentsUIViewModel.plans[1], PlansData.planPlus())
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansPlusSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)

        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPlus(isSelectable: false, endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansOtherSubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        paymentsApiMock.subscriptionRequestAnswer = .vpnBasic
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planFree(isSelectable: false, title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansProSubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .professional(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPro(endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansVisionarySubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .visionary(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planVisionary(endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansVisionaryAutoRenewSubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .visionary(periodEnd: endData.endDate)
        // add credits to check if expiration date is autorenew
        paymentsApiMock.usersAnswer = .credit(AccountPlan.visionary.yearlyCost)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planVisionary(endDateString: String(format: CoreString._pu_plan_details_renew_auto_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchCurrentPlansPlusAddons() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlusAddons(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .current, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPlus(isSelectable: false, endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    // MARK: Update plan mode
    
    func testFetchUpdatePlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: false) { result in
            switch result {
            case .success((let plans, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans, plans)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 0)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansFreeSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertTrue(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPlus())
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansPlusSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        
        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPlus(isSelectable: false, endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansOtherSubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        paymentsApiMock.subscriptionRequestAnswer = .vpnBasic
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planFree(isSelectable: false, title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansProSubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .professional(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPro(endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansVisionarySubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .visionary(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planVisionary(endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansVisionaryAutoRenewSubscription() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .visionary(periodEnd: endData.endDate)
        // add credits to check if expiration date is autorenew
        paymentsApiMock.usersAnswer = .credit(AccountPlan.visionary.yearlyCost)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planVisionary(endDateString: String(format: CoreString._pu_plan_details_renew_auto_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testFetchUpdatePlansPlusAddons() {
        let expectation = self.expectation(description: "Success completion block called")

        let endData = PlansData.getEndDate(paymentsApiMock: paymentsApiMock, component: .year, value: 1)
        paymentsApiMock.subscriptionRequestAnswer = .mailPlusAddons(periodEnd: endData.endDate)
        
        // setup PaymentsUIViewModelViewModel
        paymentsUIViewModel = PaymentsUIViewModelViewModel(mode: .update, servicePlan: servicePlan, planTypes: .mail)
        
        paymentsUIViewModel.fatchPlans(backendFetch: true) { result in
            switch result {
            case .success((_, let isAnyPlanToPurchase)):
                XCTAssertFalse(isAnyPlanToPurchase)
                XCTAssertEqual(self.paymentsUIViewModel.plans.count, 1)
                XCTAssertEqual(self.paymentsUIViewModel.plans[0], PlansData.planPlus(isSelectable: false, endDateString: String(format: CoreString._pu_plan_details_renew_expired, endData.endDateString), title: .current))
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

}
