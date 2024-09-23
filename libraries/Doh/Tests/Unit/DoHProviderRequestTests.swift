//
//  DoHProviderRequestTests.swift
//  ProtonCore-Doh-Tests - Created on 25/03/22.
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
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
@testable import ProtonCoreDoh
import ProtonCoreChallenge
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreAuthentication

class DoHProviderRequestTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    var authDelegate: TestAuthDelegate!
    var authDelegate2: TestAuthDelegate!
    let timeout = 3.0

    override func setUp() {
        authDelegate = TestAuthDelegate(sessionID: "testSessionID")
        authDelegate2 = TestAuthDelegate(sessionID: "testSessionID_2")
        HTTPStubs.setEnabled(true)
        stubProductionHosts()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    class TestAuthDelegate: AuthDelegate {
        func onSessionObtaining(credential: Credential) {}
        func onAdditionalCredentialsInfoObtained(sessionUID: String, password: String?, salt: String?, privateKey: String?) {}
        weak var authSessionInvalidatedDelegateForLoginAndSignup: AuthSessionInvalidatedDelegate?
        var authCredential: AuthCredential? { testAuthCredential }
        func authCredential(sessionUID: String) -> AuthCredential? { testAuthCredential }
        func credential(sessionUID: String) -> Credential? { testAuthCredential.map(Credential.init) }
        func onAuthenticatedSessionInvalidated(sessionUID: String) { }
        func onUpdate(credential: Credential, sessionUID: String) { }
        func onRefresh(sessionUID: String, service: APIService, complete: @escaping AuthRefreshResultCompletion) { }
        func onUnauthenticatedSessionInvalidated(sessionUID: String) { }
        private var testAuthCredential: AuthCredential? {
            AuthCredential(sessionID: sessionID, accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
        }

        let sessionID: String

        init(sessionID: String) {
            self.sessionID = sessionID
        }
    }

    struct GenericRequest: Request {
        let path: String
        let isAuth: Bool
        let authCredential: AuthCredential?
        let retryPolicy: ProtonRetryPolicy.RetryMode

        init(path: String, isAuth: Bool, authCredential: AuthCredential? = nil, retryPolicy: ProtonRetryPolicy.RetryMode = .userInitiated) {
            self.path = path
            self.isAuth = isAuth
            self.authCredential = authCredential
            self.retryPolicy = retryPolicy
        }
    }

    let urlSuffix = ProductionHosts.mailAPI.dohHost

    func fulfill(
        _ hostExpectations: [String: XCTestExpectation],
        accordingToResult result: URLRequest,
        sessionID: String = ""
    ) {
        guard let url = result.url else { XCTFail("No URL in result?"); return }

        if #available(iOS 16, *),
           let host = url.host(),
           let expectation = hostExpectations[host] {
            expectation.fulfill()
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let name = components.queryItems?.first(where: { $0.name == "name" })?.value else {
            XCTFail("URL '\(url)' doesn't contain name=testSessionID.\(self.urlSuffix)")
            return
        }

        XCTAssertEqual(name, "\(sessionID)\(sessionID.isEmpty ? "" : ".")\(self.urlSuffix)")
    }

    func testNotAuthRequestAuthCredentialPassedByAuthDelegate_NoSessionID() {
        authDelegate = TestAuthDelegate(sessionID: "")
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result)
        }

        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: false)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate

        apiService.perform(request: request, response: AuthResponse()) { task, response in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testNotAuthRequestNoAuthCredential_NoSessionID() {
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result)
        }

        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: false)
        doh.status = .forceAlternativeRouting

        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestAuthCredentialPassedByAuthDelegate_SessionID() {
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result, sessionID: "testSessionID")
        }

        var doh: DoHInterface = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate

        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestOwnSessionIDPassesByAPIService_SessionID() {
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result, sessionID: "testSessionID")
        }

        var doh: DoHInterface = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIService(doh: doh,
                                                       sessionUID: "OwnSessionID_123",
                                                       challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate

        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestAuthCredentailPassedByRequest_SessionID() {
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result, sessionID: "testSessionID")
        }

        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate

        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestAuthCredentailPassedByAuthDelegateAndRequest_SessionID() {
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result, sessionID: "testSessionID_2")
        }

        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate2.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate

        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestAuthCredentialPassesByAuthDelegateAndRequestANDAPIService_SessionID() {
        let hostExpectations = [
            "1.1.1.1": self.expectation(description: "Success completion block called from provider 1"),
            "8.8.8.8": self.expectation(description: "Success completion block called from provider 2"),
            "9.9.9.9": self.expectation(description: "Success completion block called from provider 3"),
        ]

        let expectation = self.expectation(description: "Final completion block invoked")

        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            self.fulfill(hostExpectations, accordingToResult: result, sessionID: "testSessionID_2")
        }

        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIService(doh: doh as DoHInterface,
                                                       sessionUID: "OwnSessionID_123",
                                                       challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate2.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate

        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}

#endif
