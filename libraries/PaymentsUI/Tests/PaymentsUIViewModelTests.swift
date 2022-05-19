//
//  PaymentsUIViewModelTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
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
import ProtonCore_CoreTranslation
@testable import ProtonCore_Payments
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_PaymentsUI

// TODO: ADD TESTS for plan refresh handler and on error handler

@available(iOS 13, *)
final class PaymentsUIViewModelTests: XCTestCase {

    let timeout = 1.0

    var storeKitManager: StoreKitManagerMock!
    var servicePlan: ServicePlanDataServiceMock!

    override func setUp() {
        super.setUp()
        storeKitManager = StoreKitManagerMock()
        servicePlan = ServicePlanDataServiceMock()
    }
    
    // MARK: Resolv
    func testResolvingUnfinishedTransactionsProcessSetsStoreKitManagerUp() {
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"],
                                               clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        storeKitManager.retryProcessingAllPendingTransactions { }
        XCTAssertEqual(storeKitManager.refreshHandlerStub.getCallCounter, 0)
        XCTAssertTrue(storeKitManager.refreshHandlerStub.setWasCalledExactlyOnce)
        _ = out
    }
    
    func testRefreshHandlerRefreshesPlansOnCreditsSuccess() {
        storeKitManager.retryProcessingAllPendingTransactionsStub.bodyIs { _, _ in
            self.storeKitManager.refreshHandlerStub.setLastArguments?.value()
        }
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "test")]
        servicePlan.updateCreditsStub.bodyIs { _, _, completion, _ in
            completion()
        }
        let expectation = expectation(description: "should call block")
        let planRefreshHandler: (String?) -> Void = { _ in expectation.fulfill() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"],
                                               clientApp: .mail, planRefreshHandler: planRefreshHandler, onError: { _ in XCTFail() })
        storeKitManager.retryProcessingAllPendingTransactions { }
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(servicePlan.plansStub.getWasCalledExactlyOnce)
        XCTAssertTrue(servicePlan.updateCreditsStub.wasCalledExactlyOnce)
        _ = out
    }
    
    func testRefreshHandlerRefreshesPlansOnCreditsError() {
        storeKitManager.retryProcessingAllPendingTransactionsStub.bodyIs { _, _ in
            self.storeKitManager.refreshHandlerStub.setLastArguments?.value()
        }
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "test")]
        let testError = NSError(domain: "test", code: 42)
        servicePlan.updateCreditsStub.bodyIs { _, _, _, errorCompletion in
            errorCompletion(testError)
        }
        let expectation = expectation(description: "should call block")
        let planRefreshHandler: (String?) -> Void = { _ in expectation.fulfill() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"],
                                               clientApp: .mail, planRefreshHandler: planRefreshHandler, onError: { _ in XCTFail() })
        storeKitManager.retryProcessingAllPendingTransactions { }

        waitForExpectations(timeout: timeout)
        XCTAssertTrue(servicePlan.plansStub.getWasCalledExactlyOnce)
        XCTAssertTrue(servicePlan.updateCreditsStub.wasCalledExactlyOnce)
        _ = out
    }
    
    func testRefreshHandlerShowsErrorOnPlansRefreshError() {
        storeKitManager.retryProcessingAllPendingTransactionsStub.bodyIs { _, _ in
            self.storeKitManager.refreshHandlerStub.setLastArguments?.value()
        }
        let testError = NSError(domain: "test", code: 42)
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, _, errorCompletion in
            errorCompletion(testError)
        }
        let expect1 = expectation(description: "should call this block")
        let expect2 = expectation(description: "should call that block as well")
        let planRefreshHandler: (String?) -> Void = { _ in
            expect1.fulfill()
        }
        var capturedError: Error?
        let errorHandler: (Error) -> Void = {
            capturedError = $0; expect2.fulfill()
        }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"],
                                               clientApp: .mail, planRefreshHandler: planRefreshHandler, onError: errorHandler)
        storeKitManager.retryProcessingAllPendingTransactions { }

        waitForExpectations(timeout: timeout)
        XCTAssertEqual(capturedError! as NSError, testError)
        XCTAssertTrue(servicePlan.plansStub.getWasCalledExactlyOnce)
        XCTAssertTrue(servicePlan.updateCreditsStub.wasNotCalled)
        _ = out
    }
    
    // MARK: Fetching plans

    func testFetchSignupPlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "plus")]
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchSignupPlansWithBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "plus")]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchSignupPlansWithAdditionalBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fix { counter in
            if counter == 1 { return [] } else { return [Plan.empty.updated(name: "plus")] }
        }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(servicePlan.updateServicePlansSuccessFailureStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchSignupPlansNoPurchasablePlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "plus", title: "test title", state: 0)]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(returnedPlans?.count == 0)
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    // MARK: Current plan mode
    
    func testFetchCurrentPlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "plus")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchCurrentPlansWithFetchFromBackend() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "plus")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchCurrentPlansWithSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy.updated(planDetails: [Plan.empty.updated(name: "test2", title: "test2 title")])
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free", "test2"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withoutPlans)
    }
    
    func testFetchCurrentPlansNoBackendFetchDisabledFooter() {
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.currentSubscriptionStub.fixture = Subscription.userHasUnsufficientScopeToFetchSubscription
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [""], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "")
        XCTAssertTrue(returnedFooterType == .disabled)
    }

    // MARK: Update plan mode
    func testFetchUpdatePlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchUpdatePlansWithFetchFromBackend() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchUpdatePlansWithSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy.updated(planDetails: [Plan.empty.updated(name: "test2", title: "test2 title")])
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free", "test2"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withoutPlans)
    }
    
    func testFetchUpdatePlansNoBackendFetchDisabledFooter() {
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.currentSubscriptionStub.fixture = Subscription.userHasUnsufficientScopeToFetchSubscription
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "")
        XCTAssertTrue(returnedFooterType == .disabled)
    }
    
    func testFetchCurrentPlansVPN() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "vpnplus", pricing: ["12": 9600]), Plan.empty.updated(name: "vpnbasic", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertEqual(returnedPlans?.last?.last?.name, "Basic")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }
    
    func testFetchCurrentPlansVPNFilteredPlusPlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "vpnplus", pricing: ["12": 9600]), Plan.empty.updated(name: "vpnbasic", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Basic")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchCurrentPlansVPNFilteredBasicPlan() async {
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "vpnplus", pricing: ["12": 9600]), Plan.empty.updated(name: "vpnbasic", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let (returnedPlans, returnedFooterType): ([[PlanPresentation]], FooterType) = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, footerType)):
                    continuation.resume(returning: (plans, footerType))
                }
            }
        }
        XCTAssertEqual(returnedPlans.count, 2)
        XCTAssertEqual(returnedPlans.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans.last?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }
    
    enum PresentedPriceTestingHelper {
        static let plusPlan = Plan.empty.updated(name: "vpnplus",
                                                 pricing: ["1": 1000, "12": 10000, "24": 18000],
                                                 cycle: 12)
        static let basicPlan = Plan.empty.updated(name: "vpnbasic",
                                                  pricing: ["1": 500, "12": 4800, "24": 8800],
                                                  cycle: 12)
        static let free = Plan.empty.updated(name: "free", title: "free title")
        static let basicIAP = "ios_vpnbasic_12_usd_non_renewing"
        static let plusIAP = "ios_vpnplus_12_usd_non_renewing"
        
        static func priceLabelForProduct(id storeKitId: String) -> (NSDecimalNumber, Locale)? {
            if storeKitId == plusIAP { return (NSDecimalNumber(value: 120), Locale(identifier: "en_US")) }
            if storeKitId == basicIAP { return (NSDecimalNumber(value: 60), Locale(identifier: "en_US")) }
            XCTFail(); return nil
        }
        
        static func detailsOfPlan(name: String) -> Plan? {
            if name == plusPlan.name { return plusPlan }
            if name == basicPlan.name { return plusPlan }
            if name == free.name { return free }
            XCTFail(); return nil
        }
    }
    
    func testCurrentPlan_PresentedPrice_Free_NoPaymentMethod() async {
        // GIVEN: user has no subscription and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = nil
        servicePlan.paymentMethodsStub.fixture = []
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the free plan and upgrade plans with IAP prices
        XCTAssertEqual(planPresentations.count, 2)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Free")
        #if canImport(ProtonCore_CoreTranslation_V5)
        XCTAssertEqual(planPresentations.first!.first!.price, "$0")
        #else
        XCTAssertEqual(planPresentations.first!.first!.price, nil)
        #endif
        XCTAssertEqual(planPresentations.first!.first!.cycle, nil)
        XCTAssertEqual(planPresentations.last!.count, 2)
        XCTAssertEqual(planPresentations.last!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.last!.first!.price, "$120.00")
        XCTAssertEqual(planPresentations.last!.first!.cycle, "for 1 year")
        XCTAssertEqual(planPresentations.last!.last!.name, "Basic")
        XCTAssertEqual(planPresentations.last!.last!.price, "$60.00")
        XCTAssertEqual(planPresentations.last!.last!.cycle, "for 1 year")
    }
    
    func testCurrentPlan_PresentedPrice_Cycle1_NoPaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 1 and price 2.00 EUR and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 1, amount: 200, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = []
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.first!.first!.price, "€2.00")
        XCTAssertEqual(planPresentations.first!.first!.cycle, "for 1 month")
    }
    
    func testCurrentPlan_PresentedPrice_Cycle12_NoPaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 12 and price 2.00 EUR and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 12, amount: 200, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = []
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the price returned by storekit with yearly cycle
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.first!.first!.price, "$120.00")
        XCTAssertEqual(planPresentations.first!.first!.cycle, "for 1 year")
    }
    
    func testCurrentPlan_PresentedPrice_Cycle24_NoPaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 24 and price 4.00 EUR and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 24, amount: 400, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = []
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.first!.first!.price, "€4.00")
        XCTAssertEqual(planPresentations.first!.first!.cycle, "for 2 years")
    }
    
    func testCurrentPlan_PresentedPrice_Free_PaymentMethod() async {
        // GIVEN: user has no subscription and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = nil
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the free plan and upgrade plans with IAP prices
        XCTAssertEqual(planPresentations.count, 2)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Free")
        #if canImport(ProtonCore_CoreTranslation_V5)
        XCTAssertEqual(planPresentations.first!.first!.price, "$0")
        #else
        XCTAssertEqual(planPresentations.first!.first!.price, nil)
        #endif
        XCTAssertEqual(planPresentations.first!.first!.cycle, nil)
        XCTAssertEqual(planPresentations.last!.count, 2)
        XCTAssertEqual(planPresentations.last!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.last!.first!.price, "$120.00")
        XCTAssertEqual(planPresentations.last!.first!.cycle, "for 1 year")
        XCTAssertEqual(planPresentations.last!.last!.name, "Basic")
        XCTAssertEqual(planPresentations.last!.last!.price, "$60.00")
        XCTAssertEqual(planPresentations.last!.last!.cycle, "for 1 year")
    }
    
    func testCurrentPlan_PresentedPrice_Cycle1_PaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 1 and price 2.00 EUR and card payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 1, amount: 200, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.first!.first!.price, "€2.00")
        XCTAssertEqual(planPresentations.first!.first!.cycle, "for 1 month")
    }
    
    func testCurrentPlan_PresentedPrice_Cycle12_PaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 12 and price 3.00 EUR and card payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 12, amount: 300, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.first!.first!.price, "€3.00")
        XCTAssertEqual(planPresentations.first!.first!.cycle, "for 1 year")
    }
    
    func testCurrentPlan_PresentedPrice_Cycle24_PaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 24 and price 4.00 EUR and card payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 24, amount: 400, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn,
                                               planRefreshHandler: { _ in XCTFail() }, onError: { _ in XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        XCTAssertEqual(planPresentations.first!.first!.name, "Plus")
        XCTAssertEqual(planPresentations.first!.first!.price, "€4.00")
        XCTAssertEqual(planPresentations.first!.first!.cycle, "for 2 years")
    }
}
