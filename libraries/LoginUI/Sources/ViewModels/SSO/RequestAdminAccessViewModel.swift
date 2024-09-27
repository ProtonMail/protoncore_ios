//
//  RequestAdminAccessViewModel.swift
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

extension RequestAdminAccessView {
    struct Dependencies {}
}

extension RequestAdminAccessView {

    @MainActor
    final class ViewModel: ObservableObject {
        init(dependencies: Dependencies) {}

        var adminEmailAddress: String {
            "admin@privacybydefault.com"
        }

        var screenTitle: String {
            LUITranslation.request_admin_access_title.l10n
        }

        var bodyDescription: String {
            LUITranslation.request_admin_access_description.l10n
        }

        var continueButtonActionTitle: String {
            LUITranslation.continue_core_button.l10n
        }

        func continueActionButtonTapped() {}
    }
}

#endif
