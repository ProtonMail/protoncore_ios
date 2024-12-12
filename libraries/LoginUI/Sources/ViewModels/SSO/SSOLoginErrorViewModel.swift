//
//  SSOLoginErrorViewModel.swift
//  ProtonCore-LoginUI - Created on 26/11/2024.
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

import ProtonCoreDataModel
import ProtonCoreUIFoundations
import SwiftUI

extension SSOLoginErrorView {
    struct Dependencies {
        let user: User
        let error: Error
        let continueAction: () -> Void
    }
}

extension SSOLoginErrorView {

    @MainActor
    final class ViewModel: ObservableObject {
        let user: User

        @Published var bannerState = BannerState.none
        let continueAction: () -> Void

        init(dependencies: Dependencies) {
            self.user = dependencies.user
            self.bannerState = .error(content: .init(message: dependencies.error.localizedDescription))
            self.continueAction = dependencies.continueAction
        }

        var memberEmail: String {
            user.email ?? user.displayName ?? user.name ?? "Unknown"
        }

        var avatarInitials: String {
            user.name?.initials() ?? user.displayName?.initials() ?? user.email?.initials() ?? "P"
        }

        func continueButtonTapped() {
            continueAction()
        }
    }
}

#endif
