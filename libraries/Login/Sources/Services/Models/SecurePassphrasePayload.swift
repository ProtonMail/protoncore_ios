//
//  Organization.swift
//  ProtonCore-Login
//
//  Copyright (c) 2025 Proton Technologies AG
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

import Foundation
import ProtonCoreCrypto
import ProtonCoreObservability

// Documentation of how the payload should look like
// https://protonag.atlassian.net/wiki/spaces/CP/pages/48302032/Data+specification#Encrypted-payload

/// Used when forking a session. The payload contains the passphrase that is then passed to the other device by the Backend.
public struct SecurePassphrasePayload {
    public let encryptedPayload: String
    public let passphrase: String

    enum Errors: Error {
        case couldNotCreateJsonString
        case couldNotExtractPassphraseFromEncryptedPayload
    }

    /// For cross platform compatibility I need to wrap the passphrase in this json:
    /// {
    ///    type: "default",
    ///    keyPassword: "passphrase_not_encrypted"
    /// }
    /// And then encrypt the json using ASM/GCM/NoPadding 16 iv bytes 16 tag bytes
    public init(passphrase: String?, encryptionKey: Data) throws {
        self.passphrase = passphrase ?? ""
        var json: [String: String] = [
            "type": "default"
        ]

        if let passphrase = passphrase {
            json["keyPassword"] = passphrase
        }

        let jsonData = try JSONSerialization.data(withJSONObject: json)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw Errors.couldNotCreateJsonString
        }

        let cipher = AeadCrypto(cipherIvBytes: ._16)
        self.encryptedPayload = try cipher.encrypt(value: jsonString, key: encryptionKey)
    }

    public init(encryptedPayload: String, encryptionKey: Data) throws {
        self.encryptedPayload = encryptedPayload
        let cipher = AeadCrypto(cipherIvBytes: ._16)
        let jsonString = try cipher.decrypt(base64EncryptedString: encryptedPayload, key: encryptionKey)
        guard let jsonData = jsonString.data(using: .utf8) else {
            ObservabilityEnv.report(.qrLoginDecodeQRCode(status: .failedToExtractPassphraseFromPayload))
            throw Errors.couldNotExtractPassphraseFromEncryptedPayload
        }
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: String]
        if let passphrase = json?["keyPassword"] {
            self.passphrase = passphrase
        } else {
            self.passphrase = ""
        }
    }
}
