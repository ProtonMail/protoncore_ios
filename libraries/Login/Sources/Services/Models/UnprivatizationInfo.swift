//
//  UnprivatizationInfo.swift
//  ProtonCore-Login - Created on 13.11.24.
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

import ProtonCoreCrypto
import ProtonCoreNetworking

public final class UnprivatizationInfo: Response, APIDecodableResponse, Encodable {
    var state: UnprivatizeState
    var adminEmail: String
    var orgKeyFingerprintSignature: ArmoredSignature
    var orgPublicKey: ArmoredKey

    public init(
        state: UnprivatizeState,
        adminEmail: String,
        orgKeyFingerprintSignature: ArmoredSignature,
        orgPublicKey: ArmoredKey
    ) {
        self.state = state
        self.adminEmail = adminEmail
        self.orgKeyFingerprintSignature = orgKeyFingerprintSignature
        self.orgPublicKey = orgPublicKey
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = try container.decode(UnprivatizeState.self, forKey: .state)
        adminEmail = try container.decode(String.self, forKey: .adminEmail)
        let unArmoredOrgSignature = try container.decode(String.self, forKey: .orgKeyFingerprintSignature)
        orgKeyFingerprintSignature = ArmoredSignature(value: unArmoredOrgSignature)
        let unarmoredOrgPublicKey = try container.decode(String.self, forKey: .orgPublicKey)
        orgPublicKey = ArmoredKey(value: unarmoredOrgPublicKey)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encode(adminEmail, forKey: .adminEmail)
        try container.encode(orgKeyFingerprintSignature.value, forKey: .orgKeyFingerprintSignature)
        try container.encode(orgPublicKey.value, forKey: .orgPublicKey)
    }

    required init() {
        fatalError("init() has not been implemented")
    }
    
    public enum UnprivatizeState: Int, Codable {
        case declined
        case pending
        case ready
    }

    enum CodingKeys: String, CodingKey {
        case state
        case adminEmail
        case orgKeyFingerprintSignature
        case orgPublicKey
    }
}
