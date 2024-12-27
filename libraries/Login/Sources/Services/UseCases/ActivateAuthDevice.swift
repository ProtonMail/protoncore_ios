//
//  ActivateAuthDevice.swift
//  ProtonCore-Login - Created on 24.12.24.
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
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreLog
import ProtonCoreServices

 /// Activate Device with userId and passphrase.
public struct ActivateAuthDevice {
    let apiService: APIService
    let deviceSecretRepository: DeviceSecretRepositoryProtocol

    let getEncryptedSecret: GetEncryptedSecret

    public init(
        apiService: APIService,
        deviceSecretRepository: DeviceSecretRepositoryProtocol
    ) {
        self.apiService = apiService
        self.deviceSecretRepository = deviceSecretRepository
        self.getEncryptedSecret = GetEncryptedSecret()
    }

    public func invoke(
        userId: String,
        passphrase: String
    ) async throws {
        guard let deviceSecret = try deviceSecretRepository.getByUserId(userId: userId) else {
            throw SSOLoginError.deviceSecretNotFound
        }
        guard let encryptedSecret = try getEncryptedSecret.invoke(
            passphrase: passphrase,
            deviceSecret: deviceSecret.secret
        ) else {
            throw SSOLoginError.encryptedSecretNotFound
        }

        // Call POST /auth/v4/devices/\(deviceID) and send the EncryptedSecret
        let activateAuthDeviceRequest = ActivateAuthDeviceRequest(
            deviceID: deviceSecret.deviceId,
            encryptedSecret: encryptedSecret
        )
        let (_, _): (_, DefaultResponse) = try await apiService.perform(request: activateAuthDeviceRequest)
    }
}

#endif
