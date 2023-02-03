//
//  LoginAndSignupIntegrationTests.swift
//  ProtonCore-Login-IntegrationTests - Created on 14.10.22.
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
import ProtonCore_TestingToolkit
import ProtonCore_Services
@testable import ProtonCore_Networking
@testable import ProtonCore_LoginUI
import TrustKit

@available(iOS 13.0, macOS 10.15, *)
final class LoginAndSignupIntegrationTests: XCTestCase {

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

    func testLoginAndSignupObtainsUnauthSessionIfFeatureFlagIsOn() async throws {
        try await withFeatureSwitches([.unauthSession, .enforceUnauthSessionStrictVerificationOnBackend]) {
            let api = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .empty)
            api.authDelegate = authHelper
            api.serviceDelegate = serviceDelegate
            _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
            let credentials = try await waitForResultOfOptionalOperation { api.authDelegate?.credential(sessionUID: api.sessionUID) }
            XCTAssertTrue(credentials.userID.isEmpty)
            XCTAssertTrue(credentials.userName.isEmpty)
        }
    }

    func testLoginAndSignupDoesNotObtainsUnauthSessionIfFeatureFlagIsOnButSessionAlreadyExists() async throws {
        try await withFeatureSwitches([.unauthSession, .enforceUnauthSessionStrictVerificationOnBackend]) {
            let api = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .empty)
            api.authDelegate = authHelper
            api.serviceDelegate = serviceDelegate
            _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
            let credentials = try await waitForResultOfOptionalOperation { api.authDelegate?.credential(sessionUID: api.sessionUID) }
            _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
            let result = try await waitForOptionalOperation(iterations: 5, period: 1_000_000_000) {
                api.authDelegate?.credential(sessionUID: api.sessionUID) == credentials ? nil : true
            }
            XCTAssertNil(result)
        }
    }

    func testLoginAndSignupDoesntObtainUnauthSessionIfFeatureFlagIsOff() async throws {
        try await withFeatureSwitches([]) {
            let api = PMAPIService.createAPIServiceWithoutSession(environment: .black, challengeParametersProvider: .empty)
            api.authDelegate = authHelper
            api.serviceDelegate = serviceDelegate
            _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
            let credentials = try await waitForOptionalOperation(iterations: 5, period: 1_000_000_000) { api.authDelegate?.credential(sessionUID: api.sessionUID) }
            XCTAssertNil(credentials)
        }
    }

    private func waitForResultOfOptionalOperation<T>(iterations: Int = 40, period: UInt64 = 250_000_000, operation: () async throws -> T?) async throws -> T {
        let result = try await waitForOptionalOperation(iterations: iterations, period: period, operation: operation)
        return try XCTUnwrap(result)
    }

    private func waitForOptionalOperation<T>(iterations: Int, period: UInt64, operation: () async throws -> T?) async throws -> T? {
        for _ in 1...iterations {
            guard let result = try await operation() else {
                try await Task.sleep(nanoseconds: period)
                continue
            }
            return result
        }
        return nil
    }
}
