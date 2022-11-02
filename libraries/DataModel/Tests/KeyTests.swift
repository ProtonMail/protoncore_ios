//
//  KeyTests.swift
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

@testable import ProtonCore_DataModel

class KeyTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKeyDecode() {
        let json = """
        {
            "ID": "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
            "Version": 3,
            "Flags": 3,
            "PrivateKey": "-----BEGIN PGP PRIVATE KEY BLOCK-----*-----END PGP PRIVATE KEY BLOCK-----",
            "Token": "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
            "Signature": null,
            "Activation": null,
            "Primary": 1,
            "Active": 1                 
        }
        """
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder.decapitalisingFirstLetter
            let object = try decoder.decode(Key.self, from: json.data(using: .utf8)!)
            XCTAssertEqual(object.keyID, "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==")
            XCTAssertEqual(object.version, 3)
            XCTAssertEqual(object.keyFlags, 3)
            XCTAssertEqual(object.privateKey, "-----BEGIN PGP PRIVATE KEY BLOCK-----*-----END PGP PRIVATE KEY BLOCK-----")
            XCTAssertEqual(object.token, "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----")
            XCTAssertEqual(object.signature, nil)
            XCTAssertEqual(object.activation, nil)
            XCTAssertEqual(object.primary, 1)
            XCTAssertEqual(object.active, 1)
            expectation.fulfill()
        } catch {
            
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testKeyDecodeMissingKeysOne() {
        let json = """
        {
            "ID": "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
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
                           keyFlags: 0,
                           token: "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                           signature: nil, activation: nil,
                           active: 1, version: 0, primary: 1,
                           isUpdated: false)
        
        XCTAssertEqual(key, object)
        
        class Test: NSObject {
            
        }
        let testObject = Test()
        XCTAssertNotEqual(key, testObject)
        XCTAssertEqual(object.keyID, "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==")
        XCTAssertEqual(object.version, 0)
        XCTAssertEqual(object.keyFlags, 0)
        XCTAssertEqual(object.token, "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----")
        XCTAssertEqual(object.signature, nil)
        XCTAssertEqual(object.activation, nil)
        XCTAssertEqual(object.primary, 1)
        XCTAssertEqual(object.active, 1)
    }
    
    func testKeyArchive() {
        let key = Key.init(keyID: "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
                           privateKey: nil,
                           keyFlags: 0,
                           token: "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                           signature: nil, activation: nil,
                           active: 1, version: 0, primary: 1,
                           isUpdated: false)
        
        let outData = [key].archive()
        let outKeys = Key.unarchive(outData)
        XCTAssertEqual([key], outKeys)
        
        let outKeys1 = Key.unarchive(nil)
        XCTAssertEqual(outKeys1, nil)
    }
    
    func testKeyVersion() {
        let key = Key.init(keyID: "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
                           privateKey: nil,
                           keyFlags: 0,
                           token: "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                           signature: "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                           activation: nil,
                           active: 1, version: 0, primary: 1,
                           isUpdated: false)
        
        XCTAssert(key.isKeyV2 == true)
        
        XCTAssert([key].isKeyV2 == true)
        
        let key2 = Key.init(keyID: "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
                           privateKey: nil,
                           keyFlags: 0,
                           token: "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
                           signature: nil,
                           activation: nil,
                           active: 1, version: 0, primary: 1,
                           isUpdated: false)
        
        XCTAssert(key2.isKeyV2 == false)
        
        XCTAssert([key2].isKeyV2 == false)
        
        XCTAssert([key2, key].isKeyV2 == true)
        
        XCTAssert([key2, key2].isKeyV2 == false)
    }
    
    func testKeyCodable() {
        let json = """
        {
            "ID": "IlnTbqicN-2HfUGIn-ki8bqZfLqNj5ErUB0z24Qx5g-4NvrrIc6GLvEpj2EPfwGDv28aKYVRRrSgEFhR_zhlkA==",
            "Token": "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
            "Signature": null,
            "Activation": null
        }
        """
        let decoder = JSONDecoder.decapitalisingFirstLetter
        let object = try! decoder.decode(Key.self, from: json.data(using: .utf8)!)
        let encoder = JSONEncoder()
        let outData = try! encoder.encode(object)
        let object2 = try! decoder.decode(Key.self, from: outData)
        XCTAssertEqual(object, object2)
        
        XCTAssertEqual(object.version, 0)
        XCTAssertEqual(object2.keyFlags, 0)
    }
    
    func testIsExternalAddressKey() {
        let testKeyExt = Key(keyID: "keyID", privateKey: nil, keyFlags: Int(KeyFlags.signupExternalKeyFlags.rawValue))
        XCTAssertTrue(testKeyExt.isExternalAddressKey)
        
        let testKeyExt2 = Key(keyID: "keyID", privateKey: nil, keyFlags: Int(KeyFlags.signifyingExternalAddress.rawValue))
        XCTAssertTrue(testKeyExt2.isExternalAddressKey)
    }
    
    func testIsNotExternalAddressKey() {
        let testKeyInt = Key(keyID: "keyID", privateKey: nil, keyFlags: Int(KeyFlags.signupKeyFlags.rawValue))
        XCTAssertFalse(testKeyInt.isExternalAddressKey)
        
        let testKeyInt2 = Key(keyID: "keyID", privateKey: nil, keyFlags: 0xffff ^ Int(KeyFlags.signifyingExternalAddress.rawValue))
        XCTAssertFalse(testKeyInt2.isExternalAddressKey)
        
        let testKeyInt3 = Key(keyID: "keyID", privateKey: nil, keyFlags: 0xffff ^ Int(KeyFlags.signupExternalKeyFlags.rawValue))
        XCTAssertFalse(testKeyInt3.isExternalAddressKey)
    }
    
    func testCannotBeUsedForEncryptingEmails() {
        let testKeyCannot = Key(keyID: "keyID", privateKey: nil, keyFlags: Int(KeyFlags.cannotEncryptEmail.rawValue))
        XCTAssertTrue(testKeyCannot.cannotEncryptEmail)
        
        let testKeyNotCannot = Key(keyID: "keyID", privateKey: nil, keyFlags: 0xffff ^ Int(KeyFlags.cannotEncryptEmail.rawValue))
        XCTAssertFalse(testKeyNotCannot.cannotEncryptEmail)
    }
    
    func testDontExpectSignedEmails() {
        let testKeyDont = Key(keyID: "keyID", privateKey: nil, keyFlags: Int(KeyFlags.dontExpectSignedEmails.rawValue))
        XCTAssertTrue(testKeyDont.dontExpectSignedEmails)
        
        let testKeyDo = Key(keyID: "keyID", privateKey: nil, keyFlags: 0xffff ^ Int(KeyFlags.dontExpectSignedEmails.rawValue))
        XCTAssertFalse(testKeyDo.dontExpectSignedEmails)
    }
}
