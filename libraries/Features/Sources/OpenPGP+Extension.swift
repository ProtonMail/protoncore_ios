//
//  OpenPGP+Extension.swift
//  ProtonCore-Features - Created on 22.05.2018.
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
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_Common
#if canImport(ProtonCore_Crypto_VPN)
import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
import ProtonCore_Crypto
#endif
import ProtonCore_DataModel
import ProtonCore_KeyManager

extension Data {

    func getSessionFromPubKeyPackageNonOptional(_ passphrase: String, privKeys: [Data]) throws -> SymmetricKey {
        return try Crypto().getSessionNonOptional(keyPacket: self, privateKeys: privKeys, passphrase: passphrase)
    }

    func getSessionFromPubKeyPackageNonOptional(addrPrivKey: String, passphrase: String) throws -> SymmetricKey {
        return try Crypto().getSessionNonOptional(keyPacket: self, privateKey: addrPrivKey, passphrase: passphrase)
    }
}
