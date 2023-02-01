//
//  ObservabilityEventTests.swift
//  ProtonCore-Observability-Tests - Created on 16.12.22.
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
import ProtonCore_Authentication
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_Observability

@available(iOSApplicationExtension 13.0, *)
final class ObservabilityEventTests: XCTestCase {

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
        PMAPIService.noTrustKit = false
        super.tearDown()
    }

    enum TestingEventFromWebStep: String, Encodable {
        case external_account_creation
        case proton_account_creation
        case verification
        case referral
        case upsell
        case payment
        case loading
        case congratulations
        case recovery
        case explore
    }

    struct TestingEventFromWebStepLabels: Encodable {
        let step: TestingEventFromWebStep
    }

    func testInvalidEventIsRejected() async throws {
        let event = ObservabilityEvent.screenLoadCount(screenName: .planSelection)
        let (task, _) = try await performRequest(event: event)
        let httpResponse = try XCTUnwrap(task?.response as? HTTPURLResponse)
        XCTAssertEqual(httpResponse.statusCode, 400)
    }

    private func performRequest<T>(event: ObservabilityEvent<T>) async throws -> (URLSessionDataTask?, Result<JSONDictionary, PMAPIService.APIError>) where T: Encodable {
        let service = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .empty)
        service.serviceDelegate = serviceDelegate
        service.authDelegate = authHelper
        let eventData = try JSONEncoder().encode(event)
        let parameters = try JSONSerialization.jsonObject(with: eventData, options: [])
        return await withFeatureSwitches([.unauthSession, .enforceUnauthSessionStrictVerificationOnBackend]) {
            await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded { result in
                    switch result {
                    case .success(.sessionUnavailableAndNotFetched), .failure:
                        XCTFail()
                        continuation.resume(returning: (nil, .failure(.init(domain: "core.integration-tests", code: -1))))
                    case .success(.sessionAlreadyPresent), .success(.sessionFetchedAndAvailable):
                        service.request(method: .post, path: "/data/v1/metrics", parameters: parameters, headers: nil, authenticated: false,
                                        autoRetry: true, customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background,
                                        jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
                    }
                }
            }
        }
    }
}
