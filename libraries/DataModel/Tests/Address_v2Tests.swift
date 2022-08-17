//
//  Address_v2Tests.swift
//  ProtonCore-DataModel-Tests - Created on 25.04.22.
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

class Address_v2Tests: XCTestCase {
    
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        jsonDecoder = .init()
    }
    
    override func tearDown() {
        jsonDecoder = nil
        super.tearDown()
    }
    
    func testParseTwoAddressesCorrectly() throws {
        let sut = try jsonDecoder.decode([Address_v2].self, from: .addressesJSONData)
        
        XCTAssertEqual(sut.count, 2)
        
        let firstAddress = try XCTUnwrap(sut[safe: 0])
        let secondAddress = try XCTUnwrap(sut[safe: 1])

        XCTAssertEqual(firstAddress, .init(
            id: "rgNKdmwCTyrr4_VfSnR7PgaM6QS8qcCKe2IyYASIYRh0cM2LfuGqr-9pO7aQlGWyVvd1rNuzn6Q3KK4suY9pgw==",
            domainID: "l8vWAXHBQmv0u7OVtPbcqMa4iwQaBqowINSQjPrxAr-Da8fVPKUkUcqAq30_BCxj1X0nW70HQRmAa-rIvzmKUA==",
            email: "mszklarek@proton.black",
            send: true,
            receive: true,
            status: .enabled,
            type: .protonDomain,
            order: 1,
            displayName: "mszklarek DN",
            signature: "<test_signature>",
            keys: [
                .init(
                    id: "po3wnqUjlYZ4L7N02HUq7eqC2nmrbUBWsGuqbA_0IUv5crXeMJyCuVHwxwfIOkCpyxKwHt_3giLkVXF_uZ0zKQ==",
                    version: 3,
                    privateKey: "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
                    token: "-----BEGIN PGP TOKEN-----...",
                    signature: "-----BEGIN PGP SIGNATURE-----...",
                    primary: true,
                    active: true,
                    flags: [.verifySignatures, .encryptNewData]
                )
            ]
        ))
        XCTAssertEqual(secondAddress, .init(
            id: "iF156hGSDnwLVZyh-Aef-byx7I-TG2r4onIKP-npkiLFHl3BiuXf2tr1Js8CQYhSD9nofmhL81Frr-J1_wRs4Q==",
            domainID: "ZvYvWcm9BAgxbTi5g4De95rCt4zW96IHNlC-cIvM7guz5jVp-797Wq90f5H_6fDCqNijs-C9pDxD_YAdUS2qtg==",
            email: "ddddd@whisperstone.ch",
            send: false,
            receive: false,
            status: .disabled,
            type: .customDomain,
            order: 2,
            displayName: "",
            signature: "",
            keys: [
                .init(
                    id: "2ramn-Fpb6DN5CUcAJpfqeC8CIykNZw6wHhDSBCRXwzBqMNtOag02s2HLdZjrjgiD4lciFNEBo-DwgQ6v4x4vA==",
                    version: 2,
                    privateKey: "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
                    token: "-----BEGIN PGP TOKEN-----...",
                    signature: "-----BEGIN PGP SIGNATURE-----...",
                    primary: true,
                    active: true,
                    flags: .verifySignatures
                )
            ]
        ))
    }
    
    func testParseAddressWithStatus0_ItHasDisabledStatus() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(status: 0))
        
        XCTAssertEqual(sut.status, .disabled)
    }
    
    func testParseAddressWithStatus1_ItHasEnabledStatus() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(status: 1))
        
        XCTAssertEqual(sut.status, .enabled)
    }
    
    func testParseAddressWithStatus2_ItHasDeletingStatus() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(status: 2))
        
        XCTAssertEqual(sut.status, .deleting)
    }
    
    func testParseAddressWithStatus3_ItThrowsDecodingError() throws {
        XCTAssertThrowsError(try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(status: 3)))
    }
    
    func testParseAddressWithType1_ItHasProtonDomainType() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(type: 1))
        
        XCTAssertEqual(sut.type, .protonDomain)
    }
    
    func testParseAddressWithType2_ItHasProtonAliasType() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(type: 2))
        
        XCTAssertEqual(sut.type, .protonAlias)
    }
    
    func testParseAddressWithType3_ItHasCustomDomainType() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(type: 3))
        
        XCTAssertEqual(sut.type, .customDomain)
    }
    
    func testParseAddressWithType4_ItHasPremiumDomainType() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(type: 4))
        
        XCTAssertEqual(sut.type, .premiumDomain)
    }
    
    func testParseAddressWithType5_ItHasExternalDomainType() throws {
        let sut = try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(type: 5))
        
        XCTAssertEqual(sut.type, .externalDomain)
    }
    
    func testParseAddressWithType0_ItThrowsDecodingError() throws {
        XCTAssertThrowsError(try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(type: 0)))
    }
    
    func testParseAddressWithSend99_ItThrowsDecodingError() throws {
        XCTAssertThrowsError(try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(send: 99))) { error in
            assertDecodingError(
                error: error,
                codingKey: Address_v2.CodingKeys.send.rawValue,
                debugDescription: "Expected to receive `0` or `1` but found `99` instead."
            )
        }
    }
    
    func testParseAddressWithReceive5_ItThrowsDecodingError() throws {
        XCTAssertThrowsError(try jsonDecoder.decode(Address_v2.self, from: .addressJSONData(receive: 5))) { error in
            assertDecodingError(
                error: error,
                codingKey: Address_v2.CodingKeys.receive.rawValue,
                debugDescription: "Expected to receive `0` or `1` but found `5` instead."
            )
        }
    }
    
    func testKeyFlags() {
        
        XCTAssertTrue(KeyFlags.signupKeyFlags.rawValue == 3)
        XCTAssertTrue(KeyFlags.verifySignatures.rawValue == 1)
        XCTAssertTrue(KeyFlags.encryptNewData.rawValue == 2)
        XCTAssertTrue(KeyFlags.belongsToExternalAddress.rawValue == 4)
        XCTAssertTrue(KeyFlags.all.rawValue == 7)
    }
    
}

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

private extension Data {
    
    static func addressJSONData(
        send: Int = 1,
        receive: Int = 1,
        status: Int = 0,
        type: Int = 1
    ) -> Self {
        let json = """
            {
                "DisplayName" : "mszklarek DN",
                "ConfirmationState" : 1,
                "Receive" : \(receive),
                "Email" : "mszklarek@proton.black",
                "SignedKeyList" : {
                    "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                    "MaxEpochID" : 100,
                    "ExpectedMinEpochID" : null,
                    "MinEpochID" : 54
                },
                "ID" : "rgNKdmwCTyrr4_VfSnR7PgaM6QS8qcCKe2IyYASIYRh0cM2LfuGqr-9pO7aQlGWyVvd1rNuzn6Q3KK4suY9pgw==",
                "Send" : \(send),
                "Priority" : 1,
                "Keys" : [
                    {
                        "Fingerprints" : [
                            "ce8b1560eee758c0fda68f1fe428f05b3b9735c0",
                            "fd30367d8543ab3130b90bfe45a929920fdadab4"
                        ],
                        "Active" : 1,
                        "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                        "Flags" : 3,
                        "ID" : "po3wnqUjlYZ4L7N02HUq7eqC2nmrbUBWsGuqbA_0IUv5crXeMJyCuVHwxwfIOkCpyxKwHt_3giLkVXF_uZ0zKQ==",
                        "Version" : 3,
                        "PublicKey" : "-----BEGIN PGP PUBLIC KEY BLOCK-----...",
                        "Primary" : 1,
                        "Activation" : null,
                        "Fingerprint" : "ce8b1560eee758c0fda68f1fe428f05b3b9735c0",
                        "PrivateKey" : "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
                        "Token" : "-----BEGIN PGP TOKEN-----..."
                    }
                ],
                "Status" : \(status),
                "Type" : \(type),
                "Order" : 1,
                "Signature" : "<test_signature>",
                "DomainID" : "l8vWAXHBQmv0u7OVtPbcqMa4iwQaBqowINSQjPrxAr-Da8fVPKUkUcqAq30_BCxj1X0nW70HQRmAa-rIvzmKUA==",
                "HasKeys" : 1
            }
        """
        
        return json.data(using: .utf8)!
    }

    static var addressesJSONData: Self {
        let json = """
            [
                {
                    "DisplayName" : "mszklarek DN",
                    "ConfirmationState" : 1,
                    "Receive" : 1,
                    "Email" : "mszklarek@proton.black",
                    "SignedKeyList" : {
                        "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                        "MaxEpochID" : 100,
                        "ExpectedMinEpochID" : null,
                        "MinEpochID" : 54
                    },
                    "ID" : "rgNKdmwCTyrr4_VfSnR7PgaM6QS8qcCKe2IyYASIYRh0cM2LfuGqr-9pO7aQlGWyVvd1rNuzn6Q3KK4suY9pgw==",
                    "Send" : 1,
                    "Priority" : 1,
                    "Keys" : [
                        {
                            "Fingerprints" : [
                                "ce8b1560eee758c0fda68f1fe428f05b3b9735c0",
                                "fd30367d8543ab3130b90bfe45a929920fdadab4"
                            ],
                            "Active" : 1,
                            "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                            "Flags" : 3,
                            "ID" : "po3wnqUjlYZ4L7N02HUq7eqC2nmrbUBWsGuqbA_0IUv5crXeMJyCuVHwxwfIOkCpyxKwHt_3giLkVXF_uZ0zKQ==",
                            "Version" : 3,
                            "PublicKey" : "-----BEGIN PGP PUBLIC KEY BLOCK-----...",
                            "Primary" : 1,
                            "Activation" : null,
                            "Fingerprint" : "ce8b1560eee758c0fda68f1fe428f05b3b9735c0",
                            "PrivateKey" : "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
                            "Token" : "-----BEGIN PGP TOKEN-----..."
                        }
                    ],
                    "Status" : 1,
                    "Type" : 1,
                    "Order" : 1,
                    "Signature" : "<test_signature>",
                    "DomainID" : "l8vWAXHBQmv0u7OVtPbcqMa4iwQaBqowINSQjPrxAr-Da8fVPKUkUcqAq30_BCxj1X0nW70HQRmAa-rIvzmKUA==",
                    "HasKeys" : 1
                },
                {
                    "DisplayName" : "",
                    "ConfirmationState" : 1,
                    "Receive" : 0,
                    "Email" : "ddddd@whisperstone.ch",
                    "SignedKeyList" : {
                        "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                        "MaxEpochID" : null,
                        "ExpectedMinEpochID" : 101,
                        "MinEpochID" : null
                    },
                    "ID" : "iF156hGSDnwLVZyh-Aef-byx7I-TG2r4onIKP-npkiLFHl3BiuXf2tr1Js8CQYhSD9nofmhL81Frr-J1_wRs4Q==",
                    "Send" : 0,
                    "Priority" : 2,
                    "Keys" : [
                        {
                            "Fingerprints" : [
                                "2328f825b6be31e2566e21fe924f0b1f85f68143",
                                "899315cba137be10ea1911b4dfbc4aa789d30384"
                            ],
                            "Active" : 1,
                            "Signature" : "-----BEGIN PGP SIGNATURE-----...",
                            "Flags" : 1,
                            "ID" : "2ramn-Fpb6DN5CUcAJpfqeC8CIykNZw6wHhDSBCRXwzBqMNtOag02s2HLdZjrjgiD4lciFNEBo-DwgQ6v4x4vA==",
                            "Version" : 2,
                            "PublicKey" : "-----BEGIN PGP PUBLIC KEY BLOCK-----...",
                            "Primary" : 1,
                            "Activation" : null,
                            "Fingerprint" : "2328f825b6be31e2566e21fe924f0b1f85f68143",
                            "PrivateKey" : "-----BEGIN PGP PRIVATE KEY BLOCK-----...",
                            "Token" : "-----BEGIN PGP TOKEN-----..."
                        }
                    ],
                    "Status" : 0,
                    "Type" : 3,
                    "Order" : 2,
                    "Signature" : "",
                    "DomainID" : "ZvYvWcm9BAgxbTi5g4De95rCt4zW96IHNlC-cIvM7guz5jVp-797Wq90f5H_6fDCqNijs-C9pDxD_YAdUS2qtg==",
                    "HasKeys" : 1
                }
            ]
        """

        return json.data(using: .utf8)!
    }

}
