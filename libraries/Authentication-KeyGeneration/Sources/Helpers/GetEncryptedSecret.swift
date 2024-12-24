//
//  GetEncryptedSecret.swift
//  ProtonCore-Authentication-KeyGeneration - Created on 24.12.24.
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
import ProtonCoreCrypto

public struct GetEncryptedSecret {
    let aeadCrypto = AeadCrypto()

    enum Constants {
        /// Used for Global SSO auth device secret context
        static let deviceSecretContext = "account.device-secret"
    }

    public init() {}

    public func invoke(passphrase: String, deviceSecret: String) throws -> String? {
        guard let deviceSecretKey = Data(base64Encoded: deviceSecret) else { return nil }
        return try aeadCrypto.encrypt(
            value: passphrase,
            key: deviceSecretKey,
            aad: Constants.deviceSecretContext.data(using: .utf8)
        )
    }
}
