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

import XCTest
import OHHTTPStubs
@testable import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Authentication

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
    
    func testNotAuthRequestAuthCredentialPassedByAuthDelegate_NoSessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: false)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { task, response in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testAuthRequestAuthCredentialPassedByAuthDelegate_NoSessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        var doh: DoHInterface = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testNotAuthRequestNoAuthCredential_NoSessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: false)
        doh.status = .forceAlternativeRouting
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestAuthCredentialPassedByAuthDelegate_SessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { [self] result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        var doh: DoHInterface = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testAuthRequestOwnSessionIDPassesByAPIService_SessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { [self] result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        var doh: DoHInterface = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIService(doh: doh,
                                                       sessionUID: "OwnSessionID_123",
                                                       challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuthRequestAuthCredentailPassedByRequest_SessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { [self] result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=testSessionID.\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testAuthRequestAuthCredentailPassedByAuthDelegateAndRequest_SessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { [self] result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=testSessionID_2.\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=testSessionID_2.\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh as DoHInterface,
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate2.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testAuthRequestAuthCredentialPassesByAuthDelegateAndRequestANDAPIService_SessionID() {
        let expectation1 = self.expectation(description: "Success completion block called from provider 1")
        let expectation2 = self.expectation(description: "Success completion block called from provider 2")
        let expectation3 = self.expectation(description: "Success completion block called from provider 3")
        
        let networkingEngineMock = NetworkingEngineMock(data: nil, response: nil, error: nil) { [self] result in
            if let urlString = result.url?.absoluteString, urlString.contains("google.com") {
                XCTAssertTrue(urlString.contains("name=testSessionID_2.\(self.urlSuffix)"))
                expectation1.fulfill()
            } else if let urlString = result.url?.absoluteString, urlString.contains("dns11.quad9") {
                XCTAssertTrue(urlString.contains("name=testSessionID_2.\(self.urlSuffix)"))
                expectation2.fulfill()
            }
        }
        let doh = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService.createAPIService(doh: doh as DoHInterface,
                                                       sessionUID: "OwnSessionID_123",
                                                       challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate2.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.perform(request: request, response: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
