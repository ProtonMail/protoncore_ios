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

import ProtonCoreLog
import ProtonCoreServices

public enum SSOLoginScreen {
    case setupBackupPassword(UnprivatizeUserSuccess)
    case loginSuccess(UserData)
    case requestApproveFromAnotherDevice(
        code: String,
        devices: [AuthDevice],
        unprivatizationInfo: UnprivatizationInfo
    )
    case enterBackupPassword(UnprivatizationInfo)
    case requestApproveFromAdmin(code: String, unprivatizationInfo: UnprivatizationInfo)
    case unimplemented
}

public final class PostLoginSSOAccountSetup {
    public enum Mode {
        case `default`
        case requestAdminHelp
    }

    let apiService: APIService
    let userData: LoginData

    let createAuthDevice: CreateAuthDevice
    let getUnprivatizationInfo: GetUnprivatizationInfo
    let verifyUnprivatization: VerifyUnprivatization
    let checkDeviceSecret: CheckDeviceSecret
    let decryptEncryptedSecret: DecryptEncryptedSecret
    let buildAndValidatePassphrases: BuildAndValidatePassphrases
    let getAuthDevices: GetAuthDevices
    let generateConfirmationCode: GenerateConfirmationCode

    public init(apiService: APIService, userData: LoginData) {
        self.apiService = apiService
        self.userData = userData

        let deviceSecretRepository = DeviceSecretRepository()

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

    enum State {
        case firstLogin
        case validSecret(passphrases: [String: String])
        case noSecret
        case invalidSecret
    }

    public func invoke(mode: Mode) async throws -> SSOLoginScreen {
        switch mode {
        case .default:
            return try await loadDefaultScreen()
        case .requestAdminHelp:
            return try await loadRequestAdminHelpScreen()
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
            return .loginSuccess(userData.updated(passphrases: passphrases))
        case .noSecret, .invalidSecret:
            try await createAuthDevice.invoke(addresses: userData.addresses)
            let authDevices = try await getAuthDevices.invoke()
            let unprivatizationInfo = try await getUnprivatizationInfo.invoke()
            guard !authDevices.isEmpty else { return .enterBackupPassword(unprivatizationInfo) }
            let code = try generateConfirmationCode.invoke(userId: userData.user.ID)
            return .requestApproveFromAnotherDevice(
                code: code,
                devices: authDevices,
                unprivatizationInfo: unprivatizationInfo
            )
        }
    }

    private func loginSSOState(userData: LoginData) async throws -> State {
        guard !userData.user.keys.isEmpty else {
            return .firstLogin
        }

        let encryptedSecret = try await checkDeviceSecret.invoke(userId: userData.user.ID)
        guard let decryptedSecret = try decryptEncryptedSecret.invoke(
            userId: userData.user.ID,
            encryptedSecret: encryptedSecret
        ) else {
            return .noSecret
        }
        return try deviceSecretState(userData: userData, decryptedSecret: decryptedSecret)
    }

    private func deviceSecretState(userData: LoginData, decryptedSecret: String) throws -> State {
        guard let passphrases = try buildAndValidatePassphrases.buildAndValidatePassphrases(
            passphrase: decryptedSecret,
            salts: userData.salts,
            userKeys: userData.user.keys
        ) else {
            return .invalidSecret
        }
        return .validSecret(passphrases: passphrases)
    }

    private func loadRequestAdminHelpScreen() async throws -> SSOLoginScreen {
        let code = try generateConfirmationCode.invoke(userId: userData.user.ID)
        let unprivatizationInfo = try await getUnprivatizationInfo.invoke()
        return .requestApproveFromAdmin(code: code, unprivatizationInfo: unprivatizationInfo)
    }
}
#endif
