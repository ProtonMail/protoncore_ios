//
//  HumanVerifyV3ViewControllerForMacOS.swift
//  ProtonCore-HumanVerification - Created on 2/1/16.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import AppKit
import WebKit
import ProtonCore_CoreTranslation
import ProtonCore_UIFoundations
import ProtonCore_Foundations
import ProtonCore_Networking

protocol HumanVerifyV3ViewControllerDelegate: AnyObject {
    func didDismissViewController()
    func didShowHelpViewController()
    func willReopenViewController()
}

final class HumanVerifyV3ViewController: NSViewController {
    
    // MARK: Outlets

    var webView: WKWebView!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    @IBOutlet weak var helpButton: NSButton!

    // MARK: Properties
    
    private var appearanceObserver: NSKeyValueObservation?
    let userContentController = WKUserContentController()
    weak var delegate: HumanVerifyV3ViewControllerDelegate?
    var viewModel: HumanVerifyV3ViewModel!
    
    // MARK: View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        configureUI()
        loadWebContent()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask = [.closable, .titled, .resizable]
        view.window?.minSize = NSSize(width: 400, height: 400)
        view.window?.maxSize = NSSize(width: 800, height: 800)
    }
    
    deinit {
        userContentController.removeAllUserScripts()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Actions
    
    @IBAction func helpAction(_ sender: Any) {
        delegate?.didShowHelpViewController()
    }
    
    // MARK: Private interface

    private func configureUI() {
        title = CoreString._hv_title
        startActivityIndicator()
        setupWebView()
    }
    
    private func setupWebView() {
        userContentController.add(self, name: viewModel.scriptName)
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        if #available(macOS 10.15, *) {
            webViewConfiguration.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        webViewConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.subviews.insert(webView, at: 0)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(macOS 11, *) {
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
    }

    private func loadWebContent() {
        URLCache.shared.removeAllCachedResponses()
        let requestObj = URLRequest(url: viewModel.getURL)
        webView.customUserAgent = "ipad"
        webView.load(requestObj)
    }
    
    private func startActivityIndicator() {
        activityIndicator?.startAnimation(self)
        activityIndicator?.isHidden = false
    }
    
    private func stopActivityIndicator() {
        activityIndicator?.stopAnimation(self)
        activityIndicator?.isHidden = true
    }
    
    private func setupObservers() {
        if #available(macOS 10.14, *) {
            appearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
                self?.loadWebContent()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK: - WKWebViewDelegate

extension HumanVerifyV3ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        return
    }

    func webView(_ webview: WKWebView, didFinish nav: WKNavigation!) {
        stopActivityIndicator()
    }

    func webView(_ webview: WKWebView, didCommit nav: WKNavigation!) {
        startActivityIndicator()
    }

    func webView(_ webview: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        stopActivityIndicator()
    }
}

extension HumanVerifyV3ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        NSWorkspace.shared.open(url)
        configuration.userContentController = userContentController
        return WKWebView(frame: .zero, configuration: configuration)
    }
}

extension HumanVerifyV3ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        viewModel.interpretMessage(message: message, notificationMessage: { notificationMessage in
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = notificationMessage
                alert.runModal()
            }
        }, errorHandler: { _ in 
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.willReopenViewController()
            }
        }, completeHandler: { method in
            let delay: TimeInterval = method == .captcha ? 1.0 : 0.0
            // for captcha method there is an additional artificial delay to see verification animation
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.dismiss(self)
            }
        })
    }
}

extension HumanVerifyV3ViewController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        delegate?.didDismissViewController()
    }
}
