//
//  LoginViewModelTests.swift
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
import TrustKit

@testable import ProtonCoreAuthentication
@testable import ProtonCoreChallenge
import ProtonCoreLogin
@testable import ProtonCoreLoginUI
@testable import ProtonCoreNetworking
@testable import ProtonCoreObservability
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreUIFoundations

final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var apiService: APIServiceMock!
    var dohMock: DohInterfaceMock!
    var login: LoginMock!
    var observabilityServiceMock: ObservabilityServiceMock!

    override func setUp() {
        super.setUp()
        setupMock()
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))
    }

    private func setupMock() {
        observabilityServiceMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observabilityServiceMock
        apiService = APIServiceMock()
        dohMock = DohInterfaceMock()
        dohMock.getCurrentlyUsedUrlHeadersStub.bodyIs { _ in [:] }
        let serviceDelegate = APIServiceDelegateMock()
        serviceDelegate.appVersionStub.fixture = "ios-core@1.2.3"
        serviceDelegate.userAgentStub.fixture = "TestUserAgent"
        serviceDelegate.localeStub.fixture = "en_US"
        apiService.serviceDelegateStub.fixture = serviceDelegate
        login = LoginMock()
    }

    func test_labels_ssoUIEnabled() {
        // Given
        sut.isSsoUIEnabled = true

        // Then
        XCTAssertEqual(sut.loginTextFieldTitle, LUITranslation.email_field_title.l10n)
        XCTAssertEqual(sut.titleLabel, LUITranslation.sign_in_with_sso_title.l10n)
        XCTAssertEqual(sut.signUpButtonTitle, LUITranslation.create_account_button.l10n)
        XCTAssertEqual(sut.signInWithSSOButtonTitle, LUITranslation.sign_in_button_with_password.l10n)
    }

    func test_labels_ssoUIDisabled() {
        // Given
        sut.isSsoUIEnabled = false

        // Then
        XCTAssertEqual(sut.loginTextFieldTitle, LUITranslation.username_title.l10n)
        XCTAssertEqual(sut.titleLabel, LUITranslation._core_sign_in_screen_title.l10n)
        XCTAssertEqual(sut.signUpButtonTitle, LUITranslation.create_account_button.l10n)
        XCTAssertEqual(sut.signInWithSSOButtonTitle, LUITranslation.sign_in_with_sso_button.l10n)
    }

    // MARK: - getSSOTokenFromURL

    func test_getSSOTokenFromURL_getsTokenFromValidURL() {
        // Given
        let token = "92834urjhfog34"
        let uid = "98h2biw4uaekjf"
        let url = URL(string: "http://account.proton.me/sso/login#token=\(token)&uid=\(uid)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertEqual(tokenFromHost, .init(token: token, uid: uid))
    }

    func test_getSSOTokenFromURL_getsNilFromURLWithoutToken() {
        // Given
        let uid = "98h2biw4uaekjf"
        let url = URL(string: "https://account.proton.me/sso/login#uid=\(uid)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertNil(tokenFromHost)
    }

    func test_getSSOTokenFromURL_getsNilFromURLWithoutUid() {
        // Given
        let token = "98h2biw4uaekjf"
        let url = URL(string: "https://account.proton.me/sso/login#token=\(token)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertNil(tokenFromHost)
    }

    func test_getSSOTokenFromURL_getsNilFromBadURL() {
        // Given
        let url = URL(string: "bad url")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertNil(tokenFromHost)
    }

    func test_getSSOTokenFromURL_getsTokenFromCustomSchemeCallbackURL() {
        // Given — callback URL from ASWebAuthenticationSession with custom scheme
        let token = "92834urjhfog34"
        let uid = "98h2biw4uaekjf"
        let url = URL(string: "protonmail://account.proton.me/sso/login#token=\(token)&uid=\(uid)")

        // When
        let tokenFromHost = sut.getSSOTokenFromURL(url: url)

        // Then
        XCTAssertEqual(tokenFromHost, .init(token: token, uid: uid))
    }

    // MARK: - GetSSORequest
    private var token: String { "0r8wj34iufe" }
    private var challenge: SSOChallengeResponse { .init(ssoChallengeToken: token) }

    func test_getSSORequest_withCredentials_succeed() async {
        // Given
        let credentials = AuthCredential(
            sessionID: "sessionID",
            accessToken: "accessToken",
            refreshToken: "refreshToken",
            userName: "userName",
            userID: "userID",
            privateKey: nil,
            passwordKeySalt: nil
        )
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: credentials))
        }
        apiService.dohInterfaceStub.fixture = dohMock
        apiService.sessionUIDStub.fixture = "testSessionUID"
        dohMock.getAccountHostStub.bodyIs { _ in "https://proton.unittests/account" }
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in
            "http://account.proton.test/api"
        }

        // When
        let ssoRequestResult = await sut.getSSORequest(challenge: challenge)

        // Then
        XCTAssertNil(ssoRequestResult.error)
        XCTAssertEqual(ssoRequestResult.request?.url, URL(string: "http://account.proton.test/api/auth/sso/\(token)"))
        let headers = ssoRequestResult.request?.allHTTPHeaderFields
        XCTAssertEqual(headers?["Authorization"], "Bearer accessToken")
        XCTAssertEqual(headers?["x-pm-uid"], "testSessionUID")
        XCTAssertEqual(headers?["x-pm-appversion"], "ios-core@1.2.3")
        XCTAssertEqual(headers?["User-Agent"], "TestUserAgent")
        XCTAssertEqual(headers?["x-pm-locale"], "en_US")
    }

    func test_getSSORequest_withoutCredentials_fails() async {
        // Given
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.notFound)
        }
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        // When
        let ssoRequestResult = await sut.getSSORequest(challenge: challenge)

        // Then
        XCTAssertNil(ssoRequestResult.request)
        XCTAssertEqual(ssoRequestResult.error, "Empty token")
    }

    func test_getSSORequest_withWrongConfiguration_fails() async {
        // Given
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.wrongConfigurationNoDelegate)
        }
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        // When
        let ssoRequestResult = await sut.getSSORequest(challenge: challenge)

        // Then
        XCTAssertNil(ssoRequestResult.request)
        XCTAssertEqual(ssoRequestResult.error, "AuthDelegate is required")
    }

    // MARK: - getSSORedirect

    private var accountHost: String { "https://account.proton.test" }
    private var challengeURL: URL { URL(string: "\(accountHost)/api/auth/sso/\(token)")! }

    private func makeSUTResolvingSSORequests(ssoCallbackScheme: String? = "protonvpn") -> LoginViewModel {
        let credentials = AuthCredential(
            sessionID: "sessionID",
            accessToken: "accessToken",
            refreshToken: "refreshToken",
            userName: "userName",
            userID: "userID",
            privateKey: nil,
            passwordKeySalt: nil
        )
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: credentials))
        }
        apiService.dohInterfaceStub.fixture = dohMock
        apiService.sessionUIDStub.fixture = "testSessionUID"
        dohMock.getAccountHostStub.bodyIs { _ in self.accountHost }
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "\(self.accountHost)/api" }
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, _, completion in
            completion(false)
        }
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in false }

        let login = LoginService(api: apiService,
                                 clientApp: .vpn,
                                 minimumAccountType: .external,
                                 ssoCallbackScheme: ssoCallbackScheme)
        return LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))
    }

    private func challengeResponse(statusCode: Int, headerFields: [String: String] = [:]) -> HTTPURLResponse {
        HTTPURLResponse(url: challengeURL, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headerFields)!
    }

    func test_getSSORedirect_withRedirectResponse_returnsLocationAndCallbackScheme() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        let identityProviderURL = "https://idp.proton.test/authorize?state=abc"
        let response = challengeResponse(statusCode: 303, headerFields: ["Location": identityProviderURL])
        sut.performSSORequest = { _ in (Data(), response) }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.error)
        XCTAssertEqual(result.redirect?.url, URL(string: identityProviderURL))
        XCTAssertEqual(result.redirect?.callbackScheme, "protonvpn")
    }

    func test_getSSORedirect_sendsTheRequestBuiltByGetSSORequest() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        let response = challengeResponse(statusCode: 303, headerFields: ["Location": "https://idp.proton.test"])
        var sentRequest: URLRequest?
        sut.performSSORequest = { request in
            sentRequest = request
            return (Data(), response)
        }

        // When
        _ = await sut.getSSORedirect(challenge: challenge)

        // Then
        let request = sentRequest
        XCTAssertEqual(request?.url?.path, "/api/auth/sso/\(token)")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer accessToken")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "x-pm-uid"), "testSessionUID")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "x-pm-appversion"), "ios-core@1.2.3")
    }

    func test_getSSORedirect_withRelativeLocation_resolvesAgainstRequestURL() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        let response = challengeResponse(statusCode: 302, headerFields: ["Location": "/sso/redirect?state=abc"])
        sut.performSSORequest = { _ in (Data(), response) }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.error)
        XCTAssertEqual(result.redirect?.url, URL(string: "\(accountHost)/sso/redirect?state=abc"))
    }

    func test_getSSORedirect_withoutRedirectStatusCode_fails() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        let response = challengeResponse(statusCode: 200, headerFields: ["Location": "https://idp.proton.test"])
        sut.performSSORequest = { _ in (Data(), response) }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, LUITranslation.sso_configuration_error.l10n)
    }

    func test_getSSORedirect_withoutLocationHeader_fails() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        let response = challengeResponse(statusCode: 303)
        sut.performSSORequest = { _ in (Data(), response) }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, LUITranslation.sso_configuration_error.l10n)
    }

    func test_getSSORedirect_withoutCallbackScheme_failsWithoutSendingTheRequest() async {
        // Given — no ssoCallbackScheme means no FinalRedirectBaseUrl to read the scheme back from
        let sut = makeSUTResolvingSSORequests(ssoCallbackScheme: nil)
        let response = challengeResponse(statusCode: 303, headerFields: ["Location": "https://idp.proton.test"])
        var requestWasSent = false
        sut.performSSORequest = { _ in
            requestWasSent = true
            return (Data(), response)
        }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, LUITranslation.sso_configuration_error.l10n)
        XCTAssertFalse(requestWasSent)
    }

    func test_getSSORedirect_whenRequestFails_surfacesTheError() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        sut.performSSORequest = { _ in
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "The network connection was lost"])
        }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, "The network connection was lost")
    }

    func test_getSSORedirect_withoutCredentials_propagatesTheRequestError() async {
        // Given
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.notFound)
        }
        let login = LoginService(api: apiService, clientApp: .vpn, minimumAccountType: .external)
        sut = LoginViewModel(api: apiService, login: login, challenge: PMChallenge(), clientApp: .other(named: "core"))

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, "Empty token")
    }

    func test_getSSORedirect_whenItFails_tracksFailure() async {
        // Given
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)
        let sut = makeSUTResolvingSSORequests()
        let response = challengeResponse(statusCode: 200)
        sut.performSSORequest = { _ in (Data(), response) }

        // When
        _ = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertTrue(observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    // MARK: - getSSORedirect alternative routing

    private var proxyHost: String { "https://proxy.proton.test" }

    func test_getSSORedirect_whenDoHResolvesProxy_retriesOnTheProxyHost() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        var proxyIsActive = false
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in
            proxyIsActive ? "\(self.proxyHost)/api" : "\(self.accountHost)/api"
        }
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, error, _, completion in
            guard error != nil else { completion(false); return }
            proxyIsActive = true
            completion(true)
        }
        let identityProviderURL = "https://idp.proton.test/authorize"
        var sentRequests: [URLRequest] = []
        sut.performSSORequest = { request in
            sentRequests.append(request)
            guard sentRequests.count > 1 else { throw URLError(.timedOut) }
            let response = HTTPURLResponse(url: request.url!, statusCode: 303, httpVersion: "HTTP/1.1",
                                           headerFields: ["Location": identityProviderURL])!
            return (Data(), response)
        }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.error)
        XCTAssertEqual(result.redirect?.url, URL(string: identityProviderURL))
        XCTAssertEqual(sentRequests.count, 2)
        XCTAssertEqual(sentRequests.first?.url?.host, "account.proton.test")
        XCTAssertEqual(sentRequests.last?.url?.host, "proxy.proton.test")
    }

    func test_getSSORedirect_whenDoHDoesNotRetryABlockedHost_reportsServersUnreachable() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in true }
        var requestCount = 0
        sut.performSSORequest = { _ in
            requestCount += 1
            throw URLError(.cannotFindHost)
        }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, LUITranslation._core_api_might_be_blocked_message.l10n)
        XCTAssertEqual(requestCount, 1)
    }

    func test_getSSORedirect_whenDoHKeepsAskingForRetries_stopsAtTheAttemptCap() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, _, completion in
            completion(true)
        }
        var requestCount = 0
        sut.performSSORequest = { _ in
            requestCount += 1
            throw URLError(.timedOut)
        }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertNil(result.redirect)
        XCTAssertEqual(requestCount, LoginViewModel.maxSSOAttempts)
    }

    func test_getSSORedirect_whenPinningRejectsTheServer_passesTheTLSErrorToDoHAndReportsInsecureConnection() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        var errorPassedToDoH: Error?
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, error, _, completion in
            errorPassedToDoH = error
            completion(false)
        }
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in true }
        sut.performSSORequest = { _ in
            throw NSError.protonMailError(APIErrorCode.tls, localizedDescription: NWTranslation.insecure_connection_error.l10n)
        }

        // When
        let result = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertEqual((errorPassedToDoH as? NSError)?.code, APIErrorCode.tls)
        XCTAssertNil(result.redirect)
        XCTAssertEqual(result.error, NWTranslation.insecure_connection_error.l10n)
    }

    func test_getSSORedirect_callsDoHOncePerAttemptWithTheSentRequest() async {
        // Given
        let sut = makeSUTResolvingSSORequests()
        var doHCalls: [(host: String, headers: [String: String], sessionID: String?)] = []
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, host, headers, sessionID, _, _, _, completion in
            doHCalls.append((host, headers, sessionID))
            completion(doHCalls.count < 2)
        }
        let response = challengeResponse(statusCode: 303, headerFields: ["Location": "https://idp.proton.test"])
        var sentRequests: [URLRequest] = []
        sut.performSSORequest = { request in
            sentRequests.append(request)
            return (Data(), response)
        }

        // When
        _ = await sut.getSSORedirect(challenge: challenge)

        // Then
        XCTAssertEqual(doHCalls.count, 2)
        XCTAssertEqual(sentRequests.count, 2)
        XCTAssertEqual(doHCalls.first?.host, sentRequests.first?.url?.absoluteString)
        XCTAssertEqual(doHCalls.first?.headers["Authorization"], "Bearer accessToken")
        XCTAssertEqual(doHCalls.first?.sessionID, "testSessionUID")
    }

    func test_getSSORedirect_whenSeveralAttemptsFail_tracksFailureOnce() async {
        // Given
        let failedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)
        let sut = makeSUTResolvingSSORequests()
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, _, completion in
            completion(true)
        }
        sut.performSSORequest = { _ in throw URLError(.timedOut) }

        // When
        _ = await sut.getSSORedirect(challenge: challenge)

        // Then
        let failureReports = observabilityServiceMock.reportStub.capturedArguments.filter { $0.value.isSameAs(event: failedEvent) }
        XCTAssertEqual(failureReports.count, 1)
    }

    // MARK: - SSOChallengeSessionDelegate

    private func makeChallenge() -> URLAuthenticationChallenge {
        let protectionSpace = URLProtectionSpace(host: "account.proton.test", port: 443, protocol: "https",
                                                 realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        return URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0,
                                          failureResponse: nil, error: nil, sender: ChallengeSenderStub())
    }

    private func sendChallenge(to delegate: SSOChallengeSessionDelegate) -> (disposition: URLSession.AuthChallengeDisposition?, credential: URLCredential?) {
        let task = URLSession.shared.dataTask(with: challengeURL)
        var result: (disposition: URLSession.AuthChallengeDisposition?, credential: URLCredential?) = (nil, nil)
        delegate.urlSession(URLSession.shared, task: task, didReceive: makeChallenge()) { disposition, credential in
            result = (disposition, credential)
        }
        return result
    }

    func test_ssoChallengeSessionDelegate_forwardsTheChallengeAndTheHandlersResult() {
        // Given
        let credential = URLCredential(user: "user", password: "password", persistence: .none)
        let forwardedChallenge = ChallengeBox()
        let delegate = SSOChallengeSessionDelegate { challenge, completionHandler in
            forwardedChallenge.challenge = challenge
            completionHandler(.useCredential, credential)
        }

        // When
        let result = sendChallenge(to: delegate)

        // Then
        XCTAssertEqual(forwardedChallenge.challenge?.protectionSpace.authenticationMethod, NSURLAuthenticationMethodServerTrust)
        XCTAssertEqual(result.disposition, .useCredential)
        XCTAssertIdentical(result.credential, credential)
        XCTAssertFalse(delegate.rejectedServerTrust)
    }

    func test_ssoChallengeSessionDelegate_whenTheHandlerCancels_recordsTheRejection() {
        // Given
        let delegate = SSOChallengeSessionDelegate { _, completionHandler in
            completionHandler(.cancelAuthenticationChallenge, nil)
        }

        // When
        let result = sendChallenge(to: delegate)

        // Then
        XCTAssertEqual(result.disposition, .cancelAuthenticationChallenge)
        XCTAssertTrue(delegate.rejectedServerTrust)
    }

    func test_ssoChallengeSessionDelegate_whenTheHandlerFallsBackToDefaultHandling_doesNotRecordARejection() {
        // Given
        let delegate = SSOChallengeSessionDelegate { _, completionHandler in
            completionHandler(.performDefaultHandling, nil)
        }

        // When
        let result = sendChallenge(to: delegate)

        // Then
        XCTAssertEqual(result.disposition, .performDefaultHandling)
        XCTAssertFalse(delegate.rejectedServerTrust)
    }

    func test_ssoChallengeSessionDelegate_refusesRedirects() {
        // Given
        let delegate = SSOChallengeSessionDelegate { _, completionHandler in completionHandler(.performDefaultHandling, nil) }
        let task = URLSession.shared.dataTask(with: challengeURL)
        let response = challengeResponse(statusCode: 303, headerFields: ["Location": "https://idp.proton.test"])
        var redirectRequest: URLRequest? = URLRequest(url: challengeURL)

        // When
        delegate.urlSession(URLSession.shared, task: task, willPerformHTTPRedirection: response,
                            newRequest: URLRequest(url: URL(string: "https://idp.proton.test")!)) { request in
            redirectRequest = request
        }

        // Then
        XCTAssertNil(redirectRequest)
    }

    // MARK: - processResponseToken

    func test_processResponseToken_tracksSuccess() {
        // Given
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .successful)
        login.processResponseTokenStub.bodyIs { _, _, _, completion in
            completion(.success(.finished(.init(credential: .dummy, user: .dummy, salts: [], passphrases: [:], addresses: [], scopes: []))))
        }

        // When
        sut.processResponseToken(idpEmail: "", responseToken: .init(token: "", uid: ""))

        // Then
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }

    func test_processResponseToken_tracksFailure() {
        // Given
        let expectedEvent: ObservabilityEvent = .ssoIdentityProviderLoginResult(status: .failed)
        login.processResponseTokenStub.bodyIs { _, _, _, completion in
            completion(.failure(.invalidState))
        }

        // When
        sut.processResponseToken(idpEmail: "", responseToken: .init(token: "", uid: ""))

        // Then
        XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
}

private final class ChallengeBox: @unchecked Sendable {
    var challenge: URLAuthenticationChallenge?
}

private final class ChallengeSenderStub: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}

#endif
