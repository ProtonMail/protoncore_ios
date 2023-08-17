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

#if os(iOS)

import XCTest

import ProtonCoreAuthentication
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreServices
import ProtonCoreEnvironment
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#endif
import ProtonCoreChallenge
@testable import ProtonCoreNetworking
@testable import ProtonCoreLoginUI
import TrustKit

@available(iOS 13.0, macOS 10.15, *)
final class LoginAndSignupIntegrationTests: IntegrationTestCase {

    override var testBundle: Bundle? { Bundle(for: Self.self) }
    var environment: Environment { dynamicDomain.map(Environment.custom) ?? .black }

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
    var authHelper: AuthHelper!

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
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

    private func createAPIService() -> APIService {
        let api = PMAPIService.createAPIServiceWithoutSession(environment: environment,
                                                              challengeParametersProvider: .forAPIService(clientApp: .mail, challenge: .init()))
        api.authDelegate = authHelper
        api.serviceDelegate = serviceDelegate
        return api
    }

    func testLoginAndSignupObtainsUnauthSession() async throws {
        let api = createAPIService()
        _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
        let credentials = try await waitForResultOfOptionalOperation { api.authDelegate?.credential(sessionUID: api.sessionUID) }
        XCTAssertTrue(credentials.userID.isEmpty)
        XCTAssertTrue(credentials.userName.isEmpty)
    }

    func testLoginAndSignupDoesNotObtainsUnauthSessionButSessionAlreadyExists() async throws {
        let api = createAPIService()
        _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
        let credentials = try await waitForResultOfOptionalOperation { api.authDelegate?.credential(sessionUID: api.sessionUID) }
        _ = LoginAndSignup(appName: "Mail", clientApp: .mail, apiService: api, minimumAccountType: .internal, paymentsAvailability: .notAvailable)
        let result = try await waitForOptionalOperation(iterations: 5, period: 1_000_000_000) {
            api.authDelegate?.credential(sessionUID: api.sessionUID) == credentials ? nil : true
        }
        XCTAssertNil(result)
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

#endif
