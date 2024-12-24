//
//  SSOLoginLoaderViewModel.swift
//  ProtonCore-LoginUI - Created on 26/11/2024.
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

import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreLog
import ProtonCoreUIFoundations
import SwiftUI

extension GlobalSSOMainView {
    struct Dependencies {
        let apiService: APIService
        let loginService: Login
        let userData: LoginData
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
    }
}

extension GlobalSSOMainView {

    @MainActor
    final class ViewModel: ObservableObject {
        let apiService: APIService
        let loginService: Login
        private let userData: LoginData

        @Published var screenState: ScreenState

        let organizationRepository: OrganizationRepository
        let postLoginSSOAccountSetup: PostLoginSSOAccountSetup

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        enum ScreenState {
            case loading(SSOLoginLoaderView.Dependencies)
            case error(SSOLoginErrorView.Dependencies)
            case newBackupPassword(JoinOrganizationView.Dependencies)
            case requestApproveFromAnotherDevice(SignInRequestView.Dependencies)
            case enterBackupPassword(EnterBackupPasswordView.Dependencies)
        }

        init(dependencies: Dependencies) {
            self.apiService = dependencies.apiService
            self.loginService = dependencies.loginService
            self.userData = dependencies.userData
            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate
            screenState = .loading(.init(user: userData.user))
            self.postLoginSSOAccountSetup = .init(
                apiService: apiService,
                userData: userData
            )
            organizationRepository = .init(apiService: apiService)
        }

        func startPostLoginSetup() async {
            do {
                let nextStep = try await postLoginSSOAccountSetup.invoke()
                switch nextStep {
                case .setupBackupPassword(let unprivatizeInfo):
                    await loadNewBackupPassword(unprivatizeInfo: unprivatizeInfo)
                case .loginSuccess(let newUserData):
                    await ssoNavigationDelegate?.globalSSOLoginDidFinish(data: newUserData)
                case .requestApproveFromAnotherDevice(let code, let devices):
                    loadRequestApproveFromAnotherDevice(code: code, devices: devices)
                case .enterBackupPassword:
                    loadEnterBackupPassword()
                case .unimplemented:
                    loadSSOErrorLogin(error: UnimplementedError.unimplemented, action: startPostLoginSetup)
                }
            } catch {
                PMLog.error(error)
                loadSSOErrorLogin(error: error, action: startPostLoginSetup)
            }
        }

        private func loadNewBackupPassword(unprivatizeInfo: UnprivatizeUserSuccess) async {
            do {
                let organization = try await organizationRepository.getOrganization()
                let organizationSettings = try await organizationRepository.getOrganizationSettings()
                screenState = .newBackupPassword(.init(
                    apiService: apiService,
                    loginService: loginService,
                    userData: userData,
                    organizationInfo: .init(
                        organizationName: organization.displayName,
                        organizationAdminEmail: unprivatizeInfo.adminEmail,
                        organizationLogoID: organizationSettings.logoID,
                        organizationPublicKey: unprivatizeInfo.organizationPublicKey
                    ),
                    ssoNavigationDelegate: ssoNavigationDelegate
                ))
            } catch {
                PMLog.error(error)
                loadSSOErrorLogin(error: error) {
                    await self.loadNewBackupPassword(unprivatizeInfo: unprivatizeInfo)
                }
            }
        }

        private func loadRequestApproveFromAnotherDevice(code: String, devices: [AuthDevice]) {
            screenState = .requestApproveFromAnotherDevice(.init(
                mode: .requestApproveFromAnotherDevice(code: code, devices: devices),
                userData: userData,
                ssoNavigationDelegate: ssoNavigationDelegate
            ))
        }

        private func loadEnterBackupPassword() {
            screenState = .enterBackupPassword(.init(
                userData: userData,
                apiService: apiService,
                ssoNavigationDelegate: ssoNavigationDelegate
            ))
        }

        private func loadSSOErrorLogin(error: Error, action: @escaping () async -> Void) {
            screenState = .error(.init(
                user: userData.user,
                error: error,
                continueAction: {
                    Task { [weak self] in
                        guard let self else { return }
                        self.screenState = .loading(.init(user: userData.user))
                        await action()
                    }
                }
            ))
        }
    }
}

enum UnimplementedError: LocalizedError {
    case unimplemented

    var errorDescription: String { "Flow not implemented" }
}

#endif
