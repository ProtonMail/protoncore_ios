//
//  AdminGrantAccessViewController.swift
//  ProtonCore-LoginUI - Created on 27/09/2024.
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

public final class AdminGrantAccessViewController: UIHostingController<AdminGrantAccessView> {

    let viewModel: AdminGrantAccessView.ViewModel

     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        self.viewModel = AdminGrantAccessView.ViewModel(dependencies: .init())
        let view = AdminGrantAccessView(viewModel: self.viewModel)
        super.init(rootView: view)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorProvider.BackgroundNorm
    }
}

#endif
