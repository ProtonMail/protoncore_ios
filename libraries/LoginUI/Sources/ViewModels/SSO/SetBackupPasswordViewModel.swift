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
import ProtonCoreFeatureFlags
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreObservability
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
        let apiService: APIService
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
    final class ViewModel: ObservableObject {
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

        @Published var passwordPolicyViewModel: PasswordPolicyView.ViewModel!

        private var authenticator: AuthenticatorKeyGenerationInterface?
        private let userData: LoginData
        private let deviceSecretRepository: DeviceSecretRepositoryProtocol
        private var getOrganizationLogo: GetOrganizationLogo?

        // Mode setBackupPassword
        @Published var organizationLogoURL: URL?
        var organizationInfo: OrganizationInfo?
        private var loginService: Login?

        // Mode changeTemporaryPassword
        private var passwordChangeService: BasePasswordChangeService?

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        var isPasswordPolicyEnabled: Bool {
            !FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.passwordPolicyDisabled,
                                                     reloadValue: true)
        }

        init(dependencies: Dependencies) {
            self.userData = dependencies.userData
            self.mode = dependencies.mode
            self.loginService = dependencies.loginService
            switch mode {
            case .setNewBackupPassword(let organizationInfo):
                self.organizationInfo = organizationInfo
                self.authenticator = Authenticator(api: dependencies.apiService)
                self.getOrganizationLogo = GetOrganizationLogo(apiService: dependencies.apiService)
            case .changeTemporaryPassword:
                self.passwordChangeService = BasePasswordChangeService(api: dependencies.apiService)
                self.getOrganizationLogo = GetOrganizationLogo(apiService: dependencies.apiService)
            }

            self.passwordPolicyViewModel = PasswordPolicyView.ViewModel(apiService: dependencies.apiService)

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

        func loadOrganizationLogo() {
            guard let logoId = organizationInfo?.organizationLogoID else { return }
            Task {
                organizationLogoURL = try? await getOrganizationLogo?.invoke(logoId: logoId)
            }
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
            do {
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
                ObservabilityEnv.report(.ssoAuthSetupKeys(status: .success))
            } catch let error as SSOLoginError {
                ObservabilityEnv.report(.ssoAuthSetupKeys(status: .deviceSecretNotFound))
                throw error
            } catch {
                ObservabilityEnv.report(.ssoAuthSetupKeys(status: .fromResponseError(error)))
                throw error
            }
        }

        func changeTemporaryPassword() async throws {
            do {
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
                ObservabilityEnv.report(.ssoAuthChangePassword(status: .success))
                await ssoNavigationDelegate?.globalSSOLoginDidFinish(data: updatedUserData)
                viewState = .idle
            } catch let error as SSOLoginError {
                ObservabilityEnv.report(.ssoAuthChangePassword(status: .deviceSecretNotFound))
                throw error
            } catch {
                ObservabilityEnv.report(.ssoAuthChangePassword(status: .fromResponseError(error)))
                throw error
            }
        }

        private func resetTextFieldsErrors() {
            backupPasswordStyle.mode = .idle
            repeatBackupPasswordStyle.mode = .idle
        }

        private func displayPasswordError(error: PasswordValidationError) {
            switch error {
            case .passwordEmpty, .passwordShouldHaveAtLeastEightCharacters, .passwordPolicyViolation:
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
        case .passwordPolicyViolation:
            return nil
        }
    }
}

extension SetBackupPasswordView.ViewModel: PasswordValidator {
    public func validate(for restrictions: PasswordRestrictions,
                         password: String,
                         confirmPassword: String) throws {
        if !isPasswordPolicyEnabled {
            // If the kill-switch is enabled, fallback to just simple password validation.
            try (self as PasswordValidator).validate(for: restrictions,
                                                     password: password,
                                                     confirmPassword: confirmPassword)

            return
        }

        guard password == confirmPassword else {
            throw PasswordValidationError.passwordNotEqual
        }

        self.passwordPolicyViewModel.checkPassword(password)
        if !self.passwordPolicyViewModel.passwordIsValid {
            throw PasswordValidationError.passwordPolicyViolation
        }
    }
}

#endif
