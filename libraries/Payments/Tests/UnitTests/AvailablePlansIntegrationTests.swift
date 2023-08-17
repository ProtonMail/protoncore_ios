//
//  AvailablePlansIntegrationTests.swift
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

final class AvailablePlansIntegrationTests: XCTestCase {
    func test_availablePlans_parsesCorrectly() {
        let api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        
        mockAvailablePlans()

        let expectation = expectation(description: "test_availablePlans_parseCorrectly")
        let request = AvailablePlansRequest(api: api)
        
        Task {
            do {
                let availablePlansResponse = try request.awaitResponse(responseObject: AvailablePlansResponse())
                guard let availablePlans = availablePlansResponse.availablePlans else {
                    XCTFail("Expected: available plans")
                    return
                }
                
                expectation.fulfill()
                
                XCTAssertEqual(availablePlans.code, 1000)
                XCTAssertEqual(availablePlans.plans.count, 1)
                XCTAssertEqual(availablePlans.plans[0].type, 1)
                XCTAssertEqual(availablePlans.plans[0].name, "mailpro2022")
                XCTAssertEqual(availablePlans.plans[0].title, "Mail Essentials")
                XCTAssertEqual(availablePlans.plans[0].state, 1)
                XCTAssertEqual(availablePlans.plans[0].entitlements.count, 1)
                XCTAssertEqual(availablePlans.plans[0].entitlements[0].type, "description")
                XCTAssertEqual(availablePlans.plans[0].entitlements[0].text, "text")
                XCTAssertEqual(availablePlans.plans[0].entitlements[0].icon, "<base64>")
                XCTAssertNil(availablePlans.plans[0].entitlements[0].hint)
                XCTAssertEqual(availablePlans.plans[0].offers?.count, 1)
                XCTAssertEqual(availablePlans.plans[0].offers?[0].name, "offer name")
                XCTAssertEqual(availablePlans.plans[0].offers?[0].startTime, 3412324)
                XCTAssertEqual(availablePlans.plans[0].offers?[0].endTime, 3594124)
                XCTAssertEqual(availablePlans.plans[0].offers?[0].months, 1)
                XCTAssertEqual(availablePlans.plans[0].offers?[0].price.count, 1)
                XCTAssertEqual(availablePlans.plans[0].offers?[0].price[0].currency, "USD")
                XCTAssertEqual(availablePlans.plans[0].offers?[0].price[0].current, 123)
            } catch {
                XCTFail("Expected: available plans")
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
}

extension AvailablePlansIntegrationTests {
    private func mockAvailablePlans() {
        mock(filename: "AvailablePlans", title: "available plans /payment/v5/plans mock", path: "/payments/v5/plans")
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
