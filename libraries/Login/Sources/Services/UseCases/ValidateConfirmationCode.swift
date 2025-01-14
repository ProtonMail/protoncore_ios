//
//  RequestAdminHelp.swift
//  ProtonCore-Login - Created on 31.12.24.
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
import ProtonCoreDataModel
import ProtonCoreLog
import ProtonCoreServices

public struct ValidateConfirmationCode {

    public init() {}

    // Returns the decrypted DeviceSecret
    public func invoke(
        userData: UserData,
        authDevice: AuthDevice,
        code: String
    ) throws -> String {
        guard code.count == 4 else { throw ValidationError.invalidCode }
        guard let activationToken = authDevice.activationToken,
              let activationAddressId = authDevice.activationAddressID else {
            PMLog.error("ActivationToken or ActivationAddressId not found")
            throw ValidationError.deviceSecretNotFound
        }
        guard let userAddress = userData.addresses.first(where: { $0.addressID == activationAddressId }) else {
            PMLog.error("User address with id \(activationAddressId) not found")
            throw ValidationError.deviceSecretNotFound
        }

        let decryptedDeviceSecret = try decryptDeviceSecret(
            userData: userData,
            userAddress: userAddress,
            activationToken: activationToken
        )

        let decryptedCode = String(Crockford32.encode(decryptedDeviceSecret.sha256.data(using: .utf8)!)).prefix(4)

        guard decryptedCode == code else {
            throw ValidationError.doesNotMatch
        }

        return decryptedDeviceSecret
    }

    private func decryptDeviceSecret(
        userData: UserData,
        userAddress: Address,
        activationToken: String
    ) throws -> String {
        guard let mailboxPassword = userData.getMailboxPassword else { throw ValidationError.passphraseNotFound }

        // User keys used to decrypt the UserAddress key token
        let userDecryptionKeys: [DecryptionKey] = userData.user.keys.compactMap({
            .init(privateKey: ArmoredKey(value: $0.privateKey), passphrase: Passphrase(value: mailboxPassword))
        })
        guard let encryptedUserAddressKeyToken = userAddress.keys.primary()?.token else {
            PMLog.error("User address key token not found")
            throw ValidationError.deviceSecretNotFound
        }

        // Decrypted address token used for Address Keys
        let addressToken: String = try Decryptor.decrypt(
            decryptionKeys: userDecryptionKeys,
            encrypted: ArmoredMessage(value: encryptedUserAddressKeyToken)
        )

        // Address Keys used to decrypt activationToken
        let decryptionKeys: [DecryptionKey] = userAddress.keys.map({
            .init(privateKey: ArmoredKey(value: $0.privateKey), passphrase: Passphrase(value: addressToken))
        })

        let decryptedDeviceSecret: String = try Decryptor.decrypt(
            decryptionKeys: decryptionKeys,
            encrypted: ArmoredMessage(value: activationToken)
        )

        return decryptedDeviceSecret
    }

    public enum ValidationError: LocalizedError {
        case invalidCode
        case doesNotMatch
        case deviceSecretNotFound
        case passphraseNotFound

        public var errorDescription: String? {
            return switch self {
            case .invalidCode:
                LSTranslation._sso_invalid_code.l10n
            case .doesNotMatch:
                LSTranslation._sso_code_doesnt_match.l10n
            case .deviceSecretNotFound:
                LSTranslation._sso_device_secret_not_found.l10n
            case .passphraseNotFound:
                LSTranslation._sso_passphrase_not_found.l10n
            }
        }
    }
}

#endif
