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
    func test_currentPlan_parsesCorrectly() async throws {
        let api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))

        mockCurrentPlan()

        let request = CurrentPlanRequest(api: api)

        let currentPlanResponse = try await request.response(responseObject: CurrentPlanResponse())
        guard let currentPlan = currentPlanResponse.currentPlan else {
            XCTFail("Expected: current plan")
            return
        }

        XCTAssertEqual(currentPlan.subscriptions.first!.title, "Title")
        XCTAssertEqual(currentPlan.subscriptions.first!.description, "Description")
        XCTAssertEqual(currentPlan.subscriptions.first!.cycleDescription, "CycleDescription")
        XCTAssertEqual(currentPlan.subscriptions.first!.currency, "Currency")
        XCTAssertEqual(currentPlan.subscriptions.first!.amount, 28788)
        XCTAssertEqual(currentPlan.subscriptions.first!.periodEnd, 1696938858)
        XCTAssertEqual(currentPlan.subscriptions.first!.renew, 1)
        XCTAssertEqual(currentPlan.subscriptions.first!.external, .apple)

        XCTAssertEqual(currentPlan.subscriptions.first!.entitlements.count, 2)
        XCTAssertEqual(currentPlan.subscriptions.first!.entitlements[0], .progress(.init(type: "progress", text: "19.55 MB of 15 GB", min: 0, max: 1024, current: 512)))
        XCTAssertEqual(currentPlan.subscriptions.first!.entitlements[1], .description(.init(type: "description", text: "500 GB storage", iconName: "http://.../blah.svg", hint: "You win a lot of storage")))
    }
}

extension CurrentPlanIntegrationTests {
    private func mockCurrentPlan() {
        mock(filename: "CurrentPlan", title: "current plan /payment/v5/subscription mock", path: "/payments/v5/subscription")
    }

    private func mock(filename: String, title: String, path: String, statusCode: Int32 = 200) {
        weak var usersStub = stub(condition: pathEndsWith(path)) { request in
            let bundle = Bundle.module

            let url = bundle.url(forResource: filename, withExtension: "json")!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
        }

        usersStub?.name = title
    }
}

#endif
