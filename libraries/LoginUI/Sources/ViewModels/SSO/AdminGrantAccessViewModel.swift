//
//  AdminGrantAccessViewModel.swift
//  ProtonCore-LoginUI - Created on 26/09/2024.
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

extension AdminGrantAccessView {
    struct Dependencies {}
}

extension AdminGrantAccessView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var bannerState: BannerState = .none

        @Published var confirmationCodeStyle: PCTextFieldStyle = .init(mode: .idle)
        @Published var confirmationCodeContent: PCTextFieldContent = .init(
            title: LUITranslation.confirmation_code.l10n,
            isSecureEntry: false
        )

        let adminEmail: String = "admin@privacybydefault.com"

        init(dependencies: Dependencies) {}

        var screenTitle: String {
            LUITranslation.admin_grant_access_title.l10n
        }

        var bodyDescription: String {
            String.localizedStringWithFormat(
                LUITranslation.admin_grant_access_description.l10n,
                adminEmail
            )
        }

        var grantAccessButtonTitle: String {
            LUITranslation.grant_access_button_title.l10n
        }

        var denyAccessButtonTitle: String {
            LUITranslation.deny_access_button_title.l10n
        }

        func grantAccessButtonTapped() {}

        func denyAccessButtonTapped() {}
    }
}

#endif
