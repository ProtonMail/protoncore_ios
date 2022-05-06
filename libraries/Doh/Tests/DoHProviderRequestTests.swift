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
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Authentication

class DoHProviderRequestTests: XCTestCase {
    
    // swiftlint:disable:next weak_delegate
    var authDelegate: TestAuthDelegate!
    var authDelegate2: TestAuthDelegate!
    let timeout = 2.0
    
    override func setUp() {
        authDelegate = TestAuthDelegate(sessionID: "testSessionID")
        authDelegate2 = TestAuthDelegate(sessionID: "testSessionID_2")
        super.setUp()
    }
    
    class TestAuthDelegate: AuthDelegate {
        func onForceUpgrade() { }
        var authCredential: AuthCredential? {
            testAuthCredential
        }
        func getToken(bySessionUID uid: String) -> AuthCredential? {
            testAuthCredential
        }
        func onLogout(sessionUID uid: String) { }
        func onUpdate(auth: Credential) { }
        func onRevoke(sessionUID uid: String) { }
        func onRefresh(bySessionUID uid: String, complete: (Credential?, AuthErrors?) -> Void) { }
        
        private var testAuthCredential: AuthCredential? {
            AuthCredential(sessionID: sessionID, accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date().addingTimeInterval(60 * 60), userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
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
        
        init(path: String, isAuth: Bool, authCredential: AuthCredential? = nil) {
            self.path = path
            self.isAuth = isAuth
            self.authCredential = authCredential
        }
    }
    
    let urlSuffix = "doh.query.text.protonpro"
    
    func testNotAuthRequestAuthCredentialPassedByAuthDelegate_NoSessionID() {
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "")
        let request = GenericRequest(path: "/users/testPath", isAuth: false)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "")
        let request = GenericRequest(path: "/users/testPath", isAuth: false)
        doh.status = .forceAlternativeRouting
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "")
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "OwnSessionID_123")
        let request = GenericRequest(path: "/users/testPath", isAuth: true)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "")
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "")
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate2.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
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
        let doh: DoH & ServerConfig = DohMock.mockWithMockNetworkingEngine(networkingEngine: networkingEngineMock)
        let apiService = PMAPIService(doh: doh, sessionUID: "OwnSessionID_123")
        let request = GenericRequest(path: "/users/testPath", isAuth: true, authCredential: authDelegate2.authCredential)
        doh.status = .forceAlternativeRouting
        apiService.authDelegate = authDelegate
        
        apiService.exec(route: request, responseObject: AuthResponse()) { (task, response: AuthResponse) in
            expectation3.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
