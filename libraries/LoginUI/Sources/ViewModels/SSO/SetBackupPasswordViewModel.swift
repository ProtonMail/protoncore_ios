//
//  SetBackupPasswordViewModel.swift
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
import ProtonCoreLog
import ProtonCoreUIFoundations
import ProtonCoreUtilities

extension SetBackupPasswordView {
    struct Dependencies {}
}

extension SetBackupPasswordView {

    @MainActor
    final class ViewModel: ObservableObject, PasswordValidator {

        @Published var bannerState: BannerState = .none

        @Published var backupPasswordStyle: PCTextFieldStyle = .init(mode: .idle)
        @Published var backupPasswordContent: PCTextFieldContent = .init(
            title: LUITranslation.backup_password.l10n,
            isSecureEntry: true
        )
        @Published var repeatBackupPasswordStyle: PCTextFieldStyle = .init(mode: .idle)
        @Published var repeatBackupPasswordContent: PCTextFieldContent = .init(
            title: LUITranslation.repeat_backup_password.l10n,
            isSecureEntry: true
        )

        init(dependencies: Dependencies) {}

        func continueTapped() {
            do {
                resetTextFieldsErrors()
                try validate(
                    for: .default,
                    password: backupPasswordContent.text,
                    confirmPassword: repeatBackupPasswordContent.text
                )
            } catch {
                PMLog.error(error)
                bannerState = .error(content: .init(message: error.localizedDescription))

                if let error = error as? PasswordValidationError {
                    displayPasswordError(error: error)
                }
            }
        }

        private func resetTextFieldsErrors() {
            backupPasswordStyle.mode = .idle
            repeatBackupPasswordStyle.mode = .idle
        }

        private func displayPasswordError(error: PasswordValidationError) {
            switch error {
            case .passwordEmpty:
                backupPasswordStyle.mode = .error
            case .passwordShouldHaveAtLeastEightCharacters:
                backupPasswordStyle.mode = .error
            case .passwordNotEqual:
                backupPasswordStyle.mode = .error
                repeatBackupPasswordStyle.mode = .error
            }
        }
    }
}

extension PasswordValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .passwordEmpty: 
            return LUITranslation.passwordEmptyErrorDescription.l10n
        case .passwordShouldHaveAtLeastEightCharacters:
            return LUITranslation.passwordLeast8CharactersErrorDescription.l10n
        case .passwordNotEqual:
            return LUITranslation.passwordNotMatchErrorDescription.l10n
        }
    }
}

#endif
