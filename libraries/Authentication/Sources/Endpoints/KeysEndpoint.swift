//
//  KeySaltsEndpoint.swift
//  ProtonCore-Authentication - Created on 17/03/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
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
import ProtonCoreDataModel
import ProtonCoreNetworking

extension AuthService {
    public struct KeysInfoResponse: APIDecodableResponse, Encodable {
        public let address: PublicAddressKeyData
        public let catchAll: PublicAddressKeyData?
        public let unverified: PublicAddressKeyData?
        public let warnings: [String]
        public let protonMX: Bool
        public let isProton: Int
    }

    struct KeysEndpoint: Request {

        var path: String {
            return "/core/v4/keys/all"
        }
        var method: HTTPMethod {
            return .get
        }

        var parameters: [String: Any]? {
            [
                "Email": email,
                "InternalOnly": internalOnly ? 1 : 0
            ]
        }

        var isAuth: Bool {
            return true
        }
        var auth: AuthCredential?
        var authCredential: AuthCredential? {
            return self.auth
        }

        var email: String
        var internalOnly: Bool

        init(email: String, internalOnly: Bool = true) {
            self.email = email
            self.internalOnly = internalOnly
        }
    }
}

extension AuthService {
    public struct PublicAddressKeyData: Codable {
        public let keys: [PublicAddressKey]
        public let signedKeyList: PublicSignedKeyList?
    }

    public struct PublicAddressKey: Codable {
        public let flags: Int
        public let publicKey: String
        public let source: PublicAddressKeySource?

        public enum PublicAddressKeySource: Int, Codable {
            case `internal` = 0

            /// Web Key Directory
            case wkd = 1

            /// keys.openphp.org
            case koo = 2
        }
    }

    public struct PublicSignedKeyList: Codable {
        public let data: String?
        public let signature: String?
        public let minEpochId: Int?
        public let maxEpochId: Int?
        public let expectedMinEpochId: Int?
    }
}
