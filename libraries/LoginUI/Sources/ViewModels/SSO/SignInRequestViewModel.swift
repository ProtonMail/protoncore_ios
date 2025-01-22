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

import Combine
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUIFoundations
import SwiftUI

extension SignInRequestView {
    struct Dependencies {
        let mode: SignInRequestView.ViewMode
        let apiService: APIService?
        let userData: LoginData
        let adminEmail: String
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
        let onDeviceActivatedAction: () -> Void
        let onDeviceRejectedAction: () -> Void
    }
}

extension SignInRequestView {

    enum ViewMode {
        case requestForAdminApproval(code: String)
        case requestApproveFromAnotherDevice(code: String, devices: [AuthDevice])
    }

    @MainActor
    final class ViewModel: ObservableObject {
        @Published var mode: ViewMode
        @Published var devices: [AuthDevice] = []
        private let userData: LoginData
        let adminEmail: String
        private var deleteAuthDevice: DeleteAuthDevice?

        let onDeviceActivatedAction: () -> Void
        let onDeviceRejectedAction: () -> Void

        private var authDeviceLoop: AuthDevicePollingLoop?

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        var memberEmail: String { userData.user.email ?? LUITranslation.unknown.l10n }

        private var cancellables: Set<AnyCancellable> = .init()

        init(dependencies: Dependencies) {
            self.mode = dependencies.mode
            self.userData = dependencies.userData
            self.adminEmail = dependencies.adminEmail
            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate
            self.onDeviceActivatedAction = dependencies.onDeviceActivatedAction
            self.onDeviceRejectedAction = dependencies.onDeviceRejectedAction
            if let apiService = dependencies.apiService,
               let deviceSecret = try? DeviceSecretRepository().getByUserId(userId: userData.user.ID) {
                authDeviceLoop = AuthDevicePollingLoop(
                    apiService: apiService,
                    observingDeviceId: deviceSecret.deviceId
                )
                self.deleteAuthDevice = DeleteAuthDevice(apiService: apiService)
            }
            if case .requestApproveFromAnotherDevice(_, let devices) = mode {
                self.devices = devices
            }
        }

        func startAuthDeviceLoop() {
            authDeviceLoop?.start()
            observePendingDevice()
        }

        func stopAuthDeviceLoop() {
            authDeviceLoop?.stop()
        }

        var screenTitle: String {
            switch mode {
            case .requestForAdminApproval: return LUITranslation.share_confirmation_code_title.l10n
            case .requestApproveFromAnotherDevice: return LUITranslation.approve_sign_in_another_device_title.l10n
            }
        }

        var bodyDescription: String {
            switch mode {
            case .requestForAdminApproval: 
                return String.localizedStringWithFormat(
                    LUITranslation.share_confirmation_code_description.l10n,
                    adminEmail,
                    memberEmail
                )
            case .requestApproveFromAnotherDevice: return LUITranslation.approve_sign_in_another_device_description.l10n
            }
        }

        var primaryButtonTitle: String {
            switch mode {
            case .requestForAdminApproval: return LUITranslation.use_backup_password_instead.l10n
            case .requestApproveFromAnotherDevice: return LUITranslation.use_backup_password_instead.l10n
            }
        }

        var secondaryButtonTitle: String {
            switch mode {
            case .requestForAdminApproval: return LUITranslation._core_cancel_button.l10n
            case .requestApproveFromAnotherDevice: return LUITranslation.ask_administrator_for_help.l10n
            }
        }

        func primaryActionButtonTapped() {
            switch mode {
            case .requestForAdminApproval:
                ssoNavigationDelegate?.showEnterBackupPassword(data: userData, adminEmail: adminEmail)
            case .requestApproveFromAnotherDevice:
                ssoNavigationDelegate?.showEnterBackupPassword(data: userData, adminEmail: adminEmail)
            }

        }

        func secondaryActionButtonTapped() {
            switch mode {
            case .requestForAdminApproval:
                ssoNavigationDelegate?.globalSSOLoginDidCancel()
            case .requestApproveFromAnotherDevice:
                ssoNavigationDelegate?.showRequestAdminHelpConfirmation(data: userData, adminEmail: adminEmail)
            }
        }

        private func observePendingDevice() {
            authDeviceLoop?.authDeviceObserver
                .receive(on: DispatchQueue.main)
                .sink { [weak self] authDevice in
                    guard let self else { return }
                    switch authDevice.state {
                    case .active, .activeNoAssociatedSession:
                        authDeviceLoop?.stop()
                        onDeviceActivatedAction()
                    case .rejected:
                        authDeviceLoop?.stop()
                        onDeviceRejected(authDevice: authDevice)
                    case .inactive, .pendingActivation, .pendingAdminActivation:
                        // Do nothing and continue looping
                        break
                    }
                }
                .store(in: &cancellables)
        }

        private func onDeviceRejected(authDevice: AuthDevice) {
            Task {
                try? await self.deleteAuthDevice?.invoke(deviceId: authDevice.ID)
                onDeviceRejectedAction()
            }
        }
    }
}

extension AuthDevice {
    private static let timeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        return formatter
    }()

    var lastActivityString: String {
        guard let lastActivityTime = TimeInterval(lastActivityTime) else {
            return LUITranslation.unknown.l10n
        }
        return Self.timeFormatter.localizedString(for: Date(timeIntervalSince1970: lastActivityTime), relativeTo: Date())
    }

    var icon: Image {
        guard let platform else { return IconProvider.tv }
        switch platform {
        case .android, .iOS:
            return IconProvider.mobile
        default:
            return IconProvider.tv
        }
    }
}

#endif
