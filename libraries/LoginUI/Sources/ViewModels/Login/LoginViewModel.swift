//
//  LoginViewModel.swift
//  ProtonCore-Login - Created on 04/11/2020.
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

import Foundation
import ProtonCoreAuthentication
import ProtonCoreChallenge
import ProtonCoreDataModel
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreNetworking
import ProtonCoreObservability
import ProtonCoreServices

final class LoginViewModel {
    enum LoginResult {
        case done(LoginData)
        case ssoAuthorized(LoginData)
        case totpCodeNeeded
        case fido2KeyNeeded(AuthenticationOptions)
        case anyOfFido2TotpNeeded(AuthenticationOptions)
        case mailboxPasswordNeeded
        case createAddressNeeded(CreateAddressData, String?)
        case ssoChallenge(SSOChallengeResponse)
        case switchToSSOLogin(String)
    }

    // MARK: - Properties

    let finished = Publisher<LoginResult>()
    let error = Publisher<LoginError>()
    let isLoading = Observable<Bool>(false)

    weak var navigationDelegate: NavigationDelegate?

    var isSsoUIEnabled = false
    let subtitleLabel = LUITranslation.screen_subtitle.l10n
    var loginTextFieldTitle: String {
        isSsoUIEnabled ? LUITranslation.email_field_title.l10n : LUITranslation.username_title.l10n
    }
    var titleLabel: String {
        isSsoUIEnabled ? LUITranslation.sign_in_with_sso_title.l10n : LUITranslation._core_sign_in_screen_title.l10n
    }
    var signInWithSSOButtonTitle: String {
        isSsoUIEnabled ? LUITranslation.sign_in_button_with_password.l10n : LUITranslation.sign_in_with_sso_button.l10n
    }
    let passwordTextFieldTitle = LUITranslation.password_title.l10n
    let signInButtonTitle = LUITranslation.sign_in_button.l10n
    let signUpButtonTitle = LUITranslation.create_account_button.l10n

    private let login: Login
    private let api: APIService
    let challenge: PMChallenge
    let clientApp: ClientApp

    var isCurrentlyUsingProxyDomain: Bool {
        api.dohInterface.isCurrentlyUsingProxyDomain
    }

    init(api: APIService, login: Login, challenge: PMChallenge, clientApp: ClientApp) {
        self.api = api
        self.login = login
        self.challenge = challenge
        self.clientApp = clientApp
    }

    // MARK: - Actions

    func login(username: String, password: String) {
        self.challenge.appendCheckedUsername(username)
        isLoading.value = true

        let userFrame = ["name": "username"]
        let challengeData = self.challenge.export()
            .signupFingerprintDict()
            .first(where: { $0["frame"] as? [String: String] == userFrame })
        let intent: Intent = isSsoUIEnabled ? .sso : .auto

        login.login(username: username, password: password, intent: intent, challenge: challengeData) { [weak self] result in
            switch result {
            case let .failure(error):
                if error.codeInLogin == APIErrorCode.switchToSSOError {
                    self?.finished.publish(.switchToSSOLogin(error.userFacingMessageInLogin))
                } else {
                    self?.error.publish(error)
                }
                self?.isLoading.value = false
            case let .success(status):
                switch status {
                case let .finished(data):
                    self?.finished.publish(.done(data))
                case .askTOTP:
                    self?.finished.publish(.totpCodeNeeded)
                    self?.isLoading.value = false
                case let .askFIDO2(authenticationOptions):
                    self?.finished.publish(.fido2KeyNeeded(authenticationOptions))
                    self?.isLoading.value = false
                case let .askAny2FA(context):
                    self?.finished.publish(.anyOfFido2TotpNeeded(context))
                    self?.isLoading.value = false
                case .askSecondPassword:
                    self?.finished.publish(.mailboxPasswordNeeded)
                    self?.isLoading.value = false
                case .ssoChallenge(let ssoChallengeResponse):
                    self?.finished.publish(.ssoChallenge(ssoChallengeResponse))
                    self?.isLoading.value = false
                case let .chooseInternalUsernameAndCreateInternalAddress(data):
                    self?.login.availableUsernameForExternalAccountEmail(email: data.email) { [weak self] username in
                        self?.finished.publish(.createAddressNeeded(data, username))
                        self?.isLoading.value = false
                    }
                }
            }
        }
    }

    // MARK: - Validation

    func validate(username: String) -> Result<(), LoginValidationError> {
        return !username.isEmpty ? .success : .failure(.emptyUsername)
    }

    func validate(email: String) -> Result<(), LoginValidationError> {
        guard !email.isEmpty else { return .failure(.emptyEmail)}
        return email.isValidEmail() ? .success : .failure(.invalidEmail)
    }

    func validate(password: String) -> Result<(), LoginValidationError> {
        return !password.isEmpty ? .success : .failure(.emptyPassword)
    }

    func updateAvailableDomain(result: (([String]?) -> Void)? = nil) {
        login.updateAllAvailableDomains(type: .login) { res in result?(res) }
    }

    // MARK: - SSO

    func getSSOTokenFromURL(url: URL?) -> SSOResponseToken? {
        if let url = url,
           url.path == "/sso/login" {
            var components = URLComponents()
            components.query = url.fragment
            if let items = components.queryItems,
               let token = (items.first { $0.name == "token" }?.value),
               let uid = (items.first { $0.name == "uid" }?.value) {
                return .init(token: token, uid: uid)
            }
        }

        return nil
    }

    var ssoCallbackScheme: String? {
        login.ssoCallbackScheme
    }

    func getSSORequest(challenge ssoChallengeResponse: SSOChallengeResponse) async -> (request: URLRequest?, error: String?) {
        await login.getSSORequest(challenge: ssoChallengeResponse)
    }

    func getSSOURL(challenge ssoChallengeResponse: SSOChallengeResponse) async -> (url: URL?, error: String?) {
        await login.getSSOURL(challenge: ssoChallengeResponse)
    }

    struct SSORedirect {
        let url: URL
        let callbackScheme: String
    }

    /// Set in tests to resolve the challenge without networking.
    var performSSORequest: ((URLRequest) async throws -> (Data, URLResponse))?

    private let ssoRedirectBlocker = SSORedirectBlocker()

    private func makeSSOURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        // The API service's jar carries the cookies DoH copies onto the proxy domains, which the
        // challenge request needs when alternative routing is active.
        if let cookieStorage = api.dohInterface.currentlyUsedCookiesStorage {
            configuration.httpCookieStorage = cookieStorage
        }
        return URLSession(configuration: configuration)
    }

    /// Sends the authenticated `GET /auth/sso/{token}` request and returns the identity provider URL from
    /// the redirect response, along with the callback scheme the auth session has to watch for.
    func getSSORedirect(challenge ssoChallengeResponse: SSOChallengeResponse) async -> (redirect: SSORedirect?, error: String?) {
        isLoading.value = true
        defer { isLoading.value = false }

        let requestResult = await login.getSSORequest(challenge: ssoChallengeResponse)

        if let error = requestResult.error {
            ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
            return (nil, error)
        }

        guard let request = requestResult.request,
              let callbackScheme = Self.callbackScheme(from: request) else {
            PMLog.error("SSO request has no \(Self.finalRedirectBaseURLKey) to derive the callback scheme from", sendToExternal: true)
            ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
            return (nil, LUITranslation.sso_configuration_error.l10n)
        }

        do {
            // Sending through a session backed by the API service's jar puts any Set-Cookie there; synchronizing
            // copies them onto the proxy domains too, so a later alt-routed request carries them, the same
            // way PMAPIService does after every request. None of it reaches the auth session, hence the log.
            let (_, response) = try await performSSORedirectRequest(request)
            await api.dohInterface.synchronizeCookies(with: response, requestHeaders: request.allHTTPHeaderFields ?? [:])
            logSSOResponseCookies(from: response)

            guard let httpResponse = response as? HTTPURLResponse else {
                PMLog.error("SSO challenge response is not an HTTP response", sendToExternal: true)
                ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
                return (nil, LUITranslation.sso_configuration_error.l10n)
            }

            guard (300...399).contains(httpResponse.statusCode),
                  let location = httpResponse.value(forHTTPHeaderField: "Location"),
                  let redirectURL = URL(string: location, relativeTo: request.url)?.absoluteURL else {
                PMLog.error("SSO challenge did not redirect, status code \(httpResponse.statusCode)", sendToExternal: true)
                ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
                return (nil, LUITranslation.sso_configuration_error.l10n)
            }

            return (SSORedirect(url: redirectURL, callbackScheme: callbackScheme), nil)
        } catch {
            PMLog.error(error, sendToExternal: true)
            ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
            return (nil, error.localizedDescription)
        }
    }

    private static let finalRedirectBaseURLKey = "FinalRedirectBaseUrl"

    /// `getSSORequest` builds `FinalRedirectBaseUrl` out of the account host with its scheme replaced by
    /// the client's callback scheme, so the scheme can be read back off the request it produced.
    private static func callbackScheme(from request: URLRequest) -> String? {
        guard let url = request.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let finalRedirectBaseURL = components.queryItems?
            .first(where: { $0.name == finalRedirectBaseURLKey })?.value else {
            return nil
        }

        return URL(string: finalRedirectBaseURL)?.scheme
    }

    private func performSSORedirectRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        if let performSSORequest {
            return try await performSSORequest(request)
        }
        // A session holds on to itself until invalidated, so it is built per request and torn down here.
        let session = makeSSOURLSession()
        defer { session.finishTasksAndInvalidate() }
        return try await session.data(for: request, delegate: ssoRedirectBlocker)
    }

    /// These cookies land in the API service's jar, which `ASWebAuthenticationSession` cannot read, so a
    /// handoff that depends on them fails only once the redirect opens. Names only, never values.
    private func logSSOResponseCookies(from response: URLResponse) {
        #if DEBUG_CORE_INTERNALS
        guard let httpResponse = response as? HTTPURLResponse,
              let url = httpResponse.url,
              let headerFields = httpResponse.allHeaderFields as? [String: String] else {
            return
        }

        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)

        guard !cookies.isEmpty else {
            PMLog.debug("[COOKIES][SSO] challenge response set no cookies")
            return
        }

        let details = cookies.map {
            "\($0.name) (domain: \($0.domain), path: \($0.path), expires: \($0.expiresDate?.description ?? "session"), secure: \($0.isSecure))"
        }
        PMLog.debug("[COOKIES][SSO] challenge response set \(cookies.count) cookie(s), not visible to the auth session: \(details.joined(separator: ", "))")
        #endif
    }

    @available(*, deprecated, renamed: "processResponseTokenV2", message: "Remove as part of GSSO")
    func processResponseToken(idpEmail: String, responseToken: SSOResponseToken) {
        isLoading.value = true
        login.processResponseToken(idpEmail: idpEmail, responseToken: responseToken) { [weak self] result in
            switch result {
            case .success(.finished(let data)):
                ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .successful))
                self?.finished.publish(.done(data))
            case let .failure(error):
                ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
                self?.error.publish(error)
                self?.isLoading.value = false
            default:
                self?.error.publish(.invalidState)
                self?.isLoading.value = false
            }
        }
    }

    func processResponseTokenV2(idpEmail: String, responseToken: SSOResponseToken) {
        isLoading.value = true
        Task { [weak self] in
            guard let self else { return }
            do {
                ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .successful))
                let loginStatus = try await self.login.validateAndAuthenticateSSO(idpEmail: idpEmail, responseToken: responseToken)
                guard case .finished(let userData) = loginStatus else {
                    throw LoginError.invalidState
                }
                self.finished.publish(.ssoAuthorized(userData))
            } catch {
                PMLog.error(error, sendToExternal: true)
                ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
                if let loginError = error as? LoginError {
                    self.error.publish(loginError)
                } else {
                    self.error.publish(LoginError.generic(
                        message: error.localizedDescription,
                        code: error.responseCode ?? -1,
                        originalError: error
                    ))
                }
                self.isLoading.value = false
            }
        }
    }

    func isProtonPage(url: URL?) -> Bool {
        login.isProtonPage(url: url)
    }
}

// MARK: - SSO redirect blocking

/// `URLSession` follows the challenge redirect on its own, which would fetch the identity provider page
/// instead of handing its URL back to us. Refusing the redirect completes the task with the 3xx response.
private final class SSORedirectBlocker: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

// MARK: 2FA Provider Delegate 

extension LoginViewModel: TwoFAProviderDelegate {
    func userDidGoBack() {
        navigationDelegate?.userDidGoBack()
    }

    func userDidClose() {
        navigationDelegate?.userDidClose()
    }

    func providerDidObtain(factor: String) async throws {
       try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            login.provide2FACode(factor) { [weak self] result in
                self?.callbackForDidObtain(result: result, continuation: continuation)
            }
       }
    }

    func providerDidObtain(factor: ProtonCoreAuthentication.Fido2Signature) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            login.provideFido2Signature(factor) { [weak self] result in
                self?.callbackForDidObtain(result: result, continuation: continuation)
            }
        }
    }

    private func callbackForDidObtain(result: Result<LoginStatus, LoginError>, continuation: CheckedContinuation<Void, any Error>) {
        switch result {
        case let .failure(loginError):
            error.publish(loginError)
            continuation.resume(throwing: loginError)
        case let .success(status):
            switch status {
            case let .finished(data):
                finished.publish(.done(data))
                continuation.resume()
            case let .chooseInternalUsernameAndCreateInternalAddress(data):
                login.availableUsernameForExternalAccountEmail(email: data.email) { [weak self] username in
                    self?.finished.publish(.createAddressNeeded(data, username))
                    continuation.resume()
                }
            case .askTOTP, .askAny2FA, .askFIDO2:
                PMLog.error("Asking for 2FA validation after successful 2FA validation is an invalid state", sendToExternal: true)
                   error.publish(.invalidState)
                continuation.resume(throwing: LoginError.invalidState)
            case .askSecondPassword:
                finished.publish(.mailboxPasswordNeeded)
                continuation.resume()
            case .ssoChallenge:
                PMLog.error("Receiving SSO challenge after successful 2FA code is an invalid state", sendToExternal: true)
                    error.publish(.invalidState)
                continuation.resume(throwing: LoginError.invalidState)
            }
        }
    }

}

#endif
