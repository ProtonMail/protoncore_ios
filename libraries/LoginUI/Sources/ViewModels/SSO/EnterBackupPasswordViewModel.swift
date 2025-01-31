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
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUIFoundations

extension EnterBackupPasswordView {
    struct Dependencies {
        let userData: LoginData
        let apiService: APIService?
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
    }
}

extension EnterBackupPasswordView {

    @MainActor
    final class ViewModel: ObservableObject {
        private let apiService: APIService?
        private let userData: LoginData

        private let buildAndValidatePassphrases = BuildAndValidatePassphrases()
        private var activateAuthDevice: ActivateAuthDevice?
        var organizationRepository: OrganizationRepository?

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        enum ViewState {
            case idle
            case loading
        }

        @Published var bannerState: BannerState = .none
        @Published var viewState: ViewState = .idle
        @Published var backupPasswordStyle: PCTextFieldStyle = .init(mode: .idle)
        @Published var backupPasswordContent: PCTextFieldContent = .init(
            title: LUITranslation.backup_password.l10n,
            isSecureEntry: true
        )

        init(dependencies: Dependencies) {
            self.apiService = dependencies.apiService
            self.userData = dependencies.userData
            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate
            if let apiService = dependencies.apiService {
                self.activateAuthDevice = ActivateAuthDevice(
                    apiService: apiService,
                    deviceSecretRepository: DeviceSecretRepository()
                )
                self.organizationRepository = OrganizationRepository(apiService: apiService)
            }
        }

        func primaryActionButtonTapped() {
            Task {
                let backupPassword = backupPasswordContent.text
                do {
                    guard let passphrases = try buildAndValidatePassphrases.buildAndValidatePassphrases(
                        mailboxPassword: backupPassword,
                        salts: userData.salts,
                        userKeys: userData.user.keys
                    ) else {
                        bannerState = .error(content: .init(message: LUITranslation.invalid_password.l10n))
                        return
                    }
                    let newUserData = userData.updated(passphrases: passphrases)
                    guard let passphrase = newUserData.getMailboxPassword else {
                        bannerState = .error(content: .init(message: LUITranslation.passphrase_not_found.l10n))
                        return
                    }
                    viewState = .loading
                    try await activateAuthDevice?.invoke(userId: userData.user.ID, passphrase: passphrase)
                    await ssoNavigationDelegate?.globalSSOLoginDidFinish(data: newUserData)
                    viewState = .idle
                } catch {
                    viewState = .idle
                    PMLog.error(error)
                    bannerState = .error(content: .init(message: error.localizedDescription))
                }
            }
        }

        func secondaryActionButtonTapped() {
            Task {
                do {
                    guard let organizationRepository else { return }
                    viewState = .loading
                    let organizationSignature = try await organizationRepository.getOrganizationSignature()
                    ssoNavigationDelegate?.showRequestAdminHelpConfirmation(
                        data: userData,
                        adminEmail: organizationSignature.fingerprintSignatureAddress
                    )
                    viewState = .idle
                } catch {
                    viewState = .idle
                    PMLog.error(error)
                    bannerState = .error(content: .init(message: error.localizedDescription))
                }
            }
        }

        private func resetTextFieldErrors() {
            backupPasswordStyle.mode = .idle
        }
    }
}

#endif
