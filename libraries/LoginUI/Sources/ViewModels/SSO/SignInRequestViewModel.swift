//
//  SignInRequestViewModel.swift
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

extension SignInRequestView {
    struct Dependencies {
        let mode: SignInRequestView.ViewMode
    }
}

extension SignInRequestView {

    enum ViewMode {
        case requestForAdminApproval(code: String)
        case requestApproveFromAnotherDevice(code: String)
        case approvingAccess
    }

    struct DeviceViewModel {
        let name: String
        let localizedClientName: String
        let lastActivityTime: Date

        private let timeFormatter: RelativeDateTimeFormatter = {
            let formatter = RelativeDateTimeFormatter()
            formatter.dateTimeStyle = .numeric
            return formatter
        }()

        var lastActivityString: String {
            timeFormatter.localizedString(for: lastActivityTime, relativeTo: Date())
        }
    }

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var bannerState: BannerState = .none
        @Published var mode: ViewMode
        @Published var devices: [DeviceViewModel]

        @Published var confirmationCodeContent: PCTextFieldContent = .init(title: LUITranslation.confirmation_code.l10n)

        init(dependencies: Dependencies) {
            self.mode = dependencies.mode
            self.devices = [
                .init(name: "macOS", localizedClientName: "Proton Mail, Chrome", lastActivityTime: Date()),
                .init(name: "Google Pixel 7a", localizedClientName: "Proton Mail, Android", lastActivityTime: Date())
            ]
        }

        var screenTitle: String {
            switch mode {
            case .requestForAdminApproval: return LUITranslation.share_confirmation_code_title.l10n
            case .requestApproveFromAnotherDevice: return LUITranslation.approve_sign_in_another_device_title.l10n
            case .approvingAccess: return LUITranslation.sign_in_request_title.l10n
            }
        }

        var bodyDescription: String {
            switch mode {
            case .requestForAdminApproval: 
                return String.localizedStringWithFormat(
                    LUITranslation.share_confirmation_code_description.l10n,
                    "admin@privacybydefault.com",
                    "member@privacybydefault.com"
                )
            case .requestApproveFromAnotherDevice: return LUITranslation.approve_sign_in_another_device_description.l10n
            case .approvingAccess: return LUITranslation.sign_in_request_description.l10n
            }
        }

        var primaryButtonTitle: String {
            switch mode {
            case .requestForAdminApproval: return LUITranslation.use_backup_password_instead.l10n
            case .requestApproveFromAnotherDevice: return LUITranslation.use_backup_password_instead.l10n
            case .approvingAccess: return LUITranslation.yes_it_was_me.l10n
            }
        }

        var secondaryButtonTitle: String {
            switch mode {
            case .requestForAdminApproval: return LUITranslation._core_cancel_button.l10n
            case .requestApproveFromAnotherDevice: return LUITranslation.ask_administrator_for_help.l10n
            case .approvingAccess: return LUITranslation.no_it_wasnt_me.l10n
            }
        }

        func primaryActionButtonTapped() {}

        func secondaryActionButtonTapped() {}
    }
}

#endif
