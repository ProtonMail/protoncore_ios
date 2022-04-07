//
//  AccountDeletionWebView.swift
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

import AppKit
import ProtonCore_CoreTranslation

public typealias AccountDeletionViewController = NSViewController

extension AccountDeletionWebView {
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 600.0, height: 800.0))
        view.window?.styleMask = [.closable, .titled, .resizable]
        view.window?.minSize = NSSize(width: 600, height: 800)
        view.window?.maxSize = NSSize(width: 1000, height: 1000)
    }
    
    func styleUI() {
        
    }
    
    func onAccountDeletionAppFailure(message: String) {
        presentError(message: message, close: nil)
    }
    
    func presentSuccessfulLoading() {
        webView?.animator().alphaValue = 0
        webView?.isHidden = false
        loader.isHidden = true
        loader.stopAnimation(nil)
        
        NSAnimationContext.runAnimationGroup { [weak self] context in
            context.duration = 1
            self?.webView?.animator().alphaValue = 1
        }
    }
    
    func presentSuccessfulAccountDeletion() {
        NSAnimationContext.runAnimationGroup { [weak self] context in
            context.duration = 1
            self?.webView?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.webView?.isHidden = true
        }

        // TODO: consult the macOS success presentation with designers
        let alert = NSAlert()
        alert.messageText = CoreString._ad_delete_account_success
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    func presentError(message: String, close: (() -> Void)?) {
        // TODO: consult the macOS error presentation with designers
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        if let close = close {
            alert.addButton(withTitle: CoreString._general_ok_action)
            alert.addButton(withTitle: CoreString._ad_delete_close_button)
            let response = alert.runModal()
            switch response {
            case .alertSecondButtonReturn: close()
            default: return
            }
        } else {
            alert.runModal()
        }
    }
    
    func openUrl(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}

extension AccountDeletionWebView: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        viewModel.deleteAccountWasClosed()
    }
}

extension AccountDeletionService: AccountDeletionWebViewDelegate {
    
    func shouldCloseWebView(_ viewController: AccountDeletionWebView, completion: @escaping () -> Void) {
        viewController.presentingViewController?.dismiss(viewController)
        completion()
    }

    func present(vc: AccountDeletionWebView, over: AccountDeletionViewController, completion: @escaping () -> Void) {
        vc.title = CoreString._ad_delete_account_title
        over.presentAsModalWindow(vc)
        completion()
    }
}
