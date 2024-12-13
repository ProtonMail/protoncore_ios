//
//  BuildAndValidatePassphrases.swift
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
import ProtonCoreCryptoGoInterface
import ProtonCoreDataModel
import ProtonCoreUtilities

/// Build and validate passphrases for a given mailboxPassword and KeySalts
struct BuildAndValidatePassphrases {

    func buildPassphrases(salts: [KeySalt], mailboxPassword: String) throws -> [String: String] {
        var error: NSError?

        let passphrases = salts.filter {
            $0.keySalt != nil
        }.map { salt -> (String, String) in
            let keySalt = salt.keySalt!

            let passSlice = mailboxPassword.data(using: .utf8)

            let saltPackage = Data(base64Encoded: keySalt, options: NSData.Base64DecodingOptions(rawValue: 0))
            let passphraseSlice = CryptoGo.SrpMailboxPassword(passSlice, saltPackage, &error)

            let passphraseUncut = String.init(data: passphraseSlice!, encoding: .utf8)
            // by some internal reason of go-srp, output will be 60 characters but we need only last 31 of them
            let passphrase = passphraseUncut!.suffix(31)

            return (salt.ID, String(passphrase))
        }

        if let error { throw error }

        return Dictionary(passphrases, uniquingKeysWith: { one, _ in one })
    }

    func buildPassphrases(salts: [KeySalt], passphrase: String) throws -> [String: String] {
        let passphrases = salts.map { ($0.ID, passphrase) }
        return Dictionary(passphrases, uniquingKeysWith: { one, _ in one })
    }

    func validatePassphrases(passphrases: ([String: String]), userKeys: [Key]) -> Bool {
        var isValid = false

        // new keys - user keys
        passphrases.forEach { keyID, passphrase in
            userKeys.filter { $0.keyID == keyID && $0.primary == 1 }
            .map(\.privateKey)
            .forEach { privateKey in
                var error: NSError?
                let armored = CryptoGo.CryptoNewKeyFromArmored(privateKey, &error)

                do {
                    _ = try armored?.unlock(passphrase.utf8)
                    isValid = true
                } catch {
                    // do nothing
                }
            }
        }

        return isValid
    }
}

#endif
