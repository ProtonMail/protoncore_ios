//
//  DecryptEncryptedSecret.swift
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
import Foundation
import ProtonCoreCrypto
import ProtonCoreLog
import ProtonCoreServices

/// Decrypt Passphrase from EncryptedSecret + DeviceSecret.
///
///     EncryptedSecret = base64Encode(aesGcm(data = passphrase, key = base64Decoded(deviceSecret), context))
///     Passphrase = bcrypt(password, salt)
///     Context = "account.device-secret"
///
///     Passphrase = aesGcm(data = base64Decode(encryptedSecret), key = base64Decoded(deviceSecret), context)
struct DecryptEncryptedSecret {
    let deviceSecretRepository: DeviceSecretRepositoryProtocol
    let aeadCrypto = AeadCrypto()

    enum Constants {
        /// Used for Global SSO auth device secret context
        static let deviceSecretContext = "account.device-secret"
    }

    init(deviceSecretRepository: DeviceSecretRepositoryProtocol) {
        self.deviceSecretRepository = deviceSecretRepository
    }

    func invoke(
        userId: String,
        encryptedSecret: String?
    ) throws -> String? {
        guard let encryptedSecret,
              let deviceSecret = try deviceSecretRepository.getByUserId(userId: userId)?.secret,
              let deviceSecretData = Data(base64Encoded: deviceSecret) else {
            try deviceSecretRepository.delete(for: userId)
            return nil
        }

        return try aeadCrypto.decrypt(
            base64EncryptedString: encryptedSecret,
            key: deviceSecretData,
            aad: Constants.deviceSecretContext.data(using: .utf8)
        )
    }
}

#endif
