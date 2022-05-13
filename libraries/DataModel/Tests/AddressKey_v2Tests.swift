//
//  AddressKeyTests.swift
//  ProtonCore-DataModel-Tests - Created on 26.04.22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

@testable import ProtonCore_DataModel
import XCTest

class AddressKey_v2Tests: XCTestCase {
    
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        jsonDecoder = .init()
    }
    
    override func tearDown() {
        jsonDecoder = nil
        super.tearDown()
    }
    
    func testParseAddressKeyCorrectly() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData())
        
        XCTAssertEqual(sut, .init(
            id: "po3wnqUjlYZ4L7N02HUq7eqC2nmrbUBWsGuqbA_0IUv5crXeMJyCuVHwxwfIOkCpyxKwHt_3giLkVXF_uZ0zKQ==",
            version: 3,
            privateKey: "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
            token: "-----BEGIN PGP TOKEN-----...",
            signature: "-----BEGIN PGP SIGNATURE-----...",
            primary: true,
            active: true,
            flags: .init(rawValue: 0)
        ))
    }
    
    func testParseAddressKeyWithPrimaryAndActiveDisabled() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(primary: 0, active: 0))
        
        XCTAssertEqual(sut, .init(
            id: "po3wnqUjlYZ4L7N02HUq7eqC2nmrbUBWsGuqbA_0IUv5crXeMJyCuVHwxwfIOkCpyxKwHt_3giLkVXF_uZ0zKQ==",
            version: 3,
            privateKey: "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
            token: "-----BEGIN PGP TOKEN-----...",
            signature: "-----BEGIN PGP SIGNATURE-----...",
            primary: false,
            active: false,
            flags: .init(rawValue: 0)
        ))
    }
    
    func testParseAddressKeyWithFlags0_ItHas0Flags() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(flags: 0))
        
        XCTAssertEqual(sut.flags, .init(rawValue: 0))
    }
    
    func testParseAddressKeyWithFlags1_ItHasVerifySignatureFlag() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(flags: 1))
        
        XCTAssertEqual(sut.flags, .verifySignatures)
    }
    
    func testParseAddressKeyWithFlags2_ItHasEncryptNewDataFlag() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(flags: 2))
        
        XCTAssertEqual(sut.flags, .encryptNewData)
    }
    
    func testParseAddressKeyWithFlags3_ItHasVerifySignatureAndEncryptNewDataFlags() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(flags: 3))
        
        XCTAssertEqual(sut.flags, [.verifySignatures, .encryptNewData])
    }
    
    func testParseAddressKeyWithFlags4_ItHasBelongsToExternalAddressFlag() throws {
        let sut = try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(flags: 4))
        
        XCTAssertEqual(sut.flags, .belongsToExternalAddress)
    }
    
    func testParseAddressKeyWithActive2_ItThrowsDecodingError() throws {
        XCTAssertThrowsError(try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(active: 2))) { error in
            assertDecodingError(
                error: error,
                codingKey: AddressKey_v2.CodingKeys.active.rawValue,
                debugDescription: "Expected to receive `0` or `1` but found `2` instead."
            )
        }
    }
    
    func testParseAddressKeyWithPrimary77_ItThrowsDecodingError() throws {
        XCTAssertThrowsError(try jsonDecoder.decode(AddressKey_v2.self, from: .addressKeyJSONData(primary: 77))) { error in
            assertDecodingError(
                error: error,
                codingKey: AddressKey_v2.CodingKeys.primary.rawValue,
                debugDescription: "Expected to receive `0` or `1` but found `77` instead."
            )
        }
    }
    
}

private extension Data {
    
    static func addressKeyJSONData(primary: Int = 1, active: Int = 1, flags: Int = 0) -> Self {
        let json = """
            {
                "Fingerprints" : [
                    "ce8b1560eee758c0fda68f1fe428f05b3b9735c0",
                    "fd30367d8543ab3130b90bfe45a929920fdadab4"
                ],
                "Active" : \(active),
                "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                "Flags" : \(flags),
                "ID" : "po3wnqUjlYZ4L7N02HUq7eqC2nmrbUBWsGuqbA_0IUv5crXeMJyCuVHwxwfIOkCpyxKwHt_3giLkVXF_uZ0zKQ==",
                "Version" : 3,
                "PublicKey" : "-----BEGIN PGP PUBLIC KEY BLOCK-----...",
                "Primary" : \(primary),
                "Activation" : null,
                "Fingerprint" : "ce8b1560eee758c0fda68f1fe428f05b3b9735c0",
                "PrivateKey" : "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
                "Token" : "-----BEGIN PGP TOKEN-----..."
            }
        """
        
        return json.data(using: .utf8)!
    }
    
}
