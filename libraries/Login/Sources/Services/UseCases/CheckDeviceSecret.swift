//
//  CheckDeviceSecret.swift
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
import ProtonCoreLog
import ProtonCoreServices

/// Check for a local valid DeviceSecret, remotely associate Device and return EncryptedSecret.
struct CheckDeviceSecret {
    let apiService: APIService
    let deviceSecretRepository: DeviceSecretRepositoryProtocol
    let associateAuthDevice: AssociateAuthDevice

    init(
        apiService: APIService,
        deviceSecretRepository: DeviceSecretRepositoryProtocol
    ) {
        self.apiService = apiService
        self.deviceSecretRepository = deviceSecretRepository
        self.associateAuthDevice = AssociateAuthDevice(
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )
    }

    func invoke(userId: String) async throws -> String? {
        let deviceSecret = try deviceSecretRepository.getByUserId(userId: userId)
        guard let deviceId = deviceSecret?.deviceId,
              let deviceToken = deviceSecret?.token else {
            PMLog.info("Device Secret not found")
            return nil
        }
        let associateResult = await associateAuthDevice.invoke(
            userId: userId,
            deviceId: deviceId,
            deviceToken: deviceToken
        )
        switch associateResult {
        case .deviceNotFound: return nil
        case .deviceNotActive: return nil
        case .deviceTokenInvalid: return nil
        case .deviceRejected: return nil
        case .sessionAlreadyAssociated: return nil
        case .unknownError: return nil
        case .success(let encryptedSecret): return encryptedSecret
        }
    }
}

#endif
