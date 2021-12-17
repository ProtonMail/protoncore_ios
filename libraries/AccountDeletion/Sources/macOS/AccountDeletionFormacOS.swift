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

import AppKit
import ProtonCore_CoreTranslation

public typealias AccountDeletionViewController = NSViewController

extension AccountDeletionWebView {
    
    override func loadView() {
        view = NSView(frame: NSMakeRect(0.0, 0.0, 600.0, 800.0))
        view.window?.styleMask = [.closable, .titled, .resizable]
        view.window?.minSize = NSSize(width: 600, height: 800)
        view.window?.maxSize = NSSize(width: 1000, height: 1000)
    }
    
    func styleUI() {
        
    }
    
    func presentError(message: String) {
        // TODO: consult the macOS error presentation with designers
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

extension AccountDeletionWebView: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        viewModel.deleteAccountWasClosed()
    }
}

extension AccountDeletionService: AccountDeletionWebViewDelegate {
    
    func shouldCloseWebView(_ viewController: AccountDeletionWebView) {
        viewController.presentingViewController?.dismiss(viewController)
    }

    func present(vc: AccountDeletionWebView, over: AccountDeletionViewController) {
        vc.title = CoreString._ad_delete_account_title
        over.presentAsModalWindow(vc)
    }
}
