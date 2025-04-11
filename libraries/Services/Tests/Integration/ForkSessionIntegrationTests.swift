//
//  Created on 13.03.2025.
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

import ProtonCoreQuarkCommands

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

@testable import ProtonCoreServices
@testable import ProtonCoreNetworking

@available(iOS 13.0.0, *)
final class ForkSessionIntegrationTests: IntegrationTestCase {

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

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
        PMAPIService.noTrustKit = true
    }

    override class func tearDown() {
        super.tearDown()
        PMAPIService.noTrustKit = false
    }

    func testGetPushAndPullForkSuccessfully() async throws {
        // This test forks a session
        // And makes sure we can query the session details after the fork is pushed.

        let payloads: [String?] = ["TestPayload", nil]

        for payload in payloads {
            // GIVEN
            let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .empty)
            let authDelegate = AuthHelper()
            apiService.authDelegate = authDelegate
            apiService.serviceDelegate = serviceDelegate

            let user = User(email: randomEmail, name: randomEmail, password: randomPassword, isExternal: true)
            guard let userResponse = try createAccount(user: user) else {
                XCTFail("\(#file): \(#function): Failed to create user.")
                return
            }

            guard let _ = try await login(apiService, user: user, minimumAccountType: .external).value else {
                XCTFail("\(#file): \(#function): Failed to login user.")
                return
            }

            // WHEN
            let initiateRequest = ForkSessionRequest(useCase: .initiateFork)
            let initiateResponse: (URLSessionDataTask?, ForkSessionInitiateResponse) = try await apiService.perform(request: initiateRequest)

            let pushRequest = ForkSessionRequest(useCase: .pushFork(payload: payload, clientId: "ios-vpn", independent: true, userCode: initiateResponse.1.userCode))
            let pushResponse: (URLSessionDataTask?, ForkSessionPushResponse) = try await apiService.perform(request: pushRequest)

            let pullRequest = ForkSessionRequest(useCase: .pullFork(selector: pushResponse.1.selector))
            let pullResponse: (URLSessionDataTask?, ForkSessionPullResponse) = try await apiService.perform(request: pullRequest)
            // THEN

            XCTAssertNotEqual(initiateResponse.1.userCode, "")
            XCTAssertNotEqual(initiateResponse.1.selector, "")
            XCTAssertNotEqual(pushResponse.1.selector, "")
            XCTAssertEqual(initiateResponse.1.selector, pushResponse.1.selector)

            XCTAssertNotEqual(pullResponse.1.UID, "")
            XCTAssertEqual(pullResponse.1.payload, payload)
            XCTAssertNotEqual(pullResponse.1.accessToken, "")
            XCTAssertNotEqual(pullResponse.1.refreshToken, "")

            deleteAccount(id: userResponse.decryptedUserId)
        }
    }

    private func createAccount(user: User) throws -> CreateUserQuarkResponse? {
        let quark = Quark()
            .baseUrl(environment.doh)

        return try quark.userCreate(user: user, createAddress: .noKey)
    }

    private func login(_ apiService: APIService, user: User, minimumAccountType: AccountType) async throws -> Result<LoginStatus, LoginError> {
        let loginService = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: minimumAccountType)
        return await withCheckedContinuation { continuation in
            loginService.login(username: user.name, password: user.password, challenge: nil, completion: continuation.resume(returning:))
        }
    }

    private func deleteAccount(id: Int) {
        let quark = Quark().baseUrl(environment.doh)
        let _ = try? quark.deleteUser(id: id)
    }

}
