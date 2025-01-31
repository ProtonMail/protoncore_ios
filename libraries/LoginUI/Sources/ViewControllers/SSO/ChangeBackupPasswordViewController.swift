//
//  ChangeBackupPasswordViewController.swift
//  ProtonCore-LoginUI - Created on 10/01/2025.
//
//  Copyright (c) 2025 Proton AG
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
import SwiftUI
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUIFoundations

public final class ChangeBackupPasswordViewController: UIHostingController<SetBackupPasswordView> {

     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(dependencies: SetBackupPasswordView.Dependencies) {
        let viewModel = SetBackupPasswordView.ViewModel(dependencies: dependencies)
        let view = SetBackupPasswordView(viewModel: viewModel)
        super.init(rootView: view)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorProvider.BackgroundNorm
        navigationController?.navigationBar.tintColor = ColorProvider.TextNorm
    }
}

#endif
