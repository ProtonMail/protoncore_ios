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
        let userData: UserData
        let loginDelegate: GlobalSSOLoginDelegate?
    }
}

extension GlobalSSOMainView {

    @MainActor
    final class ViewModel: ObservableObject {
        let apiService: APIService
        let userData: UserData

        @Published var screenState: ScreenState

        let organizationRepository: OrganizationRepository
        let postLoginSSOAccountSetup: PostLoginSSOAccountSetup

        weak var loginDelegate: GlobalSSOLoginDelegate?

        enum ScreenState {
            case loading(SSOLoginLoaderView.Dependencies)
            case error(SSOLoginErrorView.Dependencies)
            case newBackupPassword(JoinOrganizationView.Dependencies)
        }

        init(dependencies: Dependencies) {
            self.apiService = dependencies.apiService
            self.userData = dependencies.userData
            self.loginDelegate = dependencies.loginDelegate
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
                case .newBackupPassword(let unprivatizeInfo):
                    await loadNewBackupPassword(unprivatizeInfo: unprivatizeInfo)
                case .loginSuccess(let newUserData):
                    await loginDelegate?.globalSSOLoginDidFinish(data: newUserData)
                case .unimplemented:
                    break
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
                    userData: userData,
                    organizationInfo: .init(
                        organizationName: organization.displayName,
                        organizationAdminEmail: unprivatizeInfo.adminEmail,
                        organizationLogoID: organizationSettings.logoID,
                        organizationPublicKey: unprivatizeInfo.organizationPublicKey
                    ),
                    loginDelegate: loginDelegate
                ))
            } catch {
                PMLog.error(error)
                loadSSOErrorLogin(error: error) {
                    await self.loadNewBackupPassword(unprivatizeInfo: unprivatizeInfo)
                }
            }
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

#endif
