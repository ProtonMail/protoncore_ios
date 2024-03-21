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
final class UnauthSessionIntegrationTests: IntegrationTestCase {

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

    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    override class func tearDown() {
        super.tearDown()
        PMAPIService.noTrustKit = false
    }

    // MARK: Tests for obtaining session due to backend issuing 401 on unauthenticated call

    func testUnauthSessionIsObtainedDueToBackendRequirements() async throws {
        // GIVEN
        let service = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let authDelegate = AuthHelper()
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        XCTAssertTrue(service.sessionUID.isEmpty)
        XCTAssertNil(authDelegate.credential(sessionUID: service.sessionUID))

        // WHEN
        let (task, _) = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/core/v4/domains/available?Type=login", parameters: nil, headers: nil, authenticated: false, authRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background) { (task, result: Result<AvailableDomainResponse, API.APIError>) in
                continuation.resume(returning: (task, result))
            }
        }

        // THEN
        let httpResponse = try XCTUnwrap(task?.response as? HTTPURLResponse)
        XCTAssertEqual(httpResponse.statusCode, 200)
        XCTAssertFalse(service.sessionUID.isEmpty)
        XCTAssertNotNil(authDelegate.credential(sessionUID: service.sessionUID))
        XCTAssertEqual((task?.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-PM-UID"), service.sessionUID)
    }

    // MARK: Tests for acquiring session explicitely, through the acquire session call

    func testUnauthSessionIsAcquiredIfNoSessionIsAlreadyPresent() async throws {
        // GIVEN
        let service = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let authDelegate = AuthHelper()
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        XCTAssertTrue(service.sessionUID.isEmpty)
        XCTAssertNil(authDelegate.credential(sessionUID: service.sessionUID))

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
        }

        // THEN
        guard case .success(.sessionFetchedAndAvailable) = result else { XCTFail(); return }
        XCTAssertFalse(service.sessionUID.isEmpty)
        XCTAssertNotNil(authDelegate.credential(sessionUID: service.sessionUID))
    }

    func testUnauthSessionIsAcquiredOnlyOnceEvenForMultipleAquireMethodCalls() async throws {
        // GIVEN
        let service = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let authDelegate = AuthHelper()
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        XCTAssertTrue(service.sessionUID.isEmpty)
        XCTAssertNil(authDelegate.credential(sessionUID: service.sessionUID))

        // WHEN
        let result = await withCheckedContinuation { continuation in
            var resultOfFirstCall: Result<SessionAcquiringResult, PMAPIService.APIError>?
            service.acquireSessionIfNeeded(completion: { resultOfFirstCall = $0 })
            service.acquireSessionIfNeeded(completion: {
                continuation.resume(returning: (resultOfFirstCall, $0))
            })
            XCTAssertNil(resultOfFirstCall)
        }

        // THEN
        guard case .success(.sessionFetchedAndAvailable) = result.0 else { XCTFail(); return }
        guard case .success(.sessionAlreadyPresent) = result.1 else { XCTFail(); return }
    }

    func testUnauthSessionReturnsIsNotAcquiredIfSessionIsAlreadyPresent() async throws {
        // GIVEN
        let service = PMAPIService.createAPIService(environment: environment, sessionUID: "test session", challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let testCredentials = Credential(UID: "test session", accessToken: "test access token", refreshToken: "test refresh token", userName: .empty, userID: .empty, scopes: .empty)
        let authDelegate = AuthHelper(credential: testCredentials)
        service.authDelegate = authDelegate
        service.serviceDelegate = serviceDelegate

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
        }

        // THEN
        guard case .success(.sessionAlreadyPresent) = result else { XCTFail(); return }
    }
}

#endif
