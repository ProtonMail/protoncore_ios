//
//  CreateAuthDevice.swift
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
import UIKit
import ProtonCoreServices

/// Creates a new auth device and stores the generated DeviceSecret on the Keychain
struct CreateAuthDevice {
    let userId: String
    let apiService: APIService
    let deviceSecretRepository: DeviceSecretRepositoryProtocol

    let generateDeviceSecret = GenerateDeviceSecret()

    init(
        userId: String,
        apiService: APIService,
        deviceSecretRepository: DeviceSecretRepositoryProtocol
    ) {
        self.userId = userId
        self.apiService = apiService
        self.deviceSecretRepository = deviceSecretRepository
    }

    func invoke() async throws {
        // Generate new deviceSecret
        let deviceSecret = try generateDeviceSecret.invoke()

        // Call POST /auth/v4/devices with ActivationToken and obtain a DeviceToken
        let deviceName = await UIDevice.current.name
        let createAuthDeviceRequest = CreateAuthDeviceRequest(name: deviceName)
        let (_, result): (_, CreateAuthDeviceResponse) = try await apiService.perform(request: createAuthDeviceRequest)

        guard let authDevice = result.authDevice else { throw SSOLoginError.authDeviceNotFound }

        // Persist DeviceSecret (secret, deviceId, token)
        try deviceSecretRepository.upsert(deviceSecret: .init(
            userId: userId,
            deviceId: authDevice.ID,
            secret: deviceSecret,
            token: authDevice.deviceToken
        ))
    }
}

#endif
