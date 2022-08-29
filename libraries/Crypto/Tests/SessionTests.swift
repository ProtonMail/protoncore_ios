//
//  SessionTests.swift
//  ProtonCore-Crypto-Tests - Created on 07/15/22.
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
import Crypto
#if canImport(ProtonCore_Crypto_VPN)
@testable import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
@testable import ProtonCore_Crypto
#endif

class SessionTests: XCTestCase {
    
    func testAlgo() {
        let des3Check = "3des"
        guard let des3 = Algorithm.init(rawValue: des3Check) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(des3Check, des3.value)
        
        let tripledesCheck = "tripledes"
        guard let tripledes = Algorithm.init(rawValue: tripledesCheck) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(tripledesCheck, tripledes.value)
        
        let cast5check = "cast5"
        guard let cast5 = Algorithm.init(rawValue: cast5check) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(cast5check, cast5.value)
        
        let aes128check = "aes128"
        guard let aes128 = Algorithm.init(rawValue: aes128check) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(aes128check, aes128.value)
        
        let aes192check = "aes192"
        guard let aes192 = Algorithm.init(rawValue: aes192check) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(aes192check, aes192.value)
        
        let aes256check = "aes256"
        guard let aes256 = Algorithm.init(rawValue: aes256check) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(aes256check, aes256.value)
        
        let nilcheck = Algorithm.init(rawValue: "aaaa")
        XCTAssertNil(nilcheck)
    }
    
    func testSessionKey() {
        let aes256check = "aes256"
        guard let aes256 = Algorithm.init(rawValue: aes256check) else {
            XCTFail("nil")
            return
        }
        XCTAssertEqual(aes256check, aes256.value)
        
        var error: NSError?
        let length = 32
        guard let check = CryptoRandomToken(length, &error) else {
            XCTFail("random token is nil")
            return
        }
        let sessionKey = SessionKey.init(sessionKey: check, algo: aes256)
        
        XCTAssertTrue(sessionKey.algo.value == aes256check)
        XCTAssertEqual(sessionKey.sessionKey, check)
    }
    
}
