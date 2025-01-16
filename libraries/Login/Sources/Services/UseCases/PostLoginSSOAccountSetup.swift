//
//  PostLoginSSOAccountSetup.swift
//  ProtonCore-Login - Created on 26.11.24.
//
//  Copyright (c) 2024 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
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
import ProtonCoreNetworking
import ProtonCoreServices

public enum SSOLoginScreen {
    case setupBackupPassword(UnprivatizeUserSuccess)
    case loginSuccess(UserData)
    case loginSuccessNeedPasswordChange(UserData)
    case requestApproveFromAnotherDevice(
        code: String,
        devices: [AuthDevice],
        unprivatizationInfo: UnprivatizationInfo
    )
    case enterBackupPassword(UnprivatizationInfo)
    case requestApproveFromAdmin(code: String, unprivatizationInfo: UnprivatizationInfo)
}

public final class PostLoginSSOAccountSetup {
    public enum Mode {
        case `default`
        case requestAdminHelp
    }

    private let apiService: APIService
    private let authenticator: Authenticator
    private var userData: LoginData

    private let deviceSecretRepository: DeviceSecretRepository
    private let createAuthDevice: CreateAuthDevice
    private let getUnprivatizationInfo: GetUnprivatizationInfo
    private let verifyUnprivatization: VerifyUnprivatization
    private let checkDeviceSecret: CheckDeviceSecret
    private let decryptEncryptedSecret: DecryptEncryptedSecret
    private let buildAndValidatePassphrases: BuildAndValidatePassphrases
    private let getAuthDevices: GetAuthDevices
    private let generateConfirmationCode: GenerateConfirmationCode

    public init(apiService: APIService, userData: LoginData) {
        self.apiService = apiService
        self.userData = userData
        self.authenticator = Authenticator(api: apiService)

        self.deviceSecretRepository = DeviceSecretRepository()

        self.createAuthDevice = CreateAuthDevice(
            userId: userData.user.ID,
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )

        self.getUnprivatizationInfo = GetUnprivatizationInfo(apiService: apiService)

        self.verifyUnprivatization = VerifyUnprivatization(apiService: apiService)

        self.checkDeviceSecret = CheckDeviceSecret(
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )

        self.decryptEncryptedSecret = DecryptEncryptedSecret(deviceSecretRepository: deviceSecretRepository)
        self.buildAndValidatePassphrases = BuildAndValidatePassphrases()
        self.getAuthDevices = GetAuthDevices(apiService: apiService)
        self.generateConfirmationCode = GenerateConfirmationCode(deviceSecretRepository: deviceSecretRepository)
    }

    public func update(userData: UserData) {
        self.userData = userData
    }

    enum State {
        case firstLogin
        case validSecret(passphrases: [String: String])
        case noSecret
        case invalidSecret
        case inactiveSecret
        case noUnprivatizationInfo
    }

    public func invoke(mode: Mode) async throws -> SSOLoginScreen {
        switch mode {
        case .default:
            return try await loadDefaultScreen()
        case .requestAdminHelp:
            let unprivatizationInfo = try await getUnprivatizationInfo.invoke()
            return try await loadRequestAdminHelpScreen(unprivatizationInfo: unprivatizationInfo)
        }
    }

    private func loadDefaultScreen() async throws -> SSOLoginScreen {
        let state = try await loginSSOState(userData: userData)
        switch state {
        case .firstLogin:
            try await createAuthDevice.invoke()
            let verifyInfo = try await verifyUnprivatization.invoke()
            return .setupBackupPassword(verifyInfo)
        case .validSecret(let passphrases):
            return try await validSecretUserCheck(passphrases: passphrases)
        case .inactiveSecret:
            return try await loadScreenWithSecretAvailable()
        case .noSecret, .invalidSecret:
            try await createAuthDevice.invoke(addresses: userData.addresses)
            return try await loadScreenWithSecretAvailable()
        case .noUnprivatizationInfo:
            return .loginSuccess(userData)
        }
    }

    private func loginSSOState(userData: LoginData) async throws -> State {
        guard !userData.user.keys.isEmpty else {
            return try await firstLoginState()
        }

        switch try await checkDeviceSecret.invoke(userId: userData.user.ID) {
        case .success(let encryptedSecret):
            guard let decryptedSecret = try decryptEncryptedSecret.invoke(
                userId: userData.user.ID,
                encryptedSecret: encryptedSecret
            ) else {
                return .noSecret
            }
            return try deviceSecretState(userData: userData, decryptedSecret: decryptedSecret)
        case .inactiveSecret:
            return .inactiveSecret
        case .noSecret:
            return .noSecret
        }
    }

    private func firstLoginState() async throws -> State {
        // Try to get UnprivatizationInfo, if NotExists or NotAllowed (2501, 10401), fallback to regular SSO.
        // We must not set keys to allow API rollout to global SSO incrementally.
        do {
            _ = try await getUnprivatizationInfo.invoke()
        } catch {
            if let responseError = error as? ResponseError,
               responseError.responseCode == APIErrorCode.unprivatizationNotAllowed
                || responseError.responseCode == APIErrorCode.unprivatizationNotExists {
                PMLog.debug("Unprivatization not allowed. Falling back to regular SSO")
                return .noUnprivatizationInfo
            }
            throw error
        }
        return .firstLogin
    }

    private func deviceSecretState(userData: LoginData, decryptedSecret: String) throws -> State {
        guard let passphrases = try buildAndValidatePassphrases.buildAndValidatePassphrases(
            passphrase: decryptedSecret,
            salts: userData.salts,
            userKeys: userData.user.keys
        ) else {
            try deviceSecretRepository.delete(for: userData.user.ID)
            return .invalidSecret
        }
        return .validSecret(passphrases: passphrases)
    }

    private func validSecretUserCheck(passphrases: [String: String]) async throws -> SSOLoginScreen {
        let user = try await authenticator.getUserInfo()
        let newUserData = userData.updated(user: user)
        if user.hasTemporaryPassword {
            return .loginSuccessNeedPasswordChange(newUserData.updated(passphrases: passphrases))
        } else {
            return .loginSuccess(newUserData.updated(passphrases: passphrases))
        }
    }

    private func loadRequestAdminHelpScreen(unprivatizationInfo: UnprivatizationInfo) async throws -> SSOLoginScreen {
        let code = try generateConfirmationCode.invoke(userId: userData.user.ID)
        return .requestApproveFromAdmin(code: code, unprivatizationInfo: unprivatizationInfo)
    }

    private func loadScreenWithSecretAvailable() async throws -> SSOLoginScreen {
        let authDevices = try await getAuthDevices.invoke()
            .filter({ $0.state == .active })
        let unprivatizationInfo = try await getUnprivatizationInfo.invoke()
        guard !authDevices.isEmpty else {
            if (userData.user.hasTemporaryPassword) {
                return try await loadRequestAdminHelpScreen(unprivatizationInfo: unprivatizationInfo)
            } else {
                return .enterBackupPassword(unprivatizationInfo)
            }
        }
        let code = try generateConfirmationCode.invoke(userId: userData.user.ID)
        return .requestApproveFromAnotherDevice(
            code: code,
            devices: authDevices,
            unprivatizationInfo: unprivatizationInfo
        )
    }

}
#endif
