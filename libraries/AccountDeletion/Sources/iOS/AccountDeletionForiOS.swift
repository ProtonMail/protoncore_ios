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

import UIKit
#if canImport(ProtonCore_CoreTranslation)
import ProtonCore_CoreTranslation
#else
import PMCoreTranslation
#endif
#if canImport(ProtonCore_UIFoundations)
import ProtonCore_UIFoundations
#else
import PMUIFoundations
#endif

public typealias AccountDeletionViewController = UIViewController

extension AccountDeletionWebView {
    
    @objc func onBackButtonPressed() {
        let viewModel = self.viewModel
        self.navigationController?.presentingViewController?.dismiss(animated: true) {
            viewModel.deleteAccountWasClosed()
        }
    }
    
    func styleUI() {
        #if canImport(ProtonCore_UIFoundations)
        let backgroundColor: UIColor = ColorProvider.BackgroundNorm
        #else
        let backgroundColor: UIColor = UIColorManager.BackgroundNorm
        #endif
        view.backgroundColor = backgroundColor
        webView?.backgroundColor = backgroundColor
        webView?.scrollView.backgroundColor = backgroundColor
        webView?.scrollView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            webView?.underPageBackgroundColor = backgroundColor
        }
    }
    
    func onAccountDeletionAppFailure(message: String) {
        presentError(message: message, close: nil)
    }
    
    func presentSuccessfulLoading() {
        webView?.alpha = 0.0
        webView?.isHidden = false
        loader.stopAnimating()
        loader.isHidden = true
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.webView?.alpha = 1.0
        }
    }
    
    func presentSuccessfulAccountDeletion() {
        navigationItem.leftBarButtonItem = nil
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.webView?.alpha = 0.0
        } completion: { [weak self] _ in
            self?.webView?.isHidden = true
        }
        self.banner?.dismiss()
        self.banner = PMBanner(message: CoreString._ad_delete_account_success,
                               style: PMBannerNewStyle.success,
                               dismissDuration: Double.infinity)
        self.banner?.show(at: .top, on: self)
    }
    
    func presentError(message: String, close: (() -> Void)?) {
        self.banner?.dismiss()
        self.banner = PMBanner(message: message, style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
        if let close = close {
            self.banner?.addButton(text: CoreString._ad_delete_close_button) { [weak self] _ in
                self?.banner?.dismiss()
                close()
            }
        } else {
            self.banner?.addButton(text: CoreString._general_ok_action) { [weak self] _ in
                self?.banner?.dismiss()
            }
        }
        self.banner?.show(at: .top, on: self)
    }
    
    func openUrl(_ url: URL) {
        #if canImport(ProtonCore_Foundations)
        UIApplication.openURLIfPossible(url)
        #else
        UIApplication.shared.openURL(url)
        #endif
    }
}

extension AccountDeletionService: AccountDeletionWebViewDelegate {
    
    func shouldCloseWebView(_ viewController: AccountDeletionWebView, completion: @escaping () -> Void) {
        viewController.presentingViewController?.dismiss(animated: true, completion: completion)
    }
    
    func present(vc: AccountDeletionWebView, over: AccountDeletionViewController, completion: @escaping () -> Void) {
        let navigationVC = UINavigationController(rootViewController: vc)
        vc.title = CoreString._ad_delete_account_title
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.backImage,
            style: .done,
            target: vc,
            action: #selector(AccountDeletionWebView.onBackButtonPressed)
        )
        #if canImport(ProtonCore_UIFoundations)
        let tintColor: UIColor = ColorProvider.IconNorm
        #else
        let tintColor: UIColor = UIColorManager.IconNorm
        #endif
        vc.navigationItem.leftBarButtonItem?.tintColor = tintColor
        navigationVC.setNavigationBarHidden(false, animated: false)
        navigationVC.modalPresentationStyle = .fullScreen
        over.present(navigationVC, animated: true, completion: completion)
    }
}
