//
//  AssociateAuthDevice.swift
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

 /// Associate Device with user.
 ///
 /// Return an EncryptedSecret (that can be decrypted with a DeviceSecret).
struct AssociateAuthDevice {
    let apiService: APIService
    let deviceSecretRepository: DeviceSecretRepositoryProtocol

    enum AssociateDeviceResult: Equatable {
        case deviceNotFound
        case deviceNotActive
        case deviceTokenInvalid
        case deviceRejected
        case sessionAlreadyAssociated
        case success(String)
        case unknownError
    }

    init(
        apiService: APIService,
        deviceSecretRepository: DeviceSecretRepositoryProtocol
    ) {
        self.apiService = apiService
        self.deviceSecretRepository = deviceSecretRepository
    }

    func invoke(
        userId: String,
        deviceId: String,
        deviceToken: String
    ) async -> AssociateDeviceResult {
        do {
            // Call POST /auth/v4/devices/\(deviceID)/associate and obtain an EncryptedSecret
            let associateAuthDeviceRequest = AssociateAuthDeviceRequest(deviceID: deviceId, deviceToken: deviceToken)
            let (_, result): (_, AssociateAuthDeviceResponse) = try await apiService.perform(request: associateAuthDeviceRequest)
            guard let encryptedSecret = result.authDevice?.encryptedSecret else {
                PMLog.error("Associate AuthDevice error: EncryptedSecret not found")
                return .unknownError
            }
            return .success(encryptedSecret)
        } catch {
            return handleAssociateDeviceError(error: error, userId: userId)
        }
    }

    private func handleAssociateDeviceError(error: Error, userId: String) -> AssociateDeviceResult {
        switch error.bestShotAtReasonableErrorCode {
        case APIErrorCode.authDeviceNotFound:
            PMLog.error("Associate AuthDevice error: Not found")
            return .deviceNotFound
        case APIErrorCode.authDeviceNotActive:
            PMLog.error("Associate AuthDevice error: Not active")
            return .deviceNotActive
        case APIErrorCode.authDeviceTokenInvalid:
            PMLog.error("Associate AuthDevice error: Token invalid")
            try? deviceSecretRepository.delete(for: userId)
            return .deviceTokenInvalid
        case APIErrorCode.authDeviceRejected:
            PMLog.error("Associate AuthDevice error: Rejected")
            return .deviceRejected
        case APIErrorCode.notAllowed:
            PMLog.error("Associate AuthDevice error: Not allowed")
            return .sessionAlreadyAssociated
        default:
            PMLog.error("Associate AuthDevice error (\(error.bestShotAtReasonableErrorCode)): \(error.localizedDescription)")
            return .unknownError
        }
    }
}

#endif
