//
//  HashTests.swift
//  ProtonCore-Hash-Tests - Created on 29/10/20.
//
//  Copyright (c) 2020 Proton Technologies AG
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

@testable import ProtonCore_Hash

final class HashTests: XCTestCase {
    
    func testStringHashMD5() {
        // expected generated with $ echo -n "test string" | md5
        XCTAssertEqual("test string".md5, "6f8db599de986fab7a21625b7916589c")
    }
    
    func testStringHashMD5Byte() {
        // expected generated with $ echo -n "test string" | md5 and split into ints
        XCTAssertEqual("test string".md5_byte,
                       Data([0x6f, 0x8d, 0xb5, 0x99, 0xde, 0x98, 0x6f, 0xab, 0x7a, 0x21, 0x62, 0x5b, 0x79, 0x16, 0x58, 0x9c]))
    }
    
    func testStringHashSHA1() {
        // expected generated with $ echo -n "test string" | shasum -a 1
        XCTAssertEqual("test string".sha1, "661295c9cbf9d6b2f6428414504a8deed3020641")
    }
    
    func testStringHashSHA224() {
        // expected generated with $ echo -n "test string" | shasum -a 224
        XCTAssertEqual("test string".sha224, "dd8a1f5793f157323ccb28fe953bb8abb659bd61b7e9fae10be26f7a")
    }
    
    func testStringHashSHA256() {
        // expected generated with $ echo -n "test string" | shasum -a 256
        XCTAssertEqual("test string".sha256, "d5579c46dfcc7f18207013e65b44e4cb4e2c2298f4ac457ba8f82743f31e930b")
    }
    
    func testStringHashSHA384() {
        // expected generated with $ echo -n "test string" | shasum -a 384
        XCTAssertEqual("test string".sha384,
                       "e213dccb3221e0b8fdd995dcc1d04e218fc649981038bfac81abc98932369bac0efb758b92eccd80321df8eb64efae87")
    }
    
    func testStringHashSHA512() {
        // expected generated with $ echo -n "test string" | shasum -a 512
        XCTAssertEqual("test string".sha512,
                       "10e6d647af44624442f388c2c14a787ff8b17e6165b83d767ec047768d8cbcb71a1a3226e7cc7816bc79c0427d94a9da688c41a3992c7bf5e4d7cc3e0be5dbac")
    }
    
    func testStringHashSHA512Bytes() {
        // expected generated with $ echo -n "test string" | shasum -a 512 and split into ints
        XCTAssertEqual("test string".sha512_byte,
                       Data([0x10, 0xe6, 0xd6, 0x47, 0xaf, 0x44, 0x62, 0x44, 0x42, 0xf3, 0x88, 0xc2, 0xc1, 0x4a, 0x78, 0x7f,
                             0xf8, 0xb1, 0x7e, 0x61, 0x65, 0xb8, 0x3d, 0x76, 0x7e, 0xc0, 0x47, 0x76, 0x8d, 0x8c, 0xbc, 0xb7,
                             0x1a, 0x1a, 0x32, 0x26, 0xe7, 0xcc, 0x78, 0x16, 0xbc, 0x79, 0xc0, 0x42, 0x7d, 0x94, 0xa9, 0xda,
                             0x68, 0x8c, 0x41, 0xa3, 0x99, 0x2c, 0x7b, 0xf5, 0xe4, 0xd7, 0xcc, 0x3e, 0x0b, 0xe5, 0xdb, 0xac]))
    }
    
    func testDataHashSHA512Bytes() {
        // expected generated with $ echo -n "test string" | shasum -a 512 and split into ints
        XCTAssertEqual("test string".data(using: .utf8)!.sha512_byte,
                       Data([0x10, 0xe6, 0xd6, 0x47, 0xaf, 0x44, 0x62, 0x44, 0x42, 0xf3, 0x88, 0xc2, 0xc1, 0x4a, 0x78, 0x7f,
                             0xf8, 0xb1, 0x7e, 0x61, 0x65, 0xb8, 0x3d, 0x76, 0x7e, 0xc0, 0x47, 0x76, 0x8d, 0x8c, 0xbc, 0xb7,
                             0x1a, 0x1a, 0x32, 0x26, 0xe7, 0xcc, 0x78, 0x16, 0xbc, 0x79, 0xc0, 0x42, 0x7d, 0x94, 0xa9, 0xda,
                             0x68, 0x8c, 0x41, 0xa3, 0x99, 0x2c, 0x7b, 0xf5, 0xe4, 0xd7, 0xcc, 0x3e, 0x0b, 0xe5, 0xdb, 0xac]))
    }
}
