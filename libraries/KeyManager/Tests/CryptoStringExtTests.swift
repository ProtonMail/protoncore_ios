//
//  CryptoStringExtTests.swift
//  ProtonCore-KeyManager-Tests - Created on 4/19/21.
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

import XCTest
import ProtonCore_Crypto
import ProtonCore_DataModel
@testable import ProtonCore_KeyManager

class CryptoStringExtTests: TestCaseBase {
    func testVerifyMessage() throws {
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let addrTokenSignature = content(of: "data1_address_key_token_sign")
        let calEncPass = content(of: "data1_calendar_enc_pass")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: addrTokenSignature,
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let out = try calEncPass.verifyMessageNonOptional(verifier: [addrPriv.unArmor!],
                                                 userKeys: [userkey.unArmor!],
                                                 keys: [key], passphrase: userPassphrase, time: 0)
        XCTAssertNotNil(out)
        
        let key1 = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                            privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: addrTokenSignature,
                            activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let out1 = try calEncPass.verifyMessageNonOptional(verifier: [addrPriv.unArmor!],
                                                 userKeys: [userkey.unArmor!],
                                                 keys: [key1], passphrase: userPassphrase, time: 0)
        XCTAssertNotNil(out1)
    }
}
