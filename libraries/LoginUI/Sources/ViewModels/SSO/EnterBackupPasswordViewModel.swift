//
//  EnterBackupPasswordViewModel.swift
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
import ProtonCoreLog
import ProtonCoreUIFoundations

extension EnterBackupPasswordView {
    struct Dependencies {}
}

extension EnterBackupPasswordView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var bannerState: BannerState = .none

        @Published var backupPasswordStyle: PCTextFieldStyle = .init(mode: .idle)
        @Published var backupPasswordContent: PCTextFieldContent = .init(
            title: LUITranslation.backup_password.l10n,
            isSecureEntry: true
        )

        @Published var confirmationCodeContent: PCTextFieldContent = .init(title: LUITranslation.confirmation_code.l10n)

        init(dependencies: Dependencies) {}

        var screenTitle: String {
            return LUITranslation.enter_backup_password_title.l10n
        }

        var bodyDescription: String {
            return LUITranslation.enter_backup_password_description.l10n
        }

        var primaryButtonActionTitle: String {
            return LUITranslation.continue_core_button.l10n
        }

        var secondaryButtonActionTitle: String {
            return LUITranslation.ask_administrator_for_help.l10n
        }

        func primaryActionButtonTapped() {}

        func secondaryActionButtonTapped() {}

        private func resetTextFieldErrors() {
            backupPasswordStyle.mode = .idle
        }
    }
}

#endif
