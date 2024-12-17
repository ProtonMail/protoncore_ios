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
    case newBackupPassword(UnprivatizeUserSuccess)
    case loginSuccess(UserData)
    case unimplemented
}

public final class PostLoginSSOAccountSetup {
    let apiService: APIService
    let userData: LoginData

    let createAuthDevice: CreateAuthDevice
    let verifyUnprivatization: VerifyUnprivatization
    let checkDeviceSecret: CheckDeviceSecret
    let decryptEncryptedSecret: DecryptEncryptedSecret
    let buildAndValidatePassphrases: BuildAndValidatePassphrases

    public init(apiService: APIService, userData: LoginData) {
        self.apiService = apiService
        self.userData = userData

        let deviceSecretRepository = DeviceSecretRepository()

        self.createAuthDevice = CreateAuthDevice(
            userId: userData.user.ID,
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )

        self.verifyUnprivatization = VerifyUnprivatization(apiService: apiService)

        self.checkDeviceSecret = CheckDeviceSecret(
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )

        self.decryptEncryptedSecret = DecryptEncryptedSecret(deviceSecretRepository: deviceSecretRepository)
        self.buildAndValidatePassphrases = BuildAndValidatePassphrases()
    }

    public enum State {
        case firstLogin
        case validSecret(passphrases: [String: String])
        case unimplemented
    }

    public func invoke() async throws -> SSOLoginScreen {
        let state = await loginSSOState(userData: userData)
        switch state {
        case .firstLogin:
            try await createAuthDevice.invoke()
            let verifyInfo = try await verifyUnprivatization.invoke()
            return .newBackupPassword(verifyInfo)
        case .validSecret(let passphrases):
            return .loginSuccess(userData.updated(passphrases: passphrases))
        case .unimplemented:
            return .unimplemented
        }
    }

    private func loginSSOState(userData: LoginData) async -> State {
        guard !userData.user.keys.isEmpty else {
            return .firstLogin
        }

        do {
            let encryptedSecret = try await checkDeviceSecret.invoke(userId: userData.user.ID)
            guard let decryptedSecret = try decryptEncryptedSecret.invoke(userId: userData.user.ID, encryptedSecret: encryptedSecret) else {
                return .unimplemented
            }
            return try deviceSecretState(userData: userData, decryptedSecret: decryptedSecret)
        } catch {
            PMLog.error(error)
        }

        return .unimplemented
    }

    private func deviceSecretState(userData: LoginData, decryptedSecret: String) throws -> State {
        guard let passphrases = try buildAndValidatePassphrases.buildAndValidatePassphrases(
            passphrase: decryptedSecret,
            salts: userData.salts,
            userKeys: userData.user.keys
        ) else {
            return .unimplemented
        }
        return .validSecret(passphrases: passphrases)
    }
}
#endif
