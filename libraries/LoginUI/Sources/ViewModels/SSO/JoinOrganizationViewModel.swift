//
//  JoinOrganizationView.swift
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

import SwiftUI
import ProtonCoreUIFoundations

extension JoinOrganizationView {
    struct Dependencies {
        let externalLinks: ExternalLinks
    }
}

extension JoinOrganizationView {

    @MainActor
    final class ViewModel: ObservableObject {

        private let externalLinks: ExternalLinks

        @Published var bannerState: BannerState = .none
        
        private let organizationName: String = "Proton AG"
        let accountEmail: String = "test@test.com"
        let organizationImageName: String = "LaunchScreenVPNLogo"

        init(dependencies: Dependencies) {
            self.externalLinks = dependencies.externalLinks
        }

        var joinOrganizationTitle: String {
            String.localizedStringWithFormat(
                LUITranslation.join_organization_title.l10n,
                organizationName
            )
        }

        var termsAndConditionsLink: URL {
            externalLinks.termsAndConditions
        }

        func continueTapped() {}

        func cancelTapped() {}
    }
}

#endif
