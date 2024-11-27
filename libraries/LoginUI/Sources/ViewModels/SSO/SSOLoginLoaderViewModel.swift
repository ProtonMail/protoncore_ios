//
//  SSOLoginLoaderViewModel.swift
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

extension SSOLoginLoaderView {
    struct Dependencies {
        let user: User
    }
}

extension SSOLoginLoaderView {

    @MainActor
    final class ViewModel: ObservableObject {
        let user: User

        init(dependencies: Dependencies) {
            self.user = dependencies.user
        }

        var memberEmail: String {
            user.email ?? user.displayName ?? user.name ?? "Unknown"
        }

        var avatarInitials: String {
            user.name?.initials() ?? user.displayName?.initials() ?? user.email?.initials() ?? "P"
        }

        func cancelButtonTapped() {}
    }
}

#endif
