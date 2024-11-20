//
//  AeadCrypto.swift
//  ProtonCore-Crypto - Created on 15.11.24.
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

import Foundation
import CryptoKit

/// A class for encrypting and decrypting data using AES-GCM (Authenticated Encryption with Associated Data).
///
/// The `AeadCrypto` class provides methods to perform encryption and decryption of strings and data
/// using the AES-GCM cryptographic algorithm. It supports optional associated data (AAD) for additional
/// authentication. The class is designed to handle both base64-encoded strings and raw `Data` objects
/// for input and output.
///
/// ## Overview
/// The encryption process uses a randomly generated 12-byte initialization vector (IV) for security,
/// which is combined with the ciphertext and authentication tag in the resulting output. Decryption
/// ensures the integrity of the data by verifying the authentication tag.
///
/// - AES-GCM is a widely used encryption scheme that provides both confidentiality and integrity.
/// - This class uses the `CryptoKit` framework for cryptographic operations.
///
/// ## Methods
/// - `encrypt(value:key:aad:)`: Encrypts a string or `Data` object using the specified key and optional AAD.
/// - `decrypt(base64EncryptedString:key:aad:)`: Decrypts a base64-encoded encrypted string using the specified key and optional AAD.
/// - `decrypt(value:key:aad:)`: Decrypts an encrypted `Data` object using the specified key and optional AAD.
///
/// ## Example Usage
/// ```swift
/// let crypto = AeadCrypto()
/// let key = Data(repeating: 0, count: 32) // Example 256-bit key
/// let plaintext = "Hello, World!"
///
/// do {
///     let encrypted = try crypto.encrypt(value: plaintext, key: key)
///     print("Encrypted: \(encrypted)")
///
///     let decrypted = try crypto.decrypt(base64EncryptedString: encrypted, key: key)
///     print("Decrypted: \(decrypted)")
/// } catch {
///     print("Encryption/Decryption error: \(error)")
/// }
/// ```
///
/// - Note: This implementation uses a fixed 12-byte IV and 16-byte authentication tag,
///         which are standard for AES-GCM.
public final class AeadCrypto {
    private let AesCipherIvBytes = 12
    private let AesCipherTagBytes = 16

    public init() {}

    // MARK: Public

    /// Encrypts a string using AES-GCM.
    ///
    /// - Parameters:
    ///   - value: The string to encrypt.
    ///   - key: The encryption key as `Data`.
    ///   - aad: Optional associated data for authentication.
    /// - Returns: The encrypted string, base64-encoded as `iv | ciphertext | tag`
    /// - Throws: An error if the encryption process fails.
    public func encrypt(value: String, key: Data, aad: Data? = nil) throws -> String {
        let valueData = value.data(using: .utf8)!
        return Base64.encode(raw: try encrypt(value: valueData, key: CryptoKit.SymmetricKey(data: key), aad: aad))
    }

    /// Encrypts raw data using AES-GCM.
    ///
    /// - Parameters:
    ///   - value: The data to encrypt.
    ///   - key: The encryption key as `Data`.
    ///   - aad: Optional associated data for authentication.
    /// - Returns: The encrypted data encoded as `iv | ciphertext | tag`
    /// - Throws: An error if the encryption process fails.
    public func encrypt(value: Data, key: Data, aad: Data? = nil) throws -> Data {
        return try encrypt(value: value, key: CryptoKit.SymmetricKey(data: key), aad: aad)
    }

    /// Decrypts a base64-encoded encrypted string using AES-GCM.
    ///
    /// - Parameters:
    ///   - base64EncryptedString: The encrypted string, base64-encoded as `iv | ciphertext | tag`
    ///   - key: The decryption key as `Data`.
    ///   - aad: Optional associated data for authentication.
    /// - Returns: The decrypted string.
    /// - Throws: An error if the decryption process fails.
    public func decrypt(base64EncryptedString: String, key: Data, aad: Data? = nil) throws -> String {
        let encryptedData = Base64.decode(base64: base64EncryptedString)
        let decryptedData = try decrypt(value: encryptedData, key: CryptoKit.SymmetricKey(data: key), aad: aad)
        return String(data: decryptedData, encoding: .utf8)!
    }

    /// Decrypts encrypted data using AES-GCM.
    ///
    /// - Parameters:
    ///   - value: The encrypted data encoded as `iv | ciphertext | tag`.
    ///   - key: The decryption key as `Data`.
    ///   - aad: Optional associated data for authentication.
    /// - Returns: The decrypted data.
    /// - Throws: An error if the decryption process fails.
    public func decrypt(value: Data, key: Data, aad: Data? = nil) throws -> Data {
        return try decrypt(value: value, key: CryptoKit.SymmetricKey(data: key), aad: aad)
    }

    // MARK: Private

    /// Generates a random initialization vector (IV) for AES-GCM encryption.
    ///
    /// The IV is generated from a cryptographically secure random bytes source.
    /// By default `AES.GCM.Nonce` uses 12-byte.
    /// https://developer.apple.com/documentation/cryptokit/aes/gcm/nonce/init()
    ///
    /// - Returns: A 12-byte nonce for AES-GCM.
    /// - Throws: An error if the nonce generation fails.
    private func getRandomIV() throws -> AES.GCM.Nonce {
        guard AesCipherIvBytes == 12 else {
            var randomIV = Data(count: AesCipherIvBytes)
            let result = randomIV.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, AesCipherIvBytes, $0.baseAddress!)
            }
            guard result == errSecSuccess else { fatalError() }
            return try AES.GCM.Nonce(data: randomIV)
        }
        return AES.GCM.Nonce()
    }

    /// Encrypts the provided data using AES-GCM.
    ///
    /// This method performs AES-GCM encryption on the given plaintext data. It generates a random
    /// initialization vector (IV) and optionally incorporates associated data (AAD) into the
    /// encryption process for additional authentication. The resulting encrypted data contains:
    /// - The 12-byte IV
    /// - The ciphertext
    /// - The 16-byte authentication tag
    ///
    /// - Parameters:
    ///   - value: The plaintext data to encrypt.
    ///   - key: The cryptographic key used for encryption as a `CryptoKit.SymmetricKey`.
    ///   - aad: Optional associated data used for authentication.
    /// - Returns: A `Data` object containing the concatenated IV, ciphertext, and authentication tag.
    /// - Throws: An error if encryption fails.
    private func encrypt(value: Data, key: CryptoKit.SymmetricKey, aad: Data?) throws -> Data {
        let iv = try getRandomIV()

        var sealedBox: AES.GCM.SealedBox
        if let aad {
            sealedBox = try AES.GCM.seal(value, using: key, nonce: iv, authenticating: aad)
        } else {
            sealedBox = try AES.GCM.seal(value, using: key, nonce: iv)
        }

        return Data(iv + sealedBox.ciphertext + sealedBox.tag)
    }

    /// Decrypts the provided AES-GCM encrypted data.
    ///
    /// This method extracts the IV, ciphertext, and authentication tag from the input data and performs
    /// AES-GCM decryption. It optionally uses associated data (AAD) for verifying the integrity and
    /// authenticity of the encrypted data. If the authentication tag verification fails, an error is thrown.
    ///
    /// - Parameters:
    ///   - value: The encrypted data, which must include the concatenated IV, ciphertext, and tag.
    ///   - key: The cryptographic key used for decryption as a `CryptoKit.SymmetricKey`.
    ///   - aad: Optional associated data used for authentication.
    /// - Returns: A `Data` object containing the decrypted plaintext.
    /// - Throws: An error if decryption fails, such as when the authentication tag is invalid.
    private func decrypt(value: Data, key: CryptoKit.SymmetricKey, aad: Data?) throws -> Data {
        let iv = value[..<AesCipherIvBytes] // Extract the IV from the first 12 bytes
        let nonce = try AES.GCM.Nonce(data: iv)
        let cipherText = value[AesCipherIvBytes..<(value.count - AesCipherTagBytes)] // Extract the ciphertext
        let tag = value[(value.count - AesCipherTagBytes)...] // Extract the 16-byte authentication tag

        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: cipherText, tag: tag)
        var decryptedData: Data
        if let aad {
            decryptedData = try AES.GCM.open(sealedBox, using: key, authenticating: aad)
        } else {
            decryptedData = try AES.GCM.open(sealedBox, using: key)
        }
        return decryptedData
    }

}

