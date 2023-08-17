//
//  LoginViewControllerTests.swift
//  ProtonCore-Login-Tests - Created on 24.05.23.
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
import WebKit
@testable import ProtonCoreLoginUI
import ProtonCoreChallenge
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreObservability

final class LoginViewControllerTests: XCTestCase {
    var sut: LoginViewController!
    var loginMock: LoginMock!
    var observabilityServiceMock: ObservabilityServiceMock!
    
    override func setUp() {
        super.setUp()
        loginMock = .init()
        observabilityServiceMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observabilityServiceMock
        sut = LoginViewController()
        sut.viewModel = LoginViewModel(api: APIServiceMock(), login: loginMock, challenge: PMChallenge(), clientApp: .vpn)
    }
    
    func test_wkNavigationDelegate_tracks_http2xx_forAnyURL() {
        // Given
        
        let webView = WKWebView(frame: .zero)
        let response = FakeNavigationResponse(httpResponseCode: .http2xx, url: URL(string: "https://very.third-party.page")!)
        loginMock.isProtonPageStub.bodyIs { _, _ in false }
        let expectedEvent: ObservabilityEvent = .ssoIDPPageLoadCountTotal(status: .http2xx)
                    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: response, decisionHandler: response.decisionHandler)
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_wkNavigationDelegate_tracks_http4xx_forAnyURL() {
        // Given
        
        let webView = WKWebView(frame: .zero)
        let response = FakeNavigationResponse(httpResponseCode: .http4xx, url: URL(string: "https://very.third-party.page")!)
        loginMock.isProtonPageStub.bodyIs { _, _ in false }
        let expectedEvent: ObservabilityEvent = .ssoIDPPageLoadCountTotal(status: .http4xx)
                    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: response, decisionHandler: response.decisionHandler)
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_wkNavigationDelegate_tracks_http5xx_forAnyURL() {
        // Given
        
        let webView = WKWebView(frame: .zero)
        let response = FakeNavigationResponse(httpResponseCode: .http5xx, url: URL(string: "https://very.third-party.page")!)
        loginMock.isProtonPageStub.bodyIs { _, _ in false }
        let expectedEvent: ObservabilityEvent = .ssoIDPPageLoadCountTotal(status: .http5xx)
                    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: response, decisionHandler: response.decisionHandler)
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_wkNavigationDelegate_tracks_http2xx_forProtonURL() {
        // Given
        
        let webView = WKWebView(frame: .zero)
        let response = FakeNavigationResponse(httpResponseCode: .http2xx, url: URL(string: "https://very.proton.page")!)
        loginMock.isProtonPageStub.bodyIs { _, _ in true }
        let expectedEvent: ObservabilityEvent = .ssoProtonPageLoadCountTotal(status: .http2xx)
                    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: response, decisionHandler: response.decisionHandler)
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_wkNavigationDelegate_tracks_http4xx_forProtonURL() {
        // Given
        
        let webView = WKWebView(frame: .zero)
        let response = FakeNavigationResponse(httpResponseCode: .http4xx, url: URL(string: "https://very.proton.page")!)
        loginMock.isProtonPageStub.bodyIs { _, _ in true }
        let expectedEvent: ObservabilityEvent = .ssoProtonPageLoadCountTotal(status: .http4xx)
                    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: response, decisionHandler: response.decisionHandler)
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_wkNavigationDelegate_tracks_http5xx_forProtonURL() {
        // Given
        
        let webView = WKWebView(frame: .zero)
        let response = FakeNavigationResponse(httpResponseCode: .http5xx, url: URL(string: "https://very.proton.page")!)
        loginMock.isProtonPageStub.bodyIs { _, _ in true }
        let expectedEvent: ObservabilityEvent = .ssoProtonPageLoadCountTotal(status: .http5xx)
                    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: response, decisionHandler: response.decisionHandler)
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_wkNavigationDelegate_cancels_uponTokenReception() {
        // Given
        let token = "92834urjhfog34"
        let uid = "98h2biw4uaekjf"
        let webView = WKWebView(frame: .zero)
        let url = URL(string: "http://account.proton.me/sso/login#token=\(token)&uid=\(uid)")!
        let action = FakeNavigationAction(url: url)
        action.setExpectation(expectation: .cancel)
        
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: action, decisionHandler: action.decisionHandler)
        XCTAssertTrue(loginMock.processResponseTokenStub.wasCalledExactlyOnce)
    }
    
    func test_wkNavigationDelegate_allowsAnyURL() {
        // Given
        let webView = WKWebView(frame: .zero)
        let url = URL(string: "http://anyUrl.com")!
        let action = FakeNavigationAction(url: url)
        action.setExpectation(expectation: .allow)
    
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: action, decisionHandler: action.decisionHandler)
    }
    
    func test_wkNavigationDelegate_withToken_callsProcessResponseToken() {
        // Given
        let token = "92834urjhfog34"
        let uid = "98h2biw4uaekjf"
        let webView = WKWebView(frame: .zero)
        let url = URL(string: "http://account.proton.me/sso/login#token=\(token)&uid=\(uid)")!
        let action = FakeNavigationAction(url: url)
        action.setExpectation(expectation: .cancel)
        let loginVC = setupVCThroughStoryboard()
        
        // When
        loginVC.webView(webView, decidePolicyFor: action, decisionHandler: action.decisionHandler)
        
        // Then
        XCTAssertTrue(loginMock.processResponseTokenStub.wasCalledExactlyOnce)
    }
    
    func test_wkNavigationDelegate_withoutToken_doesNotCallProcessResponseToken() {
        // Given
        let webView = WKWebView(frame: .zero)
        let url = URL(string: "http://anyUrl.com")!
        let action = FakeNavigationAction(url: url)
        action.setExpectation(expectation: .allow)
        
        // When
        sut.webView(webView, decidePolicyFor: action, decisionHandler: action.decisionHandler)
        
        // Then
        XCTAssertTrue(loginMock.processResponseTokenStub.wasNotCalled)
    }
    
    private func setupVCThroughStoryboard() -> LoginViewController {
        let loginVC = UIStoryboard.instantiate(storyboardName: "PMLogin", controllerType: LoginViewController.self, inAppTheme: { .default })
        loginVC.viewModel = LoginViewModel(api: APIServiceMock(), login: loginMock, challenge: PMChallenge(), clientApp: .vpn)
        loginVC.loadView()
        return loginVC
    }
}

final class FakeNavigationResponse: WKNavigationResponse {
    let fakeResponse: HTTPURLResponse
    
    enum HTTPResponseCode {
        case http2xx
        case http4xx
        case http5xx
    }
    
    override var response: URLResponse {
        fakeResponse
    }
    
    init(httpResponseCode: HTTPResponseCode, url: URL) {
        switch httpResponseCode {
        case .http2xx:
            fakeResponse = .init(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        case .http4xx:
            fakeResponse = .init(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!
        case .http5xx:
            fakeResponse = .init(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        }
    }
    
    func decisionHandler(_ policy: WKNavigationResponsePolicy) {}
}

final class FakeNavigationAction: WKNavigationAction {
    let urlRequest: URLRequest
    
    var receivedPolicy: WKNavigationActionPolicy?
    var expectation: WKNavigationActionPolicy?
    
    override var request: URLRequest { urlRequest }
    
    func setExpectation(expectation: WKNavigationActionPolicy) {
        self.expectation = expectation
    }

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init()
    }
    
    convenience init(url: URL) {
        self.init(urlRequest: URLRequest(url: url))
    }
    
    func decisionHandler(_ policy: WKNavigationActionPolicy) {
        XCTAssertEqual(expectation, policy)
    }
}

#endif
