//
//  UpdatePrivateKeyRequest.swift
//  ProtonCore-Login - Created on 20.03.2024.
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

import ProtonCoreAuthentication
import ProtonCoreCrypto
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreAuthenticationKeyGeneration

/// KeysAPI
///
/// Documentation: https://protonmail.gitlab-pages.protontech.ch/Slim-API/account/#tag/Keys
struct KeysAPI {
    static let path: String = "/keys"
}

/// Update user keys for password change.
///
/// Update private keys only, use for mailbox password/single password updates.
/// This route can not be used to re-activate keys that we don't have access to, in that case the route "Activate Key" must be used first.
///
/// Documentation: https://protonmail.gitlab-pages.protontech.ch/Slim-API/account/#tag/Keys/operation/put_core-%7B_version%7D-keys-private
public final class UpdatePrivateKeyRequest: Request {

    public struct SRPAuthValues {
        let SRPSession: String // hex encoded session id
        let clientEphemeral: String // base64 encoded
        let clientProof: String // base64 encoded
    }

    let keySalt: String // base64 encoded need random value
    var userLevelKeys: [Key]
    var userAddressKeys: [Key]
    let srpAuthValues: SRPAuthValues?
    let twoFAParams: TwoFAParams?
    let userKeys: [Key]?
    let auth: PasswordAuth?
    let encryptedSecret: String?

    public init(srpAuthValues: SRPAuthValues?,
                keySalt: String,
                userlevelKeys: [Key] = [],
                addressKeys: [Key] = [],
                twoFAParams: TwoFAParams? = nil,
                userKeys: [Key]?,
                auth: PasswordAuth?,
                authCredential: AuthCredential?,
                encryptedSecret: String?) {
        self.srpAuthValues = srpAuthValues
        self.keySalt = keySalt
        self.userLevelKeys = userlevelKeys
        self.userAddressKeys = addressKeys

        self.userKeys = userKeys

        self.credential = authCredential

        // optional values
        self.twoFAParams = twoFAParams
        self.auth = auth
        self.encryptedSecret = encryptedSecret
    }

    // custom auth credentical
    let credential: AuthCredential?
    public var authCredential: AuthCredential? {
        get {
            return self.credential
        }
    }

    public var parameters: [String: Any]? {
        var keysDict: [Any] = [Any]()
        for userLevelKey in userLevelKeys where userLevelKey.isUpdated {
            keysDict.append( ["ID": userLevelKey.keyID, "PrivateKey": userLevelKey.privateKey] )
        }
        for userAddressKey in userAddressKeys where userAddressKey.isUpdated {
            keysDict.append( ["ID": userAddressKey.keyID, "PrivateKey": userAddressKey.privateKey] )
        }

        var out: [String: Any] = [
            "KeySalt": self.keySalt
        ]

        if let srpAuthValues {
            out["SRPSession"] = srpAuthValues.SRPSession
            out["ClientProof"] = srpAuthValues.clientProof
            out["ClientEphemeral"] = srpAuthValues.clientEphemeral
        }

        if !keysDict.isEmpty {
            out["Keys"] = keysDict
        }

        if let userKeys = self.userKeys {
            var userKeysDict: [Any] = []
            for userKey in userKeys where userKey.isUpdated {
                userKeysDict.append( ["ID": userKey.keyID, "PrivateKey": userKey.privateKey] )
            }
            if !userKeysDict.isEmpty {
                out["UserKeys"] = userKeysDict
            }
        }

        if let twoFAParamsDictionary = twoFAParams?.asParameterDictionary {
            out.merge(twoFAParamsDictionary, uniquingKeysWith: { a, _ in a })
        }

        if let authObj = self.auth {
            out["Auth"] = authObj.parameters
        }

        if let encryptedSecret {
            out["EncryptedSecret"] = encryptedSecret
        }

        return out
    }

    public var method: HTTPMethod {
        return .put
    }

    public var path: String {
        return KeysAPI.path + "/private"
    }
}
