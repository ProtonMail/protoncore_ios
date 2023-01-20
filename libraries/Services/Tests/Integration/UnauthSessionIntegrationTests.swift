//
//  UnauthSessionIntegrationTests.swift
//  ProtonCore-Services-Tests - Created on 04/20/22.
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
import TrustKit
import ProtonCore_Authentication
@testable import ProtonCore_Login
import ProtonCore_Challenge
import ProtonCore_CoreTranslation
import ProtonCore_Utilities
import ProtonCore_Doh
import ProtonCore_FeatureSwitch

@testable import ProtonCore_Services
@testable import ProtonCore_Networking

@available(iOS 13.0.0, *)
final class UnauthSessionIntegrationTests: XCTestCase {

    final class TestServiceDelegate: APIServiceDelegate {
        var appVersion: String { "ios-mail@4.2.0" }
        var userAgent: String? { nil }
        var locale: String { "en_US" }
        var additionalHeaders: [String: String]? { nil }
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

    override func setUp() {
        super.setUp()
        FeatureFactory.shared.enable(&.unauthSession)
        FeatureFactory.shared.disable(&.enforceUnauthSessionStrictVerificationOnBackend)
    }

    override func tearDown() {
        super.tearDown()
        // clear the feature flag state
        FeatureFactory.shared.disable(&.unauthSession)
        FeatureFactory.shared.disable(&.enforceUnauthSessionStrictVerificationOnBackend)
    }
    
    func testUnauthSessionIsObtainedDueToBackendRequirements() async {
        FeatureFactory.shared.enable(&.enforceUnauthSessionStrictVerificationOnBackend)
        let service = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        let authDelegate = AuthHelper()
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        XCTAssertTrue(service.sessionUID.isEmpty)
        XCTAssertNil(authDelegate.credential(sessionUID: service.sessionUID))

        let (task, _) = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/domains/available?Type=login", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background) { (task, result: Result<AvailableDomainResponse, API.APIError>) in
                continuation.resume(returning: (task, result))
            }
        }
        XCTAssertFalse(service.sessionUID.isEmpty)
        XCTAssertNotNil(authDelegate.credential(sessionUID: service.sessionUID))
        XCTAssertEqual((task?.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-PM-UID"), service.sessionUID)
    }

    func testUnauthSessionIsNotObtainedIfNoBackendRequirements() async {
        let service = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        let authDelegate = AuthHelper()
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        XCTAssertTrue(service.sessionUID.isEmpty)
        XCTAssertNil(authDelegate.credential(sessionUID: service.sessionUID))

        let (task, _) = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/domains/available?Type=login", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background) { (task, result: Result<AvailableDomainResponse, API.APIError>) in
                continuation.resume(returning: (task, result))
            }
        }
        XCTAssertTrue(service.sessionUID.isEmpty)
        XCTAssertNil(authDelegate.credential(sessionUID: service.sessionUID))
        XCTAssertNil((task?.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-PM-UID"))
    }
}
