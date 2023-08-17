//
//  UserTests.swift
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

class UserTests: XCTestCase {

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

    func testSubscribed_ItEncodesAndDecodesProperly() throws {
        let user = User.dummy.updated(subscribed: [.mail, .drive, .vpn])

        let encoded = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: encoded)

        XCTAssertEqual(decoded.subscribed, [.drive, .mail, .vpn])
    }

    func testSubscribed_ItArchivesAndUnarchivesProperly() throws {
        let user = UserInfo.dummy
        user.subscribed = [.mail, .drive, .vpn]

        let archived = user.archive()
        let unarchived = try XCTUnwrap(UserInfo.unarchive(archived))

        XCTAssertEqual(unarchived.subscribed, [.drive, .mail, .vpn])
    }

}
