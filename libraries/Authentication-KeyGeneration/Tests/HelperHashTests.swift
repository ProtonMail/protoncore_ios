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
import ProtonCoreCrypto
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif
import SwiftBCrypt

import ProtonCoreAuthentication
@testable import ProtonCoreAuthenticationKeyGeneration

class HelperHashTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    func testSrpRandomBitsRandom() throws {
        measure {
            for _ in 0 ..< 1000 {
                do {
                    _ = try PasswordHash.random(bits: PasswordSaltSize.accountKey.int32Bits)
                } catch {
                    XCTFail("Random bits generating failed with error: \(error)")
                }
            }
        }
    }

    func testCryptoRandom() {
        measure {
            for _ in 0 ..< 1000 {
                _ = CryptoGo.CryptoRandomToken(PasswordSaltSize.login.IntBits, nil)
            }
        }
    }

    func testCryptoBCrypt() throws {
        let testpassword = "this is a test password"
        let randomSalt = try PasswordHash.random(bits: 128)

        let byteArray = NSMutableData()
        byteArray.append(randomSalt)
        let source = NSData(data: byteArray as Data) as Data
        measure {
            for _ in 0 ..< 20 {
                var error: NSError?
                let passwordSlice = testpassword.data(using: .utf8)
                _ = CryptoGo.SrpMailboxPassword(passwordSlice, source, &error)
            }
        }
    }

    func testAutoAuthRefreshRaceCondition() throws {
        let testpassword = "this is a test password"
        let randomSalt = try PasswordHash.random(bits: 128)

        let byteArray = NSMutableData()
        byteArray.append(randomSalt)
        let source = NSData(data: byteArray as Data) as Data
        let encodedSalt = JKBCrypt.base64DotSlash(source)
        let real_salt = "$2a$10$" + encodedSalt

        let hash = try BCrypt.hash(phrase: testpassword, salt: Data(real_salt.utf8))
        var out = String(bytes: hash.bytes, encoding: .utf8)!
        // SwiftBCrypt library leaves \0 at the end of computed has. And it must be removed.
        out.removeLast()

        var index = out.index(out.startIndex, offsetBy: 4)
        let leftPwd = "$2y$" + String(out[index...])

        var error: NSError?
        let testpasswordSlice = testpassword.data(using: .utf8)
        let outSlice = CryptoGo.SrpMailboxPassword(testpasswordSlice, source, &error)
        XCTAssertNotNil(outSlice)
        let outString = String.init(data: outSlice!, encoding: .utf8)
        XCTAssertNotNil(outString)
        index = outString!.index(outString!.startIndex, offsetBy: 4)
        let rightPwd = "$2y$" + String(outString![index...])
        XCTAssertEqual(leftPwd, rightPwd)
    }
}
