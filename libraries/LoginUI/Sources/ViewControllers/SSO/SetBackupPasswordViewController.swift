//
//  JoinOrganizationViewController.swift
//  ProtonCore-Login - Created on 23/08/2024.
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

import Foundation
import ProtonCoreUIFoundations
import SwiftUI

public final class SetBackupPasswordViewController: UIHostingController<SetBackupPasswordView> {

    let viewModel: SetBackupPasswordView.ViewModel

     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        let dependencies = SetBackupPasswordView.Dependencies()
        self.viewModel = SetBackupPasswordView.ViewModel(dependencies: dependencies)
        let view = SetBackupPasswordView(viewModel: self.viewModel)
        super.init(rootView: view)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorProvider.BackgroundNorm
    }
}

#endif
