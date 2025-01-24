//
//  Choose2FAViewController.swift
//  ProtonCore-Login - Created on 8/5/2024.
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

#if os(iOS)
import SwiftUI
import ProtonCoreUIFoundations

@available(iOS 15.0, *)
public final class Choose2FAViewController: UIHostingController<Choose2FAView> {
     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(rootView: Choose2FAView) {
        super.init(rootView: rootView)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorProvider.BackgroundNorm
        navigationController?.navigationBar.tintColor = ColorProvider.TextNorm
    }
}

#endif
