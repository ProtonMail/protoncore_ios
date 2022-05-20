//
//  AccountDeletionViewModel.swift
//  ProtonCore-AccountDeletion - Created on 10.12.21.
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

#if canImport(ProtonCore_Authentication)
import ProtonCore_Authentication
#else
import PMAuthentication
#endif
#if canImport(ProtonCore_Networking)
import ProtonCore_Networking
#else
import PMCommon
#endif
#if canImport(ProtonCore_Doh)
import ProtonCore_Doh
#endif
#if canImport(ProtonCore_Services)
import ProtonCore_Services
#endif
#if canImport(ProtonCore_CoreTranslation)
import ProtonCore_CoreTranslation
#else
import PMCoreTranslation
#endif
import WebKit

public enum NotificationType: String, Codable {
    case error
    case warning
    case info
    case success
}

public protocol AccountDeletionViewModelInterface {
    
    var getURLRequest: URLRequest { get }
    
    func setup(webViewConfiguration: WKWebViewConfiguration)
    
    func shouldRetryFailedLoading(host: String, error: Error, shouldReloadWebView: @escaping (Bool) -> Void)
    
    func interpretMessage(_ message: WKScriptMessage,
                          loadedPresentation: @escaping () -> Void,
                          notificationPresentation: @escaping (NotificationType, String) -> Void,
                          successPresentation: @escaping () -> Void,
                          closeWebView: @escaping (@escaping () -> Void) -> Void)
    
    func deleteAccountWasClosed()
    
    func deleteAccountDidErrorOut(message: String)
}

final class AccountDeletionViewModel: AccountDeletionViewModelInterface {
    
    enum AccountDeletionMessageType: String, Codable {
        case loaded = "LOADED"
        case success = "SUCCESS"
        case error = "ERROR"
        case close = "CLOSE"
        case notification = "NOTIFICATION"
    }
    
    struct AccountDeletionMessagePayload: Codable {
        // error message payload
        let message: String?
        
        // notification message payload
        let type: NotificationType?
        let text: String?
    }
    
    struct AccountDeletionMessage: Codable {
        let type: AccountDeletionMessageType
        let payload: AccountDeletionMessagePayload?
    }
    
    var getURLRequest: URLRequest {
        let host = doh.getAccountHost()
        let url = URL(string: "\(host)/lite?action=delete-account#selector=\(forkSelector)")!
        return URLRequest(url: url)
    }
    
    var jsonDecoder = JSONDecoder()
    
    private let forkSelector: String
    private let apiService: APIService
    private let doh: DoHServerConfig
    private let performBeforeClosingAccountDeletionScreen: (@escaping () -> Void) -> Void
    private let completion: (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    
    enum AccountDeletionState {
        case notDeletedYet
        case alreadyDeleted
        case finishedWithoutDeletion
    }
    
    private var state: AccountDeletionState = .notDeletedYet
    
    init(forkSelector: String,
         apiService: APIService,
         doh: DoHServerConfig,
         performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
         completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void) {
        self.forkSelector = forkSelector
        self.apiService = apiService
        self.doh = doh
        self.performBeforeClosingAccountDeletionScreen = performBeforeClosingAccountDeletionScreen
        self.completion = completion
    }
    
    func setup(webViewConfiguration: WKWebViewConfiguration) {
        let requestInterceptor = AlternativeRoutingRequestInterceptor(
            headersGetter: doh.getAccountHeaders,
            cookiesSynchronization: doh.synchronizeCookies(with:)
        ) { challenge, completionHandler in
            handleAuthenticationChallenge(
                didReceive: challenge,
                noTrustKit: PMAPIService.noTrustKit,
                trustKit: PMAPIService.trustKit,
                challengeCompletionHandler: completionHandler
            )
        }
        requestInterceptor.setup(webViewConfiguration: webViewConfiguration)
    }
    
    func interpretMessage(_ message: WKScriptMessage,
                          loadedPresentation: () -> Void,
                          notificationPresentation: (NotificationType, String) -> Void,
                          successPresentation: () -> Void,
                          closeWebView: @escaping (@escaping () -> Void) -> Void) {
        guard let string = message.body as? String,
              let message = try? jsonDecoder.decode(AccountDeletionMessage.self, from: Data(string.utf8))
        else { return }
        // we ignore further messages if we've already received the success message
        guard state == .notDeletedYet else { return }
        switch message.type {
        case .loaded:
            loadedPresentation()
        case .notification:
            guard let notificationMessage = message.payload?.text else { return }
            let notificationType = message.payload?.type ?? .warning
            notificationPresentation(notificationType, notificationMessage)
        case .success:
            successPresentation()
            state = .alreadyDeleted
            let closeAfterTime = DispatchTime.now() + .seconds(3)
            let completion = completion
            performBeforeClosingAccountDeletionScreen {
                DispatchQueue.main.asyncAfter(deadline: closeAfterTime) {
                    closeWebView {
                        completion(.success(AccountDeletionSuccess()))
                    }
                }
            }
        case .error:
            state = .finishedWithoutDeletion
            let errorMessage = message.payload?.message ?? CoreString._ad_delete_network_error
            let completion = completion
            closeWebView {
                completion(.failure(.deletionFailure(message: errorMessage)))
            }
        case .close:
            state = .finishedWithoutDeletion
            closeWebView { }
            completion(.failure(.closedByUser))
        }
    }
    
    func deleteAccountDidErrorOut(message: String) {
        completion(.failure(.deletionFailure(message: message)))
    }
    
    func deleteAccountWasClosed() {
        completion(.failure(.closedByUser))
    }
    
    func shouldRetryFailedLoading(host: String, error: Error, shouldReloadWebView: @escaping (Bool) -> Void) {
        doh.handleErrorResolvingProxyDomainIfNeeded(host: host, sessionId: apiService.sessionUID, error: error, completion: shouldReloadWebView)
    }
}
