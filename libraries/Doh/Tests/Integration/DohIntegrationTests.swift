//
//  DohIntegrationTests.swift
//  ProtonCore-Doh-Tests - Created on 19/01/23.
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
import ProtonCoreEnvironment
import ProtonCoreFeatureSwitch
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif

@testable import ProtonCoreAuthentication
@testable import ProtonCoreDoh

@available(iOS 15, *)
class DohIntegrationTests: XCTestCase {

    final class TestServiceDelegate: APIServiceDelegate {
        var appVersion: String { "ios-mail@4.2.0-dev" }
        var userAgent: String? { nil }
        var locale: String { "en_US" }
        var additionalHeaders: [String: String]? { nil }
        func onUpdate(serverTime: Int64) { }
        func isReachable() -> Bool { true }
        func onDohTroubleshot() { }
    }

    let serviceDelegate = TestServiceDelegate()

    override func tearDown() {
        super.tearDown()
        Environment.productions.forEach { $0.doh.clearCache() }
    }

    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    override class func tearDown() {
        super.tearDown()
        PMAPIService.noTrustKit = false
    }
    
    func testDoHWorksForTXTDomains() async throws {
        // DoH must be run on prod, because there's no AR for atlas
        for environment in Environment.productions {
            // GIVEN
            environment.updateDohStatus(to: .forceAlternativeRouting)
            let authDelegate = AuthHelper()
            let service = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .empty)
            service.serviceDelegate = serviceDelegate
            service.authDelegate = authDelegate
            let request = AuthService.UserAvailableWithoutSpecifyingDomainEndpoint(username: "doh_fanboy")

            // WHEN
            let (task, _): (URLSessionTask?, AuthService.UserAvailableResponse) = try await service.perform(request: request)

            // THEN
            guard let response = task?.response as? HTTPURLResponse, let url = response.url else { XCTFail(); return }
            XCTAssertTrue(environment.doh.isCurrentlyUsingProxyDomain)
            XCTAssertNotEqual(environment.doh.defaultHost, environment.doh.getCurrentlyUsedHostUrl())
            XCTAssertFalse(url.absoluteString.localizedStandardContains(environment.doh.defaultHost))
            guard let request = task?.currentRequest, let host = URL(string: environment.doh.defaultHost)?.host else { XCTFail(); return }
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-pm-doh-host"), host)
        }
    }

    func testDoHDoesntWorkForADomains() async throws {
        try await withFeatureSwitches([.dohARecordQueries]) {
            // GIVEN
            // only vpn AR supports A record queries right now
            let environment = Environment.vpnProd
            environment.updateDohStatus(to: .forceAlternativeRouting)
            let authDelegate = AuthHelper()
            let service = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .empty)
            service.serviceDelegate = serviceDelegate
            service.authDelegate = authDelegate
            let request = AuthService.UserAvailableWithoutSpecifyingDomainEndpoint(username: "doh_fanboy")

            // WHEN
            let (task, _): (URLSessionTask?, AuthService.UserAvailableResponse) = try await service.perform(request: request)

            // THEN
            guard let response = task?.response as? HTTPURLResponse, let url = response.url else { XCTFail(); return }
            XCTAssertFalse(environment.doh.isCurrentlyUsingProxyDomain)
            XCTAssertEqual(environment.doh.defaultHost, environment.doh.getCurrentlyUsedHostUrl())
            XCTAssertTrue(url.absoluteString.localizedStandardContains(environment.doh.defaultHost))
            guard let request = task?.currentRequest else { XCTFail(); return }
            XCTAssertNil(request.value(forHTTPHeaderField: "x-pm-doh-host"))
        }
    }
    
}
