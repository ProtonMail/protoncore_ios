//
//  AccountDeletionWebView.swift
//  ProtonCore-AccountDeletion - Created on 10.12.21.
//
//  Copyright (c) 2021 Proton Technologies AG
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

import WebKit
#if canImport(ProtonCore_UIFoundations)
import ProtonCore_UIFoundations
#else
import PMUIFoundations
#endif
#if canImport(ProtonCore_Log)
import ProtonCore_Log
#else
import PMLog
#endif
#if canImport(ProtonCore_Foundations)
import ProtonCore_Foundations
#endif
#if canImport(ProtonCore_Networking)
import ProtonCore_Networking
#else
import PMCommon
#endif
#if canImport(ProtonCore_Services)
import ProtonCore_Services
#endif

final class WeaklyProxingScriptHandler<OtherHandler: WKScriptMessageHandler>: NSObject, WKScriptMessageHandler {
    private weak var otherHandler: OtherHandler?
    
    init(_ otherHandler: OtherHandler) { self.otherHandler = otherHandler }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let otherHandler = otherHandler else { return }
        otherHandler.userContentController(userContentController, didReceive: message)
    }
}

// swiftlint:disable:next class_delegate_protocol
protocol AccountDeletionWebViewDelegate {
    func shouldCloseWebView(_ viewController: AccountDeletionWebView, completion: @escaping () -> Void)
}

final class AccountDeletionWebView: AccountDeletionViewController {
    
    #if canImport(UIKit)
    var banner: PMBanner?
    #endif
    
    // swiftlint:disable weak_delegate
    /// The delegate is being kept strongly so that the client doesn't have to care
    /// about keeping some object to receive the completion block.
    var stronglyKeptDelegate: AccountDeletionWebViewDelegate?
    let userContentController = WKUserContentController()
    let viewModel: AccountDeletionViewModel
    var webView: WKWebView?
    
    init(viewModel: AccountDeletionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = configureUI()
        loadWebContent(webView: webView)
        self.webView = webView
        #if canImport(UIKit) && canImport(ProtonCore_Foundations)
        generateAccessibilityIdentifiers()
        #endif
    }
    
    private func configureUI() -> WKWebView {
        styleUI()
        
        userContentController.add(WeaklyProxingScriptHandler(self), name: "iOS")
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        if #available(iOS 13.0, macOS 10.15, *) {
            webViewConfiguration.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        webViewConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isHidden = false
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11, macOS 11, *) {
            let layoutGuide = view.safeAreaLayoutGuide
            webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        } else {
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        return webView
    }
    
    private var lastLoadingURL: String?
    
    private func loadWebContent(webView: WKWebView) {
        URLCache.shared.removeAllCachedResponses()
        let requestObj = viewModel.getURLRequest
        lastLoadingURL = requestObj.url?.absoluteString
        PMLog.debug("account deletion loading webview with url \(lastLoadingURL ?? "-")")
        #if canImport(AppKit)
        webView.customUserAgent = "ipad"
        #endif
        webView.load(requestObj)
    }
}

extension AccountDeletionWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        handleAuthenticationChallenge(
            didReceive: challenge,
            noTrustKit: PMAPIService.noTrustKit,
            trustKit: PMAPIService.trustKit,
            challengeCompletionHandler: completionHandler
        )
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleLoadingError(webView, error: error)
    }
    
    func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        handleLoadingError(webView, error: error)
    }
    
    private func handleLoadingError(_ webView: WKWebView, error: Error) {
        PMLog.debug("webview load fail with error \(error)")
        guard let loadingURL = lastLoadingURL else { return }
        viewModel.shouldRetryFailedLoading(host: loadingURL, error: error) { [weak self] in
            if $0 {
                self?.loadWebContent(webView: webView)
            } else {
                self?.onAccountDeletionAppFailure(message: error.localizedDescription)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        PMLog.debug("webview did finish navigation")
        onAccountDeletionAppLoadedSuccessfully()
    }
}

extension AccountDeletionWebView: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        
        openUrl(url)
        
        configuration.userContentController = userContentController
        return WKWebView(frame: webView.frame, configuration: configuration)
    }
}

extension AccountDeletionWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "iOS" else { return }
        viewModel.interpretMessage(message) {
            DispatchQueue.main.async { [weak self] in
                self?.presentSuccessfulAccountDeletion()
            }
        } errorPresentation: { [weak self] errorMessage, shouldAllowClosing in
            DispatchQueue.main.async { [weak self] in
                guard shouldAllowClosing else {
                    self?.presentError(message: errorMessage, close: nil)
                    return
                }
                self?.presentError(message: errorMessage) { [weak self] in
                    guard let self = self else { return }
                    self.stronglyKeptDelegate?.shouldCloseWebView(self, completion: {})
                }
            }
        } closeWebView: { completion in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stronglyKeptDelegate?.shouldCloseWebView(self, completion: completion)
            }
        }
    }
}

#if canImport(UIKit) && canImport(ProtonCore_Foundations)
extension AccountDeletionWebView: AccessibleView {}
#endif
