//
//  LoginIntegrationTests.swift
//  ProtonCore-Login-Tests - Created on 16/02/2023.
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
import ProtonCoreQuarkCommands
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreAuthentication
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif

@available(iOS 13.0, macOS 10.15, *)
final class LoginIntegrationTests: IntegrationTestCase {

    override var testBundle: Bundle? { Bundle(for: Self.self) }
    var environment: Environment { dynamicDomain.map(Environment.custom) ?? .black }

    final class TestServiceDelegate: APIServiceDelegate {
        var appVersion: String { "ios-vpn@4.2.0-dev" }
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

    private func createAccountAndLogin(user: User, minimumAccountType: AccountType) async throws -> Result<LoginStatus, LoginError> {
        let quarkCommands = Quark().baseUrl(environment.doh)
        try quarkCommands.userCreate(user: user)

        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .empty)
        apiService.authDelegate = authHelper
        apiService.serviceDelegate = serviceDelegate
        let loginService = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: minimumAccountType)
        return await withCheckedContinuation { continuation in
            loginService.login(username: user.name, password: user.password, challenge: nil, completion: continuation.resume(returning:))
        }
    }

    func testExternalAccountWithoutKeysGetsKeysGeneratedIfRequiredAccountIsUsername() async throws {
        let user = User(email: randomEmail, name: randomEmail, password: randomPassword, isExternal: true)
        let loginResult = try await createAccountAndLogin(user: user, minimumAccountType: .username)

        guard case let .success(.finished(userData)) = loginResult else { XCTFail(); return }
        XCTAssertFalse(userData.user.keys.isEmpty)
        let address = try XCTUnwrap(userData.addresses.first)
        XCTAssertFalse(address.keys.isEmpty)
        XCTAssertTrue(address.isExternal)
    }

    func testDoesNotRequireAskingForSecondPasswordForUsernameRequirement() async throws {
        let user = User(name: randomName, password: randomPassword, mailboxPassword: "456")
        let loginResult = try await createAccountAndLogin(user: user, minimumAccountType: .username)
       
        guard case let .success(.finished(userData)) = loginResult else { XCTFail(); return }
        XCTAssertFalse(userData.user.keys.isEmpty)
        let address = try XCTUnwrap(userData.addresses.first)
        XCTAssertFalse(address.keys.isEmpty)
        XCTAssertTrue(address.isInternal)
    }

    func testRequiresAskingForSecondPasswordForExternalRequirement() async throws {
        var user = User(name: randomEmail, password: randomPassword, mailboxPassword: "456")
        user.email = randomEmail
        user.isExternal = true
        let loginResult = try await createAccountAndLogin(user: user, minimumAccountType: .external)
        guard case .success(.askSecondPassword) = loginResult else { XCTFail(); return }
    }

    func testRequiresAskingForSecondPasswordForInternalRequirement() async throws {
        let user = User(name: randomName, password: randomPassword, mailboxPassword: "456")
        let loginResult = try await createAccountAndLogin(user: user, minimumAccountType: .internal)
        
        guard case .success(.askSecondPassword) = loginResult else { XCTFail(); return }
    }

}
