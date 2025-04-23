//
//  AccessGrantedDeniedViewModel.swift
//  ProtonCore-LoginUI - Created on 23/08/2024.
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

import SwiftUI

extension LoginVPNGuestView {
    struct Dependencies {
    }
}

extension LoginVPNGuestView {

    @MainActor
    final class ViewModel: ObservableObject {

        init(dependencies: Dependencies) {}

        func continueAsGuestTapped() {}
        func signInTapped() {}

    }
}
#if DEBUG
extension LoginVPNGuestView.ViewModel {
    static func mock() -> LoginVPNGuestView.ViewModel {
        let dependencies = LoginVPNGuestView.Dependencies()
        let viewModel = LoginVPNGuestView.ViewModel(dependencies: dependencies)
        return viewModel
    }
}
#endif

#endif
