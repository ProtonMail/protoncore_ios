//
//  Created on 12.03.2025.
//
//  Copyright (c) 2025 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import XCTest
import TrustKit
import ProtonCoreAuthentication
@testable import ProtonCoreLogin
import ProtonCoreChallenge
import ProtonCoreEnvironment
import ProtonCoreUtilities
import ProtonCoreDoh
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif

@testable import ProtonCoreServices
@testable import ProtonCoreNetworking

@available(iOS 13.0.0, *)
final class GetUserCodeAndSelectorIntegrationTests: IntegrationTestCase {

    override var testBundle: Bundle? { Bundle(for: Self.self) }
    var environment: Environment { dynamicDomain.map(Environment.custom) ?? .black }

    final class TestServiceDelegate: APIServiceDelegate {
        // Feature works only for VPN
        var appVersion: String { "ios-vpn@4.2.0-dev" }
        var userAgent: String? { nil }
        var locale: String { "en_US" }
        var additionalHeaders: [String: String]? { ["X-Enforce-UnauthSession": "true"] }
        func onUpdate(serverTime: Int64) { }
        func isReachable() -> Bool { true }
        func onDohTroubleshot() { }
    }

    let serviceDelegate = TestServiceDelegate()

    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    override class func tearDown() {
        super.tearDown()
        PMAPIService.noTrustKit = false
    }

    func testGetUserCodeAndSelectorSuccessfully() async throws {
        // GIVEN
        let service = PMAPIService.createAPIServiceWithoutSession(
            environment: environment,
            challengeParametersProvider: .forAPIService(clientApp: .vpn, challenge: .init()))
        // Note: We need both authDelegate and serviceDelegate for the request to succeed.
        let authDelegate = AuthHelper()
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        let useCase = GetUserCodeAndSelector(apiService: service)

        // WHEN
        let result = try await useCase.invoke()

        // THEN
        XCTAssertNotEqual(result.userCode, "")
        XCTAssertNotEqual(result.selector, "")
    }
}

#endif
