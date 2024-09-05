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
import ProtonCoreUIFoundations

extension AccessGrantedDeniedView {
    struct Dependencies {
        let mode: AccessGrantedDeniedView.ViewMode
    }
}

extension AccessGrantedDeniedView {

    enum ViewMode {
        case accessGranted
        case accessDenied
    }

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var bannerState: BannerState = .none
        @Published var mode: ViewMode

        @Published var confirmationCodeContent: PCTextFieldContent = .init(title: LUITranslation.confirmation_code.l10n)

        init(dependencies: Dependencies) {
            self.mode = dependencies.mode
        }

        var screenTitle: String {
            switch mode {
            case .accessGranted: return LUITranslation.access_granted_title.l10n
            case .accessDenied: return LUITranslation.access_denied_title.l10n
            }
        }

        var bodyDescription: String {
            switch mode {
            case .accessGranted: return LUITranslation.access_granted_description.l10n
            case .accessDenied: return LUITranslation.access_denied_description.l10n
            }
        }

        var primaryButtonActionTitle: String {
            switch mode {
            case .accessGranted: return LUITranslation.continue_core_button.l10n
            case .accessDenied: return LUITranslation.back_to_signin_button.l10n
            }
        }

        func primaryActionButtonTapped() {}
    }
}

#endif
