//
//  EmailVerifyViewController.swift
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

#if canImport(UIKit)
import UIKit
import WebKit
import ProtonCore_CoreTranslation
import ProtonCore_UIFoundations
import ProtonCore_Foundations
import ProtonCore_Networking

protocol HumanVerifyV3ViewControllerDelegate: AnyObject {
    func didDismissViewController()
    func didShowHelpViewController()
}

class HumanVerifyV3ViewController: UIViewController, AccessibleView {
    
    // MARK: Outlets

    var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeBarButtonItem: UIBarButtonItem!

    // MARK: Properties
    
    let userContentController = WKUserContentController()
    weak var delegate: HumanVerifyV3ViewControllerDelegate?
    var viewModel: HumanVerifyV3ViewModel!

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadWebContent()
        generateAccessibilityIdentifiers()
    }
    
    deinit {
        userContentController.removeAllUserScripts()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadWebContent()
    }

    // MARK: Actions
    
    @IBAction func closeAction(_ sender: Any) {
        delegate?.didDismissViewController()
    }
    
    @IBAction func helpAction(_ sender: Any) {
        delegate?.didShowHelpViewController()
    }
    
    // MARK: Private interface

    private func configureUI() {
        title = CoreString._hv_title
        closeBarButtonItem.tintColor = ColorProvider.IconNorm
        closeBarButtonItem.accessibilityLabel = "closeButton"
        view.backgroundColor = ColorProvider.BackgroundNorm
        activityIndicator?.startAnimating()
        setupWebView()
    }
    
    private func setupWebView() {
        userContentController.add(self, name: viewModel.scriptName)
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        webViewConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        view.bringSubviewToFront(activityIndicator)
        
        let layoutGuide = view.safeAreaLayoutGuide
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
    }

    private func loadWebContent() {
        URLCache.shared.removeAllCachedResponses()
        let requestObj = URLRequest(url: viewModel.getURL)
        webView.load(requestObj)
    }
}

// MARK: - WKWebViewDelegate

extension HumanVerifyV3ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        enableUserInteraction(for: webView)
        decisionHandler(.allow)
        return
    }

    func webView(_ webview: WKWebView, didFinish nav: WKNavigation!) {
        enableUserInteraction(for: webView)
        activityIndicator?.stopAnimating()
    }

    func webView(_ webview: WKWebView, didCommit nav: WKNavigation!) {
        enableUserInteraction(for: webView)
        activityIndicator?.startAnimating()
    }

    func webView(_ webview: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        enableUserInteraction(for: webView)
        activityIndicator?.stopAnimating()
    }

    private func enableUserInteraction(for webView: WKWebView) {
        webView.window?.isUserInteractionEnabled = true
    }
}

extension HumanVerifyV3ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        UIApplication.openURLIfPossible(url)
        return WKWebView(frame: webView.frame, configuration: configuration)
    }
}

extension HumanVerifyV3ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        viewModel.interpretMessage(message: message, validMessage: {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator?.startAnimating()
                self?.webView.isUserInteractionEnabled = false
            }
        }, notificationMessage: { message in
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    let banner = PMBanner(message: message, style: PMBannerNewStyle.success)
                    banner.show(at: .topCustom(.baner), on: self)
                }
            }
        }, complete: { [weak self] res, error, finish in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator?.stopAnimating()
                self?.webView.isUserInteractionEnabled = true
                if res {
                    self?.navigationController?.dismiss(animated: true) {
                        finish?()
                    }
                } else {
                    if let error = error, let self = self {
                        let banner = PMBanner(message: error.localizedDescription, style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
                        banner.addButton(text: CoreString._hv_ok_button) { [weak self] _ in
                            banner.dismiss()
                            self?.webView.reload()
                        }
                        banner.show(at: .topCustom(.baner), on: self)
                    }
                }
            }
        })
    }
}

#endif
