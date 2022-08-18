//
//  HelperHashTests.swift
//  ProtonCore-Authentication-KeyGeneration-Tests - Created on 03/16/2021.
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
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import OpenPGP

import ProtonCore_Authentication
@testable import ProtonCore_Authentication_KeyGeneration
import ProtonCore_Crypto

class HelperHashTests: XCTestCase {
    
    func testOpenPGPRandom() {
        measure {
            for _ in 0 ..< 1000 {
                _ = PMNOpenPgp.randomBits(PasswordSaltSize.accountKey.int32Bits)
            }
        }
    }
    
    func testCryptoRandom() {
        measure {
            for _ in 0 ..< 1000 {
               _ = CryptoRandomToken(PasswordSaltSize.login.IntBits, nil)
            }
        }
    }
    
    func testOpenPGPBCrypt() {
        
        let testpassword = "this is a test password"
        let randomSalt = PasswordHash.random(bits: 128)
        
        let byteArray = NSMutableData()
        byteArray.append(randomSalt)
        let source = NSData(data: byteArray as Data) as Data
        let encodedSalt = JKBCrypt.based64DotSlash(source)
        let real_salt = "$2a$10$" + encodedSalt
        measure {
            for _ in 0 ..< 20 {
                _ = PMNBCryptHash.hashString(testpassword, salt: real_salt)
            }
        }
    }
    
    func testCryptoBCrypt() {
        let testpassword = "this is a test password"
        let randomSalt = PasswordHash.random(bits: 128)
        
        let byteArray = NSMutableData()
        byteArray.append(randomSalt)
        let source = NSData(data: byteArray as Data) as Data
        measure {
            for _ in 0 ..< 20 {
                var error: NSError?
                let passwordSlice = testpassword.data(using: .utf8)
                _ = SrpMailboxPassword(passwordSlice, source, &error)
            }
        }
    }
    
    func testAutoAuthRefreshRaceConditaion() {
        let testpassword = "this is a test password"
        let randomSalt = PasswordHash.random(bits: 128)
        
        let byteArray = NSMutableData()
        byteArray.append(randomSalt)
        let source = NSData(data: byteArray as Data) as Data
        let encodedSalt = JKBCrypt.based64DotSlash(source)
        let real_salt = "$2a$10$" + encodedSalt
        let out = PMNBCryptHash.hashString(testpassword, salt: real_salt)
        var index = out.index(out.startIndex, offsetBy: 4)
        let leftPwd = "$2y$" + String(out[index...])
        
        var error: NSError?
        let testpasswordSlice = testpassword.data(using: .utf8)
        let outSlice = SrpMailboxPassword(testpasswordSlice, source, &error)
        XCTAssertNotNil(outSlice)
        let outString = String.init(data: outSlice!, encoding: .utf8)
        XCTAssertNotNil(outString)
        index = outString!.index(outString!.startIndex, offsetBy: 4)
        let rightPwd = "$2y$" + String(outString![index...])
        XCTAssertEqual(leftPwd, rightPwd)
    }
}
