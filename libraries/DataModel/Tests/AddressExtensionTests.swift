//
//  AddressExtensionsTests.swift
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

class AddressExtensionsTests: XCTestCase {
    
    private var interfaceJson: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override func setUp() {
        super.setUp()
        self.interfaceJson = """
        [
         {
             "ID": "_pm5NXefHCdTz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtP70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 0,
             "Receive": 0,
             "Status": 0,
             "Type": 2,
             "Order": 0,
             "DisplayName": "hi",
             "Signature": "hi there",
             "HasKeys": 0,
                "Keys": [
                  {
                      "ID": "IlnTbqicN-2HfUGIFhR_zhlkA==",
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
             "Order": 1,
             "DisplayName": "hi",
             "Signature": "hi there",
             "HasKeys": 0,
             "Keys": []
         },
         {
             "ID": "_pm5NXefHCdfqhTWHWAETz-WDjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtPbcW70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 0,
             "Receive": 0,
             "Status": 0,
             "Type": 2,
             "Order": 2,
         },
         {
             "ID": "qmhrlFYb8h3JhOOykKv8Zs11uTH8X_SrUZSg==",
             "DomainID": "l8vWAXHBQmv0u730_BCxj1X0nW70HQRmAa-rIvzmKUA==",
             "Email": "lu@protonmail.dev",
             "Send": 1,
             "Receive": 1,
             "Status": 1,
             "Type": 1,
             "Order": 3,
             "DisplayName": "test name",
             "Signature": "hi there",
             "HasKeys": 1,
             "Keys": []
         }
        ]
        """
    }
    
    func testGetDefaultAddressFound() {
        let json = """
        [
         {
             "ID": "_pm5NXefHCdTz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtP70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 0,
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
             "DisplayName": "hi",
             "Signature": "hi there",
             "HasKeys": 0,
             "Keys": []
         },
         {
             "ID": "_pm5NXefHCdfqhTWHWAETz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtPbcW70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 0,
             "Receive": 0,
             "Status": 0,
             "Type": 2,
             "Order": 2,
         },
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
             "Keys": []
         }
        ]
        """
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .decapitaliseFirstLetter
            let object = try decoder.decode([Address].self, from: json.data(using: .utf8)!)
            XCTAssertTrue(object.count == 4)
            let found = object.defaultAddress()
            XCTAssertNotNil(found)
            XCTAssertEqual(found!.addressID, "qmhrlFYb8h3JhOOykKv8ZsuTH8X_SrUZSg==")
            
            let foundSend = object.defaultSendAddress()
            XCTAssertNotNil(foundSend)
            XCTAssertEqual(foundSend!.addressID, "qmhrlFYb8h3JhOOykKv8ZsuTH8X_SrUZSg==")
            
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testGetDefaultAddressNil() {
        let json = """
        [
         {
             "ID": "_pm5NXefHCdTz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtP70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 0,
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
             "DisplayName": "hi",
             "Signature": "hi there",
             "HasKeys": 0,
             "Keys": []
         },
         {
             "ID": "_pm5NXefHCdfqhTWHWAETz-WDqjLDRXNWftciXw==",
             "DomainID": "l8vWAXHBQmv0u7OVtPbcW70HQRmAa-rIvzmKUA==",
             "Email": "hi@protonmail.dev",
             "Send": 0,
             "Receive": 0,
             "Status": 0,
             "Type": 2,
             "Order": 2,
         }
        ]
        """
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .decapitaliseFirstLetter
            let object = try decoder.decode([Address].self, from: json.data(using: .utf8)!)
            XCTAssertTrue(object.count == 3)
            let found = object.defaultAddress()
            XCTAssertNil(found)
            let foundSend = object.defaultSendAddress()
            XCTAssertNil(foundSend)
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testLookupAddressByID() {
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .decapitaliseFirstLetter
            let objects = try decoder.decode([Address].self, from: self.interfaceJson.data(using: .utf8)!)
            XCTAssertTrue(objects.count == 4)
            let found = objects.address(byID: "qmhrlFYb8h3JhOOykKv8Zs11uTH8X_SrUZSg==")
            XCTAssertNotNil(found)
            
            let notFound = objects.address(byID: "UZSg==")
            XCTAssertNil(notFound)
            
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testGetAddressOrder() {
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .decapitaliseFirstLetter
            let objects = try decoder.decode([Address].self, from: self.interfaceJson.data(using: .utf8)!)
            XCTAssertTrue(objects.count == 4)
            let order = objects.getAddressOrder()
            XCTAssertEqual(order, ["_pm5NXefHCdTz-WDqjLDRXNWftciXw==",
                                   "_pm5NXefHCdfqhTWHWAETz-WDqjLDRXNWftciXw==",
                                   "_pm5NXefHCdfqhTWHWAETz-WDjLDRXNWftciXw==",
                                   "qmhrlFYb8h3JhOOykKv8Zs11uTH8X_SrUZSg=="])
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testGetOrderInt() {
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .decapitaliseFirstLetter
            let objects = try decoder.decode([Address].self, from: self.interfaceJson.data(using: .utf8)!)
            XCTAssertTrue(objects.count == 4)
            let order = objects.getAddressNewOrder()
            XCTAssertEqual(order, [0, 1, 2, 3])
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testToKeys() {
        
        let expectation = self.expectation(description: "Success completion block called")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .decapitaliseFirstLetter
            let objects = try decoder.decode([Address].self, from: self.interfaceJson.data(using: .utf8)!)
            XCTAssertTrue(objects.count == 4)
            let keys = objects.toKeys()
            XCTAssertTrue(keys.count == 1)
            expectation.fulfill()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
