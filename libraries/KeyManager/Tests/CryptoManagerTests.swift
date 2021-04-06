//
//  CryptoManagerTests.swift
//  ProtonCore-KeyManager-Tests - Created on 4/19/21.
//
//  Copyright (c) 2021 Proton Technologies AG
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
import ProtonCore_DataModel
@testable import ProtonCore_KeyManager

class CryptoManagerTests: TestCaseBase {

    func testGenerateCryptoKeyRing() {
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        let keyRing = try? CryptoManager.generateCryptoKeyRing(key: userkey, passphrase: userPassphrase)
        XCTAssertNotNil(keyRing)
    }
  
    func testDecryptString() {
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        let addrToken = content(of: "data1_address_key_token")
        let addrClear = content(of: "data1_address_key_clear_pass")
        
        let splited = try! addrToken.split()
        let keyPacket = splited?.getBinaryKeyPacket()
        let dataPacket = splited?.getBinaryDataPacket()
        
        var error: NSError?
        let keyRing = try? CryptoManager.generateCryptoKeyRing(key: userkey, passphrase: userPassphrase)
        let clear = CryptoManager.decryptString(keyPacket: keyPacket!,
                                                encryptedPacket: dataPacket!,
                                                keyRing: keyRing!, error: &error)
        XCTAssertTrue(addrClear == clear)
    }
  
    func testVerifyDetached() {
        let addrPriv = content(of: "data1_address_key")
        let addrClear = content(of: "data1_address_key_clear_pass")
        let addrTokenSign = content(of: "data1_address_key_token_sign")

        let keyRing = try? CryptoManager.generateCryptoKeyRing(key: addrPriv, passphrase: addrClear)
        let boolValue = try? CryptoManager.verifyDetached(signature: addrTokenSign,
                                                          plainText: addrClear,
                                                          keyRing: keyRing!, verifyTime: 0)
        XCTAssertTrue(boolValue!)
    }
}
