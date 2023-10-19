//
//  AddressTests.swift
//  ProtonCore-DataModel-Tests - Created on 4/19/21.
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

@testable import ProtonCoreDataModel

class AddressTests: XCTestCase {
    
    func testAddressesDecode() {
        let json = """
        [
         {
             "ID": "qmhrlFYb8h3JhOOykKv8ZsuTH8X_SrUZSg==",
             "DomainID": "l8vWAXHBQmv0u730_BCxj1X0nW70HQRmAa-rIvzmKUA==",
             "Email": "lu@protonmail.dev",
             "Send": 1,
             "Receive": 1,
             "Status": 1,
             "Type": 1,
             "Order": 1,
             "DisplayName": "test name",
             "Signature": "hi there",
             "HasKeys": 1,
             "Keys": [
                 {
                     "ID": "IlnTbqicN-2HfUGIn-ki8aKYVRRrSgEFhR_zhlkA==",
                     "Version": 3,
                     "Flags": 3,
                     "PrivateKey": "-----BEGIN PGP PRIVATE KEY BLOCK-----*-----END PGP PRIVATE KEY BLOCK-----",
                     "Token": "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                     "Signature": null,
                     "Activation": null,
                     "Primary": 1,
                     "Active": 1
                 }
             ]
         },
         {
             "ID": "_pm5NXefHCdfqhTWHWAETz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtPbcW70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 1,
             "Receive": 0,
             "Status": 0,
             "Type": 2,
             "Order": 2,
             "DisplayName": "hi",
             "Signature": "hi there",
             "HasKeys": 0,
             "Keys": []
         },
         {
             "ID": "_pm5NXefHCdfqhTWHWAETz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtPbcW70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 1,
             "Receive": 0,
             "Status": 0,
             "Type": 2,
             "Order": 2,
         }
        ]
        """
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder.decapitalisingFirstLetter
            let object = try decoder.decode([Address].self, from: json.data(using: .utf8)!)
            XCTAssertTrue(object.count == 3)
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testKeyDecodeMissingKeys() {
        let json = """
        {
            "ID": "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
            "Version": 3,
            "Flags": 3,
            "Token": "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
            "Signature": null,
            "Activation": null,
            "Primary": 1,
            "Active": 1
        }
        """
        let decoder = JSONDecoder.decapitalisingFirstLetter
        let object = try! decoder.decode(Key.self, from: json.data(using: .utf8)!)
        let key = Key.init(keyID: "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
                           privateKey: nil,
                           keyFlags: 3,
                           token: "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                           signature: nil, activation: nil,
                           active: 1, version: 3, primary: 1,
                           isUpdated: false)
        XCTAssertEqual(key, object)
        XCTAssertEqual(object.keyID, "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==")
        XCTAssertEqual(object.version, 3)
        XCTAssertEqual(object.keyFlags, 3)
        XCTAssertEqual(object.token, "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----")
        XCTAssertEqual(object.signature, nil)
        XCTAssertEqual(object.activation, nil)
        XCTAssertEqual(object.primary, 1)
        XCTAssertEqual(object.active, 1)
    }
    
    func testAddressArchive() {
        let json = """
        {
            "ID": "qmhrlFYb8h3JhOOykKv8ZsuTH8X_SrUZSg==",
            "DomainID": "l8vWAXHBQmv0u730_BCxj1X0nW70HQRmAa-rIvzmKUA==",
            "Email": "lu@protonmail.dev",
            "Send": 1,
            "Receive": 1,
            "Status": 1,
            "Type": 1,
            "Order": 1,
            "DisplayName": "test name",
            "Signature": "hi there",
            "HasKeys": 1,
            "Keys": [
                {
                    "ID": "IlnTbqicN-2HfUGIn-ki8aKYVRRrSgEFhR_zhlkA==",
                    "Version": 3,
                    "Flags": 3,
                    "PrivateKey": "-----BEGIN PGP PRIVATE KEY BLOCK-----*-----END PGP PRIVATE KEY BLOCK-----",
                    "Token": "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                    "Signature": null,
                    "Activation": null,
                    "Primary": 1,
                    "Active": 1
                }
            ]
        }
        """
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder.decapitalisingFirstLetter
            let object = try decoder.decode(Address.self, from: json.data(using: .utf8)!)
            XCTAssertNotNil(object)
            
            let outData = object.archive()
            let outKey = Address.unarchive(outData)
            XCTAssertEqual(object, outKey)
            
            let outKey1 = Address.unarchive(nil)
            XCTAssertEqual(outKey1, nil)
            
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
    }
    
    func testConvertFirstAddressToAddress_v2() {
        let address = Address(
            addressID: "<test_address_id_1>",
            domainID: "<test_domain_id_1>",
            email: "test_1@proton.me",
            send: .active,
            receive: .active,
            status: .enabled,
            type: .protonDomain,
            order: 1,
            displayName: "<test_user_1>",
            signature: "<test_signature_1>",
            hasKeys: 1,
            keys: [
                .init(
                    keyID: "<test_key_id_1>",
                    privateKey: "<test_private_key_1>",
                    keyFlags: 1,
                    token: "<test_token_1>",
                    signature: nil,
                    activation: nil,
                    active: 1,
                    version: 99,
                    primary: 1,
                    isUpdated: false
                )
            ]
        )
        
        XCTAssertEqual(address.toAddress_v2, .init(
            id: "<test_address_id_1>",
            domainID: "<test_domain_id_1>",
            email: "test_1@proton.me",
            send: true,
            receive: true,
            status: .enabled,
            type: .protonDomain,
            order: 1,
            displayName: "<test_user_1>",
            signature: "<test_signature_1>",
            keys: [
                .init(
                    id: "<test_key_id_1>",
                    version: 99,
                    privateKey: "<test_private_key_1>",
                    token: "<test_token_1>",
                    signature: nil,
                    primary: true,
                    active: true,
                    flags: .verifySignatures
                )
            ])
        )
    }
    
    func testConvertSecondAddressToAddress_v2() {
        let address = Address(
            addressID: "<test_address_id_2>",
            domainID: "<test_domain_id_2>",
            email: "test_2@proton.me",
            send: .inactive,
            receive: .inactive,
            status: .disabled,
            type: .externalAddress,
            order: 3,
            displayName: "<test_user_2>",
            signature: "<test_signature_2>",
            hasKeys: 0,
            keys: [
                .init(
                    keyID: "<test_key_id_2>",
                    privateKey: nil,
                    keyFlags: 3,
                    token: nil,
                    signature: nil,
                    activation: nil,
                    active: 0,
                    version: 13,
                    primary: 0,
                    isUpdated: false
                )
            ]
        )
        
        XCTAssertEqual(address.toAddress_v2, .init(
            id: "<test_address_id_2>",
            domainID: "<test_domain_id_2>",
            email: "test_2@proton.me",
            send: false,
            receive: false,
            status: .disabled,
            type: .externalDomain,
            order: 3,
            displayName: "<test_user_2>",
            signature: "<test_signature_2>",
            keys: [
                .init(
                    id: "<test_key_id_2>",
                    version: 13,
                    privateKey: "",
                    token: nil,
                    signature: nil,
                    primary: false,
                    active: false,
                    flags: [.verifySignatures, .encryptNewData]
                )
            ])
        )
    }

}
