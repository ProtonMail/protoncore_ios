//
//  PaymentsUICoordinatorTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 23/08/2022.
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

#if os(iOS)

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsDataModel
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreServices
@testable import ProtonCoreObservability
@testable import ProtonCorePayments
@testable import ProtonCorePaymentsUI

final class PaymentsUICoordinatorTests: XCTestCase {

    var planServiceMock: ServicePlanDataServiceMock!
    var plansDataSource: PlansDataSourceMock!
    var storeKitManager: StoreKitManagerMock!
    var paymentsApi: PaymentsApiMock!
    var apiService: APIServiceMock!
    var alertManager: AlertManagerMock!
    var purchaseManager: PurchaseManager!
    let timeout: TimeInterval = 10
    
    override func setUp() {
        super.setUp()
        planServiceMock = ServicePlanDataServiceMock()
        plansDataSource = PlansDataSourceMock()
        storeKitManager = StoreKitManagerMock()
        paymentsApi = PaymentsApiMock()
        apiService = APIServiceMock()
        alertManager = AlertManagerMock()
        purchaseManager = PurchaseManager(planService: .left(planServiceMock),
                                          storeKitManager: storeKitManager,
                                          paymentsApi: paymentsApi,
                                          apiService: apiService )
    }
    
    func testObservabilityEnvPlanSelectorFreePlan() {
        let expectation = self.expectation(description: "Success completion block called")
        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        
        observeMock.reportStub.bodyIs { _, event in
            guard event.isSameAs(event: .planSelectionCheckoutTotal(status: .successful, plan: .free)) else {
                return
            }
            expectation.fulfill()
        }
        
        let plan = InAppPurchasePlan.freePlan
        let testPlan = PlanPresentation(accountPlan: plan, planPresentationType: .current(.unavailable))
        let coordinator = PaymentsUICoordinator.init(planService: .left(planServiceMock),
                                                     storeKitManager: storeKitManager,
                                                     purchaseManager: purchaseManager,
                                                     clientApp: .vpn,
                                                     shownPlanNames: ["free"],
                                                     customization: .empty,
                                                     alertManager: AlwaysDelegatingPaymentsUIAlertManager(delegatedAlertManager: alertManager)) { }
        coordinator.userDidSelectPlan(plan: testPlan, addCredits: false) { }
        waitForExpectations(timeout: timeout)
    }
    
    func testObservabilityEnvPlanSelectorPaidPlan() {
        let expectation = self.expectation(description: "Success completion block called")
        let expectation2 = self.expectation(description: "Should call refresh handler")
        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        observeMock.reportStub.bodyIs { _, event in
            guard event.isSameAs(event: .planSelectionCheckoutTotal(status: .successful, plan: .paid)) else {
                return
            }
            expectation.fulfill()
        }
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
                "Plans": [String]()
            ] as [String : Any]
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
        let plan = InAppPurchasePlan(protonPlan: .dummy.updated(name: "mail_plus"), listOfIAPIdentifiers: ["ios_test_12_usd_non_renewing"])!
        let testPlan = PlanPresentation(accountPlan: plan, planPresentationType: .current(.unavailable))
        let coordinator = PaymentsUICoordinator.init(planService: .left(planServiceMock),
                                                     storeKitManager: storeKitManager,
                                                     purchaseManager: purchaseManager,
                                                     clientApp: .vpn,
                                                     shownPlanNames: ["free", "test"],
                                                     customization: .empty,
                                                     alertManager: AlwaysDelegatingPaymentsUIAlertManager(delegatedAlertManager: alertManager)) { }
        coordinator.userDidSelectPlan(plan: testPlan, addCredits: false) { }
        waitForExpectations(timeout: timeout)
    }
    
    func testObservabilityEnvPlanSelectorPaidPlanFailed() {
        let expectation = self.expectation(description: "Success completion block called")
        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        
        observeMock.reportStub.bodyIs { _, event in
            guard event.isSameAs(event: .planSelectionCheckoutTotal(status: .failed, plan: .paid)) else {
                return
            }
            expectation.fulfill()
        }
        
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(couponCode: "test code")
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success([:]))
        }
        let plan = InAppPurchasePlan(protonPlan: .dummy.updated(name: "mail_plus"), listOfIAPIdentifiers: ["ios_test_12_usd_non_renewing"])!
        let testPlan = PlanPresentation(accountPlan: plan, planPresentationType: .current(.unavailable))
        let coordinator = PaymentsUICoordinator.init(planService: .left(planServiceMock),
                                                     storeKitManager: storeKitManager,
                                                     purchaseManager: purchaseManager,
                                                     clientApp: .vpn,
                                                     shownPlanNames: ["free", "test"],
                                                     customization: .empty,
                                                     alertManager: AlwaysDelegatingPaymentsUIAlertManager(delegatedAlertManager: alertManager)) { }
        coordinator.userDidSelectPlan(plan: testPlan, addCredits: false) { }
        waitForExpectations(timeout: timeout)
    }
    
    func testObservabilityEnvPlanSelectorUnknownToFree() {
        let expectation = self.expectation(description: "Success completion block called")
        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        observeMock.reportStub.bodyIs { _, event in
            guard event.isSameAs(event: .planSelectionCheckoutTotal(status: .failed, plan: .free)) else {
                return
            }
            expectation.fulfill()
        }
        
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        planServiceMock.currentSubscriptionStub.fixture = .dummy.updated(couponCode: "test code")
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success([:]))
        }
        let plan = InAppPurchasePlan(protonPlan: .dummy.updated(name: "mail_p211l2us_free"), listOfIAPIdentifiers: ["ios_test_12_usd_non_renewing"])!
        let testPlan = PlanPresentation(accountPlan: plan, planPresentationType: .current(.unavailable))
        let coordinator = PaymentsUICoordinator.init(planService: .left(planServiceMock),
                                                     storeKitManager: storeKitManager,
                                                     purchaseManager: purchaseManager,
                                                     clientApp: .vpn,
                                                     shownPlanNames: ["free", "test"],
                                                     customization: .empty,
                                                     alertManager: AlwaysDelegatingPaymentsUIAlertManager(delegatedAlertManager: alertManager)) { }
        coordinator.userDidSelectPlan(plan: testPlan, addCredits: false) { }
        waitForExpectations(timeout: timeout)
    }
    
    func testObservabilityEnvPlanSelectorPaidPlanApiBlocked() {
        let expectation = self.expectation(description: "Success completion block called")
        let observeMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observeMock
        observeMock.reportStub.bodyIs { _, event in
            guard event.isSameAs(event: .planSelectionCheckoutTotal(status: .apiMightBeBlocked, plan: .paid)) else {
                return
            }
            expectation.fulfill()
        }
        planServiceMock.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, _ in .dummy.updated(name: "ios_test_12_usd_non_renewing", iD: "test_plan_id") }
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in completion(nil, .success(ValidateSubscription(amountDue: 100).toJsonDict)) }
        storeKitManager.purchaseProductStub.bodyIs { _, _, _, _, errorCompletion, _ in errorCompletion(StoreKitManagerErrors.apiMightBeBlocked(message: "test message", originalError: NSError.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: "api_might_be_blocked_message"))) }
        
        let plan = InAppPurchasePlan(protonPlan: .dummy.updated(name: "mail_plus"), listOfIAPIdentifiers: ["ios_test_12_usd_non_renewing"])!
        let testPlan = PlanPresentation(accountPlan: plan, planPresentationType: .current(.unavailable))
        let coordinator = PaymentsUICoordinator.init(planService: .left(planServiceMock),
                                                     storeKitManager: storeKitManager,
                                                     purchaseManager: purchaseManager,
                                                     clientApp: .vpn,
                                                     shownPlanNames: ["free", "test"],
                                                     customization: .empty,
                                                     alertManager: AlwaysDelegatingPaymentsUIAlertManager(delegatedAlertManager: alertManager)) { }
        coordinator.userDidSelectPlan(plan: testPlan, addCredits: false) { }
        waitForExpectations(timeout: timeout)
    }
}

#endif
