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

import ProtonCoreAuthentication
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreObservability
import ProtonCoreServices
import ProtonCoreUIFoundations
import SwiftUI

extension GlobalSSOMainView {
    struct Dependencies {
        let mode: PostLoginSSOAccountSetup.Mode
        let apiService: APIService
        let loginService: Login
        let userData: LoginData
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
    }
}

extension GlobalSSOMainView {

    @MainActor
    final class ViewModel: ObservableObject {
        private let apiService: APIService
        private let loginService: Login
        private var userData: LoginData {
            didSet {
                postLoginSSOAccountSetup.update(userData: userData)
            }
        }
        private let authService: Authenticator

        var mode: PostLoginSSOAccountSetup.Mode
        @Published var screenState: ScreenState

        let organizationRepository: OrganizationRepository
        let postLoginSSOAccountSetup: PostLoginSSOAccountSetup

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        enum ScreenState {
            case loading(SSOLoginLoaderView.Dependencies)
            case error(SSOLoginLoaderView.Dependencies)
            case newBackupPassword(SetBackupPasswordView.Dependencies)
            case requestApproveFromAnotherDevice(SignInRequestView.Dependencies)
            case enterBackupPassword(EnterBackupPasswordView.Dependencies)
            case accessGrantedDenied(AccessGrantedDeniedView.Dependencies)
        }

        init(dependencies: Dependencies) {
            self.mode = dependencies.mode
            self.apiService = dependencies.apiService
            self.loginService = dependencies.loginService
            self.authService = Authenticator(api: dependencies.apiService)
            self.userData = dependencies.userData
            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate
            screenState = .loading(.init(user: userData.user, errorRetryAction: nil))
            self.postLoginSSOAccountSetup = .init(
                apiService: apiService,
                userData: userData
            )
            organizationRepository = .init(apiService: apiService)
        }

        func invokePostLoginSetup() async {
            do {
                let nextStep = try await postLoginSSOAccountSetup.invoke(mode: mode)
                switch nextStep {
                case .setupBackupPassword(let unprivatizeInfo):
                    await loadSetNewBackupPassword(unprivatizeInfo: unprivatizeInfo)
                case .loginSuccess(let newUserData):
                    await ssoNavigationDelegate?.globalSSOLoginDidFinish(data: newUserData)
                case .loginSuccessNeedPasswordChange(let newUserData):
                    self.screenState = .accessGrantedDenied(.init(
                        mode: .accessGranted(userData: newUserData),
                        ssoNavigationDelegate: ssoNavigationDelegate
                    ))
                case .requestApproveFromAnotherDevice(let code, let devices):
                    await loadRequestApproveFromAnotherDevice(code: code, devices: devices)
                case .enterBackupPassword:
                    await loadEnterBackupPassword()
                case .requestApproveFromAdmin(let code):
                    await loadRequestApproveFromAdmin(code: code)
                }
            } catch {
                PMLog.error(error)
                loadSSOErrorLogin(error: error, action: invokePostLoginSetup)
            }
        }

        private func loadSetNewBackupPassword(unprivatizeInfo: UnprivatizeUserSuccess) async {
            do {
                let organization = try await organizationRepository.getOrganization()
                let organizationSettings = try await organizationRepository.getOrganizationSettings()
                ObservabilityEnv.report(.ssoAuthLoadOrganization(status: .successful))
                screenState = .newBackupPassword(.init(
                    mode: .setNewBackupPassword(organizationInfo: .init(
                        organizationName: organization.displayName,
                        organizationAdminEmail: unprivatizeInfo.adminEmail,
                        organizationLogoID: organizationSettings.logoID,
                        organizationPublicKey: unprivatizeInfo.organizationPublicKey
                    )),
                    apiService: apiService,
                    userData: userData,
                    loginService: loginService,
                    ssoNavigationDelegate: ssoNavigationDelegate
                ))
            } catch {
                ObservabilityEnv.report(.ssoAuthLoadOrganization(status: .failed))
                PMLog.error(error)
                loadSSOErrorLogin(error: error) {
                    await self.loadSetNewBackupPassword(unprivatizeInfo: unprivatizeInfo)
                }
            }
        }

        private func loadRequestApproveFromAnotherDevice(code: String, devices: [AuthDevice]) async {
            screenState = .requestApproveFromAnotherDevice(.init(
                mode: .requestApproveFromAnotherDevice(code: code, devices: devices),
                apiService: apiService,
                userData: userData,
                ssoNavigationDelegate: ssoNavigationDelegate,
                onDeviceActivatedAction: { [weak self] in
                    Task { [weak self] in
                        self?.mode = .default
                        await self?.invokePostLoginSetup()
                    }
                },
                onDeviceRejectedAction: { [weak self] in
                    self?.loadDeviceRejected()
                }
            ))
        }

        private func loadEnterBackupPassword() async {
            screenState = .enterBackupPassword(.init(
                userData: userData,
                apiService: apiService,
                ssoNavigationDelegate: ssoNavigationDelegate
            ))
        }

        private func loadRequestApproveFromAdmin(code: String) async {
            do {
                let organizationSignature = try await organizationRepository.getOrganizationSignature()
                ObservabilityEnv.report(.ssoAuthLoadOrganization(status: .successful))
                screenState = .requestApproveFromAnotherDevice(.init(
                    mode: .requestForAdminApproval(code: code, adminEmail: organizationSignature.fingerprintSignatureAddress),
                    apiService: apiService,
                    userData: userData,
                    ssoNavigationDelegate: ssoNavigationDelegate,
                    onDeviceActivatedAction: { [weak self] in
                        guard let self else { return }
                        Task {
                            self.mode = .default
                            let newUser = try await self.authService.getUserInfo()
                            self.userData = self.userData.updated(user: newUser)
                            await self.invokePostLoginSetup()
                        }
                    },
                    onDeviceRejectedAction: { [weak self] in
                        self?.loadDeviceRejected()
                    }
                ))
            } catch {
                ObservabilityEnv.report(.ssoAuthLoadOrganization(status: .failed))
                PMLog.error(error)
                loadSSOErrorLogin(error: error) {
                    await self.loadRequestApproveFromAdmin(code: code)
                }
            }
        }

        private func loadDeviceRejected() {
            screenState = .accessGrantedDenied(.init(
                mode: .accessDenied,
                ssoNavigationDelegate: ssoNavigationDelegate
            ))
        }

        private func loadSSOErrorLogin(error: Error, action: @escaping () async -> Void) {
            self.screenState = .error(.init(
                user: userData.user,
                errorRetryAction: .init(
                    error: error,
                    retryAction: { [weak self] in
                        Task { [weak self] in
                            guard let self else { return }
                            self.screenState = .loading(.init(user: userData.user, errorRetryAction: nil))
                            await action()
                        }
                    }
                )
            ))
        }
    }
}

#endif
