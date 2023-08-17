//
//  IAPtoPlanMappingTests.swift
//  ProtonCore-Payments-Tests - Created on 01/06/2023.
//
//  Copyright (c) 2023 Proton Technologies AG
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
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCorePayments

final class IAPtoPlanMappingTests: XCTestCase {
    
    var paymentsApi: PaymentsApiMock!
    var apiService: APIServiceMock!
    var paymentsAlertMock: PaymentsAlertManager!
    var servicePlanDataStorageMock: ServicePlanDataStorageMock!
    
    override func setUp() {
        super.setUp()
        paymentsApi = PaymentsApiMock()
        apiService = APIServiceMock()
        paymentsAlertMock = PaymentsAlertManager(alertManager: AlertManagerMock())
        servicePlanDataStorageMock = ServicePlanDataStorageMock()
    }

    func testIAPPlanIsParsedFromIAPIdentifier_Success() throws {
        let iap = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_12_usd_non_renewing"))
        XCTAssertNotNil(iap.storeKitProductId, "ioscore_core2023_12_usd_non_renewing")
        XCTAssertEqual(iap.protonName, "core2023")
        XCTAssertNil(iap.offer)
        XCTAssertEqual(iap.period, "12")
    }
    
    func testIAPPlanIsParsedFromIAPIdentifier_Failure() throws {
        // plan name missing
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "ioscore_12_usd_non_renewing"))
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "ioscore__12_usd_non_renewing"))
        // cycle missing
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_usd_non_renewing"))
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "ioscore_core2023__usd_non_renewing"))
        // prefix missing
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "core2023_12_usd_non_renewing"))
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "_core2023_12_usd_non_renewing"))
        // wrong prefix
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "androidcore_core2023_12_usd_non_renewing"))
        // suffix missing
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "isocore_core2023_12_usd_"))
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "isocore_core2023_12_usd"))
        // wrong suffix
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "isocore_core2023_12_usd_renewing"))
        // currency missing
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "isocore_core2023_12_non_renewing"))
        XCTAssertNil(InAppPurchasePlan(storeKitProductId: "isocore_core2023_12__non_renewing"))
    }
    
    func testIAPOfferIsParsedFromIAPIdentifier_Success() throws {
        let iap = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        XCTAssertNotNil(iap.storeKitProductId, "ioscore_core2023_12_usd_non_renewing")
        XCTAssertEqual(iap.protonName, "core2023")
        XCTAssertEqual(iap.offer, "testpromo")
        XCTAssertEqual(iap.period, "12")
    }
    
    func testIAPOfferIsParsedFromIAPIdentifier_Failure() throws {
        let iap1 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_12_usd_non_renewing"))
        XCTAssertNil(iap1.offer)
        let iap2 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023__12_usd_non_renewing"))
        XCTAssertNil(iap2.offer)
    }
    
    func testIAPPlanIsObtainedFromPlanWithoutOfferAndVendors_Success() throws {
        let plan = Plan.dummy.updated(name: "core2023")
        XCTAssertNotNil(InAppPurchasePlan(protonPlan: plan, listOfIAPIdentifiers: ["ioscore_core2023_12_usd_non_renewing"]))
    }
    
    func testIAPPlanIsObtainedFromPlanWithoutOfferAndVendors_Failure() throws {
        let plan = Plan.dummy.updated(name: "notcore2023")
        let iap = try XCTUnwrap(InAppPurchasePlan(protonPlan: plan, listOfIAPIdentifiers: ["ioscore_core2023_12_usd_non_renewing"]))
        XCTAssertNil(iap.storeKitProductId)
    }
    
    func testIAPPlanIsObtainedFromPlanWithOffer_Success() throws {
        let plan = Plan.dummy.updated(name: "core2023", offer: "testpromo")
        XCTAssertNotNil(InAppPurchasePlan(protonPlan: plan, listOfIAPIdentifiers: ["ioscore_core2023_testpromo_12_usd_non_renewing"]))
    }
    
    func testIAPPlanIsObtainedFromPlanWithOffer_Failure() throws {
        let plan = Plan.dummy.updated(name: "core2023", offer: "testpromo")
        let iap = try XCTUnwrap(InAppPurchasePlan(protonPlan: plan, listOfIAPIdentifiers: ["ioscore_core2023_12_usd_non_renewing"]))
        XCTAssertNil(iap.storeKitProductId)
    }
    
    func testIAPPlanIsObtainedFromPlanWithVendors_Success() throws {
        let plan = Plan.dummy.updated(name: "core2023", vendors: .init(apple: .init(plans: ["12": "ioscore_core2023_12_usd_non_renewing"])))
        XCTAssertNotNil(InAppPurchasePlan(protonPlan: plan, listOfIAPIdentifiers: ["ioscore_core2023_12_usd_non_renewing"]))
    }
    
    func testIAPPlanIsObtainedFromPlanWithVendors_Failure() throws {
        // wrong cycle
        let plan1 = Plan.dummy.updated(name: "core2023", vendors: .init(apple: .init(plans: ["1": "ioscore_core2023_12_usd_non_renewing"])))
        XCTAssertNil(InAppPurchasePlan(protonPlan: plan1, listOfIAPIdentifiers: ["ioscore_core2023_12_usd_non_renewing"]))
        // wrong vendor
        let plan2 = Plan.dummy.updated(name: "core2023", vendors: .init(apple: .init(plans: ["12": "ioscore_notcore2023_12_usd_non_renewing"])))
        XCTAssertNil(InAppPurchasePlan(protonPlan: plan2, listOfIAPIdentifiers: ["ioscore_core2023_12_usd_non_renewing"]))
    }
    
    func testServicePlanProvidesPlanDetailsCorrespondingToIAP_FindingByName_Success() throws {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test promo plan", offer: "testpromo"),
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
        ]
        let iap = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_12_usd_non_renewing"))
        let plan = try XCTUnwrap(out.detailsOfPlanCorrespondingToIAP(iap))
        XCTAssertTrue(plan.ID == "test regular plan")
    }
    
    func testServicePlanProvidesPlanDetailsCorrespondingToIAP_FindingByName_Failure() throws {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test promo plan", offer: "testpromo"),
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
        ]
        // wrong plan name
        let iap1 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_noncore2023_12_usd_non_renewing"))
        XCTAssertNil(out.detailsOfPlanCorrespondingToIAP(iap1))
        
        // wrong promo name
        let iap2 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_someotherpromo_12_usd_non_renewing"))
        XCTAssertNil(out.detailsOfPlanCorrespondingToIAP(iap2))
    }
    
    func testServicePlanProvidesPlanDetailsCorrespondingToIAP_FindingByNameAndOffer_Success() throws {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
            Plan.dummy.updated(name: "core2023", iD: "test promo plan", offer: "testpromo")
        ]
        let iap = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        let plan = try XCTUnwrap(out.detailsOfPlanCorrespondingToIAP(iap))
        XCTAssertTrue(plan.ID == "test promo plan")
    }
    
    func testServicePlanProvidesPlanDetailsCorrespondingToIAP_FindingByNameAndOffer_Failure() throws {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
            Plan.dummy.updated(name: "core2023", iD: "test promo plan", offer: "testpromo")
        ]
        // wrong plan name
        let iap1 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_noncore2023_testpromo_12_usd_non_renewing"))
        XCTAssertNil(out.detailsOfPlanCorrespondingToIAP(iap1))
        
        // wrong promo name
        let iap2 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_someotherpromo_12_usd_non_renewing"))
        XCTAssertNil(out.detailsOfPlanCorrespondingToIAP(iap2))
    }
    
    func testServicePlanProvidesPlanDetailsCorrespondingToIAP_FindingByVendors_Success() throws {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        
        // all data match
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
            Plan.dummy.updated(name: "core2023", iD: "test promo plan",
                               vendors: .init(apple: .init(plans: ["12": "ioscore_core2023_testpromo_12_usd_non_renewing"])))
        ]
        let iap1 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        let plan1 = try XCTUnwrap(out.detailsOfPlanCorrespondingToIAP(iap1))
        XCTAssertTrue(plan1.ID == "test promo plan")
        
        // plan name can differ from name in IAP identifier
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "noncore2023", iD: "test regular plan"),
            Plan.dummy.updated(name: "noncore2023", iD: "test promo plan",
                               vendors: .init(apple: .init(plans: ["12": "ioscore_core2023_testpromo_12_usd_non_renewing"])))
        ]
        let iap2 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        let plan2 = try XCTUnwrap(out.detailsOfPlanCorrespondingToIAP(iap2))
        XCTAssertTrue(plan2.ID == "test promo plan")
    }
    
    func testServicePlanProvidesPlanDetailsCorrespondingToIAP_FindingByVendors_Failure() throws {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        
        // wrong period
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
            Plan.dummy.updated(name: "core2023", iD: "test promo plan",
                               vendors: .init(apple: .init(plans: ["1": "ioscore_core2023_testpromo_12_usd_non_renewing"])))
        ]
        let iap1 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        XCTAssertNil(out.detailsOfPlanCorrespondingToIAP(iap1))
        
        // wrong IAP identifier
        out.availablePlansDetails = [
            Plan.dummy.updated(name: "core2023", iD: "test regular plan"),
            Plan.dummy.updated(name: "core2023", iD: "test promo plan",
                               vendors: .init(apple: .init(plans: ["12": "ioscore_noncore2023_testpromo_12_usd_non_renewing"])))
        ]
        let iap2 = try XCTUnwrap(InAppPurchasePlan(storeKitProductId: "ioscore_core2023_testpromo_12_usd_non_renewing"))
        XCTAssertNil(out.detailsOfPlanCorrespondingToIAP(iap2))
    }
    
}
