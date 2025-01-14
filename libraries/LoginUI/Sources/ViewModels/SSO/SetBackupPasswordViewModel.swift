//
//  SetBackupPasswordViewModel.swift
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

import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreCrypto
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUIFoundations
import ProtonCoreUtilities
import SwiftUI

extension SetBackupPasswordView {
    enum Mode {
        case setNewBackupPassword(organizationInfo: OrganizationInfo)
        case changeTemporaryPassword
    }

    struct Dependencies {
        let mode: SetBackupPasswordView.Mode
        let apiService: APIService?
        let userData: LoginData
        let loginService: Login?
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
    }

    struct OrganizationInfo {
        let organizationName: String
        let organizationAdminEmail: String
        let organizationLogoID: String?
        let organizationPublicKey: ArmoredKey
    }
}

extension SetBackupPasswordView {

    @MainActor
    final class ViewModel: ObservableObject, PasswordValidator {
        @Published var viewState: ViewState = .idle
        @Published var bannerState: BannerState = .none

        let mode: SetBackupPasswordView.Mode

        enum ViewState {
            case idle
            case loading
        }

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

        private var authenticator: AuthenticatorKeyGenerationInterface?
        private let userData: LoginData
        private let deviceSecretRepository: DeviceSecretRepositoryProtocol

        // Mode setBackupPassword
        var organizationInfo: OrganizationInfo?
        private var loginService: Login?

        // Mode changeTemporaryPassword
        private var passwordChangeService: BasePasswordChangeService?


        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        init(dependencies: Dependencies) {
            self.userData = dependencies.userData
            self.mode = dependencies.mode
            self.loginService = dependencies.loginService
            switch mode {
            case .setNewBackupPassword(let organizationInfo):
                self.organizationInfo = organizationInfo
                if let apiService = dependencies.apiService {
                    self.authenticator = Authenticator(api: apiService)
                }
            case .changeTemporaryPassword:
                if let apiService = dependencies.apiService {
                    self.passwordChangeService = BasePasswordChangeService(api: apiService)
                }
            }

            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate
            self.deviceSecretRepository = DeviceSecretRepository()
        }

        var screenTitle: String {
            switch mode {
            case .setNewBackupPassword:
                String.localizedStringWithFormat(
                    LUITranslation.join_organization_title.l10n,
                    organizationInfo?.organizationName ?? LUITranslation.unknown.l10n
                )
            case .changeTemporaryPassword:
                LUITranslation.set_backup_password_title.l10n
            }
        }

        var joinOrganizationSubtitle: String {
            String.localizedStringWithFormat(
                LUITranslation.join_organization_description.l10n,
                organizationInfo?.organizationAdminEmail ?? LUITranslation.unknown.l10n
            )
        }

        var organizationAdminEmail: String {
            organizationInfo?.organizationAdminEmail ?? LUITranslation.unknown.l10n
        }

        var organizationLogoURL: URL? {
            guard let _ = organizationInfo?.organizationLogoID else { return nil }
            // TODO: Retrieve logo from /organizations/logo/{logoId}
            return nil
        }

        func continueTapped() {
            Task {
                do {
                    resetTextFieldsErrors()
                    try validate(
                        for: .default,
                        password: backupPasswordContent.text,
                        confirmPassword: repeatBackupPasswordContent.text
                    )
                    viewState = .loading
                    switch mode {
                    case .setNewBackupPassword:
                        try await setupNewAccountKeys()
                    case .changeTemporaryPassword:
                        try await changeTemporaryPassword()
                    }
                } catch {
                    viewState = .idle
                    PMLog.error(error)
                    bannerState = .error(content: .init(message: error.localizedDescription))

                    if let error = error as? PasswordValidationError {
                        displayPasswordError(error: error)
                    }
                }
            }
        }

        func setupNewAccountKeys() async throws {
            guard let authenticator, let loginService, let organizationInfo else {
                throw SSOLoginError.authenticatorNotFound
            }

            guard let deviceSecret = try deviceSecretRepository.getByUserId(userId: userData.user.ID) else {
                throw SSOLoginError.deviceSecretNotFound
            }

            try await authenticator.setupAccountKeys(
                addresses: userData.addresses,
                password: backupPasswordContent.text,
                orgPublicKey: organizationInfo.organizationPublicKey,
                deviceSecret: deviceSecret.secret
            )
            let updatedUserData = try await loginService.refreshUserData(backupPassword: backupPasswordContent.text)
            await ssoNavigationDelegate?.globalSSOLoginDidFinish(data: updatedUserData)
            viewState = .idle
        }

        func changeTemporaryPassword() async throws {
            guard let loginService, let passwordChangeService else {
                throw SSOLoginError.authenticatorNotFound
            }
            guard let deviceSecret = try deviceSecretRepository.getByUserId(userId: userData.user.ID) else {
                throw SSOLoginError.deviceSecretNotFound
            }
            if let mailboxPassword = userData.getMailboxPassword {
                userData.credential.update(password: mailboxPassword)
            }
            try await passwordChangeService.updateUserPassword(
                auth: userData.credential,
                userInfo: userData.toUserInfo,
                loginPassword: userData.getMailboxPassword!,
                newPassword: .init(value: backupPasswordContent.text),
                buildAuth: true,
                skipPasswordSRPProof: true,
                deviceSecret: deviceSecret.secret
            )
            let updatedUserData = try await loginService.refreshUserData(backupPassword: backupPasswordContent.text)
            await ssoNavigationDelegate?.globalSSOLoginDidFinish(data: updatedUserData)
            viewState = .idle
        }

        private func resetTextFieldsErrors() {
            backupPasswordStyle.mode = .idle
            repeatBackupPasswordStyle.mode = .idle
        }

        private func displayPasswordError(error: PasswordValidationError) {
            switch error {
            case .passwordEmpty, .passwordShouldHaveAtLeastEightCharacters:
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
