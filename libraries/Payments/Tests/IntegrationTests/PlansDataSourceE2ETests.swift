//
//  PlansDataSourceE2ETests.swift
//  ProtonCorePaymentsTests - Created on 03.08.23.
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

import ProtonCoreAuthentication
import ProtonCoreChallenge
import ProtonCoreDoh
import ProtonCoreEnvironment
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
@testable import ProtonCorePayments
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif

final class PlansDataSourceE2ETests: IntegrationTestCase {

    override var testBundle: Bundle? { Bundle(for: Self.self) }
    var environment: Environment { dynamicDomain.map(Environment.custom) ?? .black }

    final class TestServiceDelegate: APIServiceDelegate {
        var appVersion: String { "ios-mail@4.2.0-dev" }
        var userAgent: String? { nil }
        var locale: String { "en_US" }
        var additionalHeaders: [String: String]? { ["X-Enforce-UnauthSession": "true"] }
        func onUpdate(serverTime: Int64) { }
        func isReachable() -> Bool { true }
        func onDohTroubleshot() { }
    }

    let serviceDelegate = TestServiceDelegate()
    var authHelper: AuthHelper!

    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    override func setUp() {
        super.setUp()
        authHelper = AuthHelper()
    }

    override func tearDown() {
        authHelper = nil
        super.tearDown()
    }

    override class func tearDown() {
        super.tearDown()
        PMAPIService.noTrustKit = false
    }

    private func createAPIService() -> APIService {
        let api = PMAPIService.createAPIServiceWithoutSession(environment: environment,
                                                              challengeParametersProvider: .forAPIService(clientApp: .mail, challenge: .init()))
        api.authDelegate = authHelper
        api.serviceDelegate = serviceDelegate
        return api
    }

//    func testAvailablePlansAreFetched() async throws {
//        // the storekit is mocked because it fails with following error
//        // https://stackoverflow.com/questions/65688144/storekittest-request-product-error-domain-asderrordomain-code-950-unhandled-e
//        let storeKitDataSource = StoreKitDataSourceMock()
//        storeKitDataSource.filterAccordingToAvailableProductsStub.bodyIs { _, plans in plans }
//        let out = PlansDataSource(apiService: createAPIService(), storeKitDataSource: storeKitDataSource)
//        try await out.fetchAvailablePlans()
//        XCTAssertNotNil(out.availablePlans)
//    }

}

#endif
