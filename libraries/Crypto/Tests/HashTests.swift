//
//  HashTests.swift
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
import ProtonCoreCryptoGoInterface
import ProtonCoreCrypto

class HashTests: CryptoTestBase {
    
    // Assert helper when function has return value
    public func AssertNoThrow<T> (_ expression: @autoclosure () throws -> T,
                                  _ message: String = "",
                                  file: StaticString = #file,
                                  line: UInt = #line,
                                  _ resultHandler: (T) -> Void) {
        var result: T?
        XCTAssertNoThrow(try { result = try expression() }(), message, file: file, line: line)
        XCTAssertNotNil(result, "Result is nil", file: file, line: line)
        resultHandler(result!)
    }

    func testEncoderBased64WithString() {
        let check = "TestString"
        let based64 = Based64.encode(value: check)
        let bStr = Based64String.init(based64: based64)
        XCTAssertEqual(check, String(data: bStr.decode, encoding: .utf8))
    }

    func testArgon2Challenge() {
        let b64Challenge = "qbYJSn07JQGfol0u8MJTZ16fDRyFo2AR6phcgqlZCr44RBpz/odJc17EROMfMOpz2dE8oHW2JHeqoRax2ha4bpGusDBkEySSWJU+cmuWePzUC58fTY+VJMLBMDLhdqV9QKvozeqKcoPzqDoHZZYmyWQf4DIAKfgaha/WwzMikQMBAAAAIAAAAOEQAAABAAAA"
        AssertNoThrow(try Hash.Argon2(challengeData: b64Challenge)) { solved in
            XCTAssertEqual(solved, "ewAAAAAAAABXe+n/4g0Hfz40eEw7h5d3XeiKdWilfCJvz0izj7p0YA==")
        }
        
        let utf8str = "kljsfkljsadfl".data(using: String.Encoding.utf8)
        let b64Challenge1 = utf8str!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        XCTAssertThrowsError(try Hash.Argon2(challengeData: b64Challenge1)) { message in
            XCTAssertTrue(message.localizedDescription.contains("challenge length"))
        }
    }
    
    func testECDLPChallenge() {
        let b64Challenge = "kavkPtdQF/bQMvMlCjfgMdRdMsIsA8DP0X0/p44n+6jcchSeEewrjqcwy0FYF0jkWO1Wz1pdSe3meRNtpf+g2DQluiIbobuq4mM7J45fabUlKRtbEhSogoc9H3S74Wlj"
        AssertNoThrow(try Hash.ECDLP(challengeData: b64Challenge)) { solved in
            XCTAssertEqual(solved, "ngAAAAAAAAAczZrEZLqS9+TGdB7vNex1HzvPpFJD7Qd4+yPEgGduDw==")
        }
        
        let utf8str = "kljsfkljsadfl".data(using: String.Encoding.utf8)
        let b64Challenge1 = utf8str!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))

        XCTAssertThrowsError(try Hash.ECDLP(challengeData: b64Challenge1)) { message in
            XCTAssertTrue(message.localizedDescription.contains("challenge length"))
        }
    }
}
