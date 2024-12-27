//
//  JoinOrganizationView.swift
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

extension JoinOrganizationView {
    struct Dependencies {
        let apiService: APIService?
        let loginService: Login?
        let userData: LoginData
        let organizationInfo: OrganizationInfo
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
    }

    struct OrganizationInfo {
        let organizationName: String
        let organizationAdminEmail: String
        let organizationLogoID: String?
        let organizationPublicKey: ArmoredKey
    }
}

extension JoinOrganizationView {

    @MainActor
    final class ViewModel: ObservableObject, PasswordValidator {
        @Published var viewState: ViewState = .idle
        @Published var bannerState: BannerState = .none

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
        private let loginService: Login?
        private let userData: LoginData
        let organizationInfo: OrganizationInfo
        private let deviceSecretRepository: DeviceSecretRepositoryProtocol

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        init(dependencies: Dependencies) {
            if let apiService = dependencies.apiService {
                self.authenticator = Authenticator(api: apiService)
            }
            self.loginService = dependencies.loginService
            self.userData = dependencies.userData
            self.organizationInfo = dependencies.organizationInfo
            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate
            self.deviceSecretRepository = DeviceSecretRepository()
        }

        var joinOrganizationTitle: String {
            String.localizedStringWithFormat(
                LUITranslation.join_organization_title.l10n,
                organizationInfo.organizationName
            )
        }

        var joinOrganizationDescription: String {
            String.localizedStringWithFormat(
                LUITranslation.join_organization_description.l10n,
                organizationInfo.organizationAdminEmail
            )
        }

        var organizationLogoURL: URL? {
            guard let _ = organizationInfo.organizationLogoID else { return nil }
            // TODO: Retrieve logo from /organizations/logo/{logoId}
            return nil
        }

        func continueTapped() {
            Task {
                do {
                    guard let authenticator, let loginService else { throw SSOLoginError.authenticatorNotFound }
                    resetTextFieldsErrors()
                    try validate(
                        for: .default,
                        password: backupPasswordContent.text,
                        confirmPassword: repeatBackupPasswordContent.text
                    )
                    viewState = .loading
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
