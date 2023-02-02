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
    var service: ObservabilityServiceImpl!

    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    override func setUp() {
        super.setUp()
        authHelper = AuthHelper()
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .empty)
        apiService.serviceDelegate = serviceDelegate
        apiService.authDelegate = authHelper
        service = ObservabilityServiceImpl(apiService: apiService)
    }

    override func tearDown() {
        authHelper = nil
        super.tearDown()
    }

    override class func tearDown() {
        PMAPIService.noTrustKit = false
        super.tearDown()
    }
    
    // MARK: - Test external account creation schema
    
    func test_externalAccountCreation_withSuccessfulStatus_isValid() async throws {
        try await testEventIsValid(event: .externalAccountCreationSigninTotal(status: .successful))
    }

    func test_externalAccountCreation_withFailedStatus_isValid() async throws {
        try await testEventIsValid(event: .externalAccountCreationSigninTotal(status: .failed))
    }

    // MARK: - Test human verification schema

    func test_humanVerification_withSuccessfulStatus_isValid() async throws {
        try await testEventIsValid(event: .humanVerificationOutcomeTotal(status: .successful))
    }

    func test_humanVerification_withFailedStatus_isValid() async throws {
        try await testEventIsValid(event: .humanVerificationOutcomeTotal(status: .failed))
    }

    func test_humanVerification_withCanceledStatus_isValid() async throws {
        try await testEventIsValid(event: .humanVerificationOutcomeTotal(status: .canceled))
    }

    func test_humanVerificationScreenLoad_withSuccessfulStatus_isValid() async throws {
        try await testEventIsValid(event: .humanVerificationScreenLoadTotal(status: .successful))
    }

    func test_humanVerificationScreenLoad_withFailedStatus_isValid() async throws {
        try await testEventIsValid(event: .humanVerificationScreenLoadTotal(status: .failed))
    }

    // MARK: - Test plan selection schema

    func test_unlimitedPlanSelection_withSuccessfulStatus_isValid() async throws {
        try await testEventIsValid(event: .planSelectionCheckoutTotal(status: .successful, plan: .unlimited))
    }

    func test_unlimitedPlanSelection_withFailedStatus_isValid() async throws {
        try await testEventIsValid(event: .planSelectionCheckoutTotal(status: .failed, plan: .unlimited))
    }

    func test_plusPlanSelection_withSuccessfulStatus_isValid() async throws {
        try await testEventIsValid(event: .planSelectionCheckoutTotal(status: .successful, plan: .plus))
    }

    func test_plusPlanSelection_withFailedStatus_isValid() async throws {
        try await testEventIsValid(event: .planSelectionCheckoutTotal(status: .failed, plan: .plus))
    }

    func test_freePlanSelection_withSuccessfulStatus_isValid() async throws {
        try await testEventIsValid(event: .planSelectionCheckoutTotal(status: .successful, plan: .free))
    }

    func test_freePlanSelection_withFailedStatus_isValid() async throws {
        try await testEventIsValid(event: .planSelectionCheckoutTotal(status: .failed, plan: .free))
    }

    // MARK: - Test screen load count schema

    func test_screenLoadCount_forExternalAccountCreation_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .externalAccountCreation))
    }

    func test_screenLoadCount_forProtonAccountCreation_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .protonAccountCreation))
    }

    func test_screenLoadCount_forPasswordCreation_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .passwordCreation))
    }

    func test_screenLoadCount_forSetRecoveryMethod_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .setRecoveryMethod))
    }

    func test_screenLoadCount_forEmailVerification_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .emailVerification))
    }

    func test_screenLoadCount_forCongratulation_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .congratulation))
    }

    func test_screenLoadCount_forCreateProtonAccountWithCurrentEmail_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .createProtonAccountWithCurrentEmail))
    }

    func test_screenLoadCount_forPlanSelection_isValid() async throws {
        try await testEventIsValid(event: .screenLoadCountTotal(screenName: .planSelection))
    }

    // MARK: test invalid event
    
    func testInvalidEventIsRejected() async throws {
        struct InvalidData: Encodable {}
        let event = ObservabilityEvent<CounterPayloadWithLabels<InvalidData>>.init(
            name: "invalid_name",
            version: .v1,
            data: .init(labels: .init())
        )
        let (task, _) = try await performRequest(event: event)
        let httpResponse = try XCTUnwrap(task?.response as? HTTPURLResponse)
        XCTAssertEqual(httpResponse.statusCode, 422)
    }

    // MARK: - Private

    private func testEventIsValid<T: Encodable>(event: ObservabilityEvent<T>) async throws {
        let (task, _) = try await performRequest(event: event)
        let httpResponse = try XCTUnwrap(task?.response as? HTTPURLResponse)
        XCTAssertEqual(httpResponse.statusCode, 200)
    }
    
    private func performRequest<T>(event: ObservabilityEvent<T>) async throws -> (URLSessionDataTask?, Result<JSONDictionary, PMAPIService.APIError>) where T: Encodable {
        return await withFeatureSwitches([.unauthSession, .enforceUnauthSessionStrictVerificationOnBackend]) {
            await withCheckedContinuation { continuation in
                service.report(event) { task, result in
                    continuation.resume(returning: (task, result))
                }
            }
        }
    }
}
