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
import ProtonCore_CoreTranslation
import ProtonCore_UIFoundations

public typealias AccountDeletionViewController = UIViewController

extension AccountDeletionWebView {
    
    @objc func onBackButtonPressed() {
        let viewModel = self.viewModel
        self.navigationController?.presentingViewController?.dismiss(animated: true) {
            viewModel.deleteAccountWasClosed()
        }
    }
    
    func styleUI() {
        view.backgroundColor = ColorProvider.BackgroundNorm
        webView?.backgroundColor = ColorProvider.BackgroundNorm
        webView?.scrollView.backgroundColor = ColorProvider.BackgroundNorm
        webView?.scrollView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            webView?.underPageBackgroundColor = ColorProvider.BackgroundNorm
        }
    }
    
    func onAccountDeletionAppLoadedSuccessfully() {
//        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func onAccountDeletionAppFailure(message: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.closeImage, style: .done, target: self, action: #selector(AccountDeletionWebView.onBackButtonPressed)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorProvider.IconNorm
//        navigationController?.setNavigationBarHidden(false, animated: true)
        presentError(message: message)
    }
    
    func presentError(message: String) {
        self.banner?.dismiss()
        self.banner = PMBanner(message: message, style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
        self.banner?.addButton(text: CoreString._general_ok_action) { [weak self] _ in
            self?.banner?.dismiss()
        }
        self.banner?.show(at: .top, on: self)
    }
    
    func openUrl(_ url: URL) {
        UIApplication.openURLIfPossible(url)
    }
}

extension AccountDeletionService: AccountDeletionWebViewDelegate {
    
    func shouldCloseWebView(_ viewController: AccountDeletionWebView) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func present(vc: AccountDeletionWebView, over: AccountDeletionViewController) {
        let navigationVC = UINavigationController(rootViewController: vc)
        vc.title = CoreString._ad_delete_account_title
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.backImage,
            style: .done,
            target: vc,
            action: #selector(AccountDeletionWebView.onBackButtonPressed)
        )
        vc.navigationItem.leftBarButtonItem?.tintColor = ColorProvider.IconNorm
        navigationVC.setNavigationBarHidden(false, animated: false)
        navigationVC.modalPresentationStyle = .fullScreen
        over.present(navigationVC, animated: true, completion: nil)
    }
}
