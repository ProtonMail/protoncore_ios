//
//  KeymakerTests.swift
//  ProtonCore-Keymaker-Tests - Created on 4/05/2022.
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
import ProtonCoreKeymaker

final class KeychainTests: XCTestCase {
    
    private var provider: SecItemMethodsProviderMock!
    private var out: Keychain!
    
    override func setUp() {
        provider = SecItemMethodsProviderMock()
        out = Keychain(service: "test.service", accessGroup: "test.access.group", secItemMethodsProvider: provider)
    }
    
    // MARK: - Read
    
    func testKeychainPassesDataIfFound() throws {
        // given
        let data: NSData = Data(repeating: 1, count: 100) as NSData
        provider.SecItemCopyMatchingStub.bodyIs { _, _, result in
            result?.pointee = data
            return noErr
        }
        
        // when
        let result = try XCTUnwrap(try out.dataOrError(forKey: "any.key"))
        
        // then
        XCTAssertEqual(result, data as Data)
    }
    
    func testKeychainPassesNilIfNotFound() throws {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in errSecItemNotFound }
        
        // when
        let result = try out.dataOrError(forKey: "any.key")
        
        // then
        XCTAssertNil(result)
    }

    func testKeychainPassesDataReadError() {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.dataOrError(forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.readFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
    
    func testKeychainPassesStringReadError() {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.stringOrError(forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.readFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
    
    // MARK: - Write
    
    func testKeychainReturnsWhenAddingSucceeds() throws {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in errSecItemNotFound }
        provider.SecItemAddStub.bodyIs { _, _, _ in noErr }
        
        // when
        try out.setOrError(Data(), forKey: "any.key")
    }
    
    func testKeychainPassesDataWriteErrorWhenAddingFails() {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in errSecItemNotFound }
        provider.SecItemAddStub.bodyIs { _, _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.setOrError(Data(), forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.writeFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
    
    func testKeychainPassesStringWriteErrorWhenAddingFails() {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in errSecItemNotFound }
        provider.SecItemAddStub.bodyIs { _, _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.setOrError(String(), forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.writeFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
    
    // MARK: - Update
    
    func testKeychainReturnsWhenUpdatingSucceeds() throws {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in noErr }
        provider.SecItemUpdateStub.bodyIs { _, _, _ in noErr }
        
        // when
        try out.setOrError(Data(), forKey: "any.key")
    }
    
    func testKeychainPassesDataWriteErrorWhenUpdatingFails() {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in noErr }
        provider.SecItemUpdateStub.bodyIs { _, _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.setOrError(Data(), forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.updateFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
    
    func testKeychainPassesStringWriteErrorWhenUpdatingFails() {
        // given
        provider.SecItemCopyMatchingStub.bodyIs { _, _, _ in noErr }
        provider.SecItemUpdateStub.bodyIs { _, _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.setOrError(String(), forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.updateFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
    
    // MARK: - Delete
    
    func testKeychainReturnsIfDeletingSucceeds() throws {
        // given
        provider.SecItemDeleteStub.bodyIs { _, _ in noErr }
        
        // when
        try out.removeOrError(forKey: "any.key")
    }
    
    func testKeychainPassesRemoveError() {
        // given
        provider.SecItemDeleteStub.bodyIs { _, _ in errSecInteractionNotAllowed }
        
        // when
        XCTAssertThrowsError(try out.removeOrError(forKey: "any.key")) { error in
            
            // then
            guard case let Keychain.AccessError.deleteFailed(key, errorCode) = error else { XCTFail(); return }
            XCTAssertEqual(key, "any.key")
            XCTAssertEqual(errorCode, errSecInteractionNotAllowed)
        }
    }
}
