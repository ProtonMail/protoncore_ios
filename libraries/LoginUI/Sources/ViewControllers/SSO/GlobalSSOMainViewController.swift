//
//  GlobalSSOMainViewController.swift
//  ProtonCore-LoginUI - Created on 28/11/2024.
//
//  Copyright (c) 2024 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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

import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUIFoundations
import SwiftUI

protocol GlobalSSONavigationDelegate: AnyObject {
    func showRequestAdminHelpConfirmation(data: LoginData, unprivatizationInfo: UnprivatizationInfo)
    func showRequestAdminHelp(data: LoginData)
    func showEnterBackupPassword(data: LoginData, unprivatizationInfo: UnprivatizationInfo)
    func showChangeBackupPassword(data: LoginData)
    func globalSSOLoginDidFinish(data: LoginData) async
    func globalSSOLoginDidCancel()
}

final class GlobalSSOMainViewController: UIHostingController<GlobalSSOMainView> {
    let viewModel: GlobalSSOMainView.ViewModel

    weak var navigationDelegate: NavigationDelegate?

     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        dependencies: GlobalSSOMainView.Dependencies,
        navigationDelegate: NavigationDelegate?
    ) {
        self.viewModel = GlobalSSOMainView.ViewModel(dependencies: dependencies)
        let view = GlobalSSOMainView(viewModel: self.viewModel)
        self.navigationDelegate = navigationDelegate
        super.init(rootView: view)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorProvider.BackgroundNorm
        navigationController?.navigationBar.tintColor = ColorProvider.TextNorm
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.leftBarButtonItem = .button(on: self, action: #selector(dismissViewController), image: IconProvider.crossBig)
    }

    @objc
    func dismissViewController() {
        navigationDelegate?.userDidClose()
    }
}

#endif
