//
//  GrantAccessViewModel.swift
//  ProtonCore-LoginUI - Created on 07/01/2025.
//
//  Copyright (c) 2025 Proton AG
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
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUIFoundations

extension GrantAccessView {
    struct Dependencies {
        let apiService: APIService?
        let authDevices: [AuthDevice]
        let userData: LoginData
        let navigationDelegate: GrantAccessViewNavigationDelegate?
    }
}

extension GrantAccessView {

    @MainActor
    final class ViewModel: ObservableObject {
        private let authDevices: [AuthDevice]
        private let userData: LoginData

        private var rejectAuthDevice: RejectAuthDevice?
        private var validateConfirmationCode: ValidateConfirmationCode
        private var activateAuthDevice: ActivateAuthDevice?

        weak var navigationDelegate: GrantAccessViewNavigationDelegate?

        @Published var bannerState: BannerState = .none
        @Published var confirmationCodeStyle: PCTextFieldStyle = .init(mode: .idle)
        @Published var confirmationCodeContent: PCTextFieldContent = .init(
            title: LUITranslation.confirmation_code.l10n,
            autocapitalization: .allCharacters
        )

        var memberEmail: String { userData.user.email ?? LUITranslation.unknown.l10n }

        var bodyDescription: String {
            return String.localizedStringWithFormat(
                LUITranslation.sign_in_request_description.l10n,
                memberEmail
            )
        }

        init(dependencies: Dependencies) {
            self.authDevices = dependencies.authDevices
            self.userData = dependencies.userData
            self.navigationDelegate = dependencies.navigationDelegate

            let deviceSecretRepository = DeviceSecretRepository()
            if let apiService = dependencies.apiService {
                rejectAuthDevice = RejectAuthDevice(apiService: apiService)
                activateAuthDevice = ActivateAuthDevice(
                    apiService: apiService,
                    deviceSecretRepository: deviceSecretRepository
                )
            }
            validateConfirmationCode = ValidateConfirmationCode()
        }

        func primaryActionButtonTapped() {
            Task {
                do {
                    guard let activateAuthDevice else { return }
                    guard let authDevice = authDevices.first else { throw SSOLoginError.authDeviceNotFound }
                    resetConfirmationCodeInput()

                    let deviceSecret = try validateConfirmationCode.invoke(
                        userData: userData,
                        authDevice: authDevice,
                        code: confirmationCodeContent.text
                    )

                    guard let mailboxPassphrase = userData.getMailboxPassword else {
                        PMLog.error("Passphrase not found")
                        bannerState = .error(content: .init(message: LUITranslation.error_occured.l10n))
                        return
                    }
                    try await activateAuthDevice.invoke(
                        userId: userData.user.ID,
                        deviceId: authDevice.ID,
                        deviceSecret: deviceSecret,
                        passphrase: mailboxPassphrase
                    )
                    navigationDelegate?.dismissGrantAccessView()
                } catch let error as ValidateConfirmationCode.ValidationError {
                    displayConfirmationCodeError(error: error)
                } catch {
                    PMLog.error(error)
                    bannerState = .error(content: .init(message: error.localizedDescription))
                }
            }
        }

        func secondaryActionButtonTapped() {
            Task {
                do {
                    guard let rejectAuthDevice else { return }
                    guard let authDevice = authDevices.first else { throw SSOLoginError.authDeviceNotFound }
                    try await rejectAuthDevice.invoke(deviceId: authDevice.ID)
                    navigationDelegate?.dismissGrantAccessView()
                } catch {
                    PMLog.error(error)
                    bannerState = .error(content: .init(message: error.localizedDescription))
                }
            }
        }

        private func displayConfirmationCodeError(error: ValidateConfirmationCode.ValidationError) {
            confirmationCodeStyle.mode = .error
            confirmationCodeContent.footnote = error.localizedDescription
        }

        private func resetConfirmationCodeInput() {
            confirmationCodeStyle.mode = .idle
            confirmationCodeContent.footnote = ""
        }
    }
}

#endif
