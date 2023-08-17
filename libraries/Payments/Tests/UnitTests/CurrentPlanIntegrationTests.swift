//
//  CurrentPlanIntegrationTests.swift
//  ProtonCorePaymentsTests - Created on 13.07.23.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#if os(iOS)

import XCTest
import OHHTTPStubs

import ProtonCoreAuthentication
import ProtonCoreChallenge
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
@testable import ProtonCorePayments

#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif

final class CurrentPlanIntegrationTests: XCTestCase {
    func test_currentPlan_parsesCorrectly() {
        let api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        
        mockCurrentPlan()

        let expectation = expectation(description: "test_currentPlan_parsesCorrectly")
        let request = CurrentPlanRequest(api: api)
        
        Task {
            do {
                let currentPlanResponse = try request.awaitResponse(responseObject: CurrentPlanResponse())
                guard let currentPlan = currentPlanResponse.currentPlan else {
                    XCTFail("Expected: current plan")
                    return
                }
                
                expectation.fulfill()
                
                XCTAssertEqual(currentPlan.code, 1000)
                XCTAssertEqual(currentPlan.subscription.name, "name")
                XCTAssertEqual(currentPlan.subscription.description, "Current plan")
                XCTAssertEqual(currentPlan.subscription.ID, "6opBd5UdUtY_RtEz...YA==")
                XCTAssertEqual(currentPlan.subscription.parentMetaPlanID, "hUcV0_EeNw...g==")
                XCTAssertEqual(currentPlan.subscription.type, 1)
                XCTAssertEqual(currentPlan.subscription.title, "Visionary")
                XCTAssertEqual(currentPlan.subscription.cycle, 12)
                XCTAssertEqual(currentPlan.subscription.cycleDescription, "1 year")
                XCTAssertEqual(currentPlan.subscription.currency, "USD")
                XCTAssertEqual(currentPlan.subscription.amount, 28788)
                XCTAssertEqual(currentPlan.subscription.offer, "default")
                XCTAssertEqual(currentPlan.subscription.quantity, 1)
                XCTAssertEqual(currentPlan.subscription.periodStart, 1665402858)
                XCTAssertEqual(currentPlan.subscription.periodEnd, 1696938858)
                XCTAssertEqual(currentPlan.subscription.createTime, 1570708458)
                XCTAssertEqual(currentPlan.subscription.couponCode, "PROTONTEAM")
                XCTAssertEqual(currentPlan.subscription.discount, -28788)
                XCTAssertEqual(currentPlan.subscription.renewDiscount, -28788)
                XCTAssertEqual(currentPlan.subscription.renewAmount, 0)
                XCTAssertEqual(currentPlan.subscription.renew, 1)
                XCTAssertEqual(currentPlan.subscription.external, 0)
                
                XCTAssertEqual(currentPlan.subscription.entitlements.count, 2)
                XCTAssertEqual(currentPlan.subscription.entitlements[0], .storage(.init(type: "Storage", max: 1024, current: 512)))
                XCTAssertEqual(currentPlan.subscription.entitlements[1], .description(.init(type: "Description", text: "500 GB storage", icon: "http://.../blah.svg", hint: "You win a lot of storage")))
                
                XCTAssertEqual(currentPlan.subscription.decorations.count, 2)
                XCTAssertEqual(currentPlan.subscription.decorations[0].type, "Star")
                XCTAssertEqual(currentPlan.subscription.decorations[0].icon, "<base64>")
                XCTAssertEqual(currentPlan.subscription.decorations[1].type, "Border")
                XCTAssertEqual(currentPlan.subscription.decorations[1].color, "#xxx")
                
                XCTAssertNil(currentPlan.upcomingSubscription)
            } catch {
                XCTFail("Expected: current plan")
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
}

extension CurrentPlanIntegrationTests {
    private func mockCurrentPlan() {
        mock(filename: "CurrentPlan", title: "current plan /payment/v5/subscription mock", path: "/payments/v5/subscription")
    }
    
    private func mock(filename: String, title: String, path: String, statusCode: Int32 = 200) {
        weak var usersStub = stub(condition: pathEndsWith(path)) { request in
            #if SPM
            let bundle = Bundle.module
            #else
            let bundle = Bundle(for: type(of: self))
            #endif

            let url = bundle.url(forResource: filename, withExtension: "json")!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
        }
        
        usersStub?.name = title
    }
}

#endif
