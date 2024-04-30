//
//  TwoFA.swift
//  ProtonCore-Services - Created on 25.04.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation

public struct TwoFA: Codable {

    public var enabled: State
    public var FIDO2: Fido2?

    public init(enabled: State, fido2: Fido2? = nil) {
        self.enabled = enabled
        self.FIDO2 = fido2
    }

    public struct State: OptionSet, Codable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let off: State = []
        public static let totp = State(rawValue: 1 << 0)
        public static let webAuthn = State(rawValue: 1 << 1)
    }

    public struct Fido2: Codable {
        public let authenticationOptions: AuthenticationOptions?
        public let registeredKeys: [RegisteredKey]
    }

    public struct AuthenticationOptions: Codable {
        public let publicKey: PublicKey
    }

    public struct PublicKey: Codable {
        public let timeout: Int
        public let challenge: Data
        public let userVerification: String
        public let rpId: String
        public let allowCredentials: [AllowedCredential]
    }
    public struct AllowedCredential: Codable {
        public let id: Data
        public let type: String
    }

    public struct RegisteredKey: Codable {
        public let attestationFormat: String
        public let credentialID: Data
        public let name: String
    }
}
