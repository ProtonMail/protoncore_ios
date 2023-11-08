//
//  KeychainTests.swift
//  ProtonCore-ProtonCore-Keymaker - Created on 08/07/2019.
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

@testable import ProtonCoreKeymaker

#if !targetEnvironment(simulator)
class KeychainTests: XCTestCase {

    /*
     These tests can only run with signed binary on a device, switch them on when CI will be capable of that
     Check https://developer.apple.com/documentation/security/errsecmissingentitlement for details

     */

    let keychain = Keychain(service: "ch.protonmail", accessGroup: "2SB5Z68H26.ch.protonmail.PMKeymaker")

    override func setUp() {
        super.setUp()
        keychain.removeEverything()
    }

    func testAddNew() {
        let data = #function.data(using: .utf8)!
        let key = #function

        // check value does not appear in the keychain
        let presentsBeforeSaving = keychain.getData(forKey: key)
        XCTAssertNil(presentsBeforeSaving)

        // save
        let savedSuccessfully = keychain.add(data: data, forKey: key)
        XCTAssertTrue(savedSuccessfully)

        // verify saved
        let presentsAfterSaving = keychain.getData(forKey: key)
        XCTAssertEqual(data, presentsAfterSaving)
    }

    func testUpdate() {
        let dataOld = (#function + "old").data(using: .utf8)!
        let dataUpdated = (#function + "new").data(using: .utf8)!
        let key = #function

        // check value does not appear in the keychain
        let presentsBeforeSaving = keychain.getData(forKey: key)
        XCTAssertNil(presentsBeforeSaving)

        // save
        let savedSuccessfully = keychain.add(data: dataOld, forKey: key)
        XCTAssertTrue(savedSuccessfully)

        // verify saved
        let presentsAfterSaving = keychain.getData(forKey: key)
        XCTAssertEqual(dataOld, presentsAfterSaving)

        // save
        let updatedSuccessfully = keychain.add(data: dataUpdated, forKey: key)
        XCTAssertTrue(updatedSuccessfully)

        // verify saved
        let presentsAfterUpdating = keychain.getData(forKey: key)
        XCTAssertEqual(dataUpdated, presentsAfterUpdating)
    }

    func testRemove() {
        let data = #function.data(using: .utf8)!
        let key = #function

        // check value does not appear in the keychain
        let presentsBeforeSaving = keychain.getData(forKey: key)
        XCTAssertNil(presentsBeforeSaving)

        // save
        let savedSuccessfully = keychain.add(data: data, forKey: key)
        XCTAssertTrue(savedSuccessfully)

        // verify saved
        let presentsAfterSaving = keychain.getData(forKey: key)
        XCTAssertEqual(data, presentsAfterSaving)

        let removed = keychain.remove(key)
        XCTAssertTrue(removed)

        // verify saved
        let presentsAfterRemoving = keychain.getData(forKey: key)
        XCTAssertNil(presentsAfterRemoving)
    }

    func testThreadSafety() {
        let sut = Keychain(service: "ch.protonmail", accessGroup: "2SB5Z68H26.me.proton.account.SharedItems")
        let dispatchGroup = DispatchGroup()
        let expectation = expectation(description: "multithreading")

        for i in 0..<250 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                sut.set("value \(i)".data(using: .utf8)!, forKey: "always the same key")
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

}
#endif
