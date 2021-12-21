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
import ProtonCore_Foundations
import ProtonCore_UIFoundations

final class WeaklyProxingScriptHandler<OtherHandler: WKScriptMessageHandler>: NSObject, WKScriptMessageHandler {
    private weak var otherHandler: OtherHandler?
    
    init(_ otherHandler: OtherHandler) { self.otherHandler = otherHandler }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let otherHandler = otherHandler else { return }
        otherHandler.userContentController(userContentController, didReceive: message)
    }
}

protocol AccountDeletionWebViewDelegate {
    func shouldCloseWebView(_ viewController: AccountDeletionWebView)
}

final class AccountDeletionWebView: AccountDeletionViewController {
    
    #if canImport(UIKit)
    var banner: PMBanner?
    #endif
    
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
        #if canImport(UIKit)
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
        print("loading \(lastLoadingURL ?? "")")
        #if canImport(AppKit)
        webView.customUserAgent = "ipad"
        #endif
        webView.load(requestObj)
    }
}

extension AccountDeletionWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("webview did receive redirect")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("webview did receive challenge")
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webview load fail with error \(error)")
    }
    
    func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        print("webview load fail with error \(error)")
        guard let loadingURL = lastLoadingURL else { return }
        viewModel.shouldRetryFailedLoading(host: loadingURL, error: error) { [weak self] in
            if $0 {
                self?.loadWebContent(webView: webView)
            } else {
                // present error, CP-3101
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview did finish navigation")
        styleUI()
    }
}

extension AccountDeletionWebView: WKUIDelegate {
    
}

extension AccountDeletionWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "iOS" else { return }
        viewModel.interpretMessage(message) { [weak self] errorMessage in
            DispatchQueue.main.async { [weak self] in
                self?.presentError(message: errorMessage)
            }
        } closeWebView: {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stronglyKeptDelegate?.shouldCloseWebView(self)
            }
        }
    }
}

#if canImport(UIKit)
extension AccountDeletionWebView: AccessibleView {}
#endif
