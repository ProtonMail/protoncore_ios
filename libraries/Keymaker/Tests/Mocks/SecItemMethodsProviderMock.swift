//
//  KeychainMock.swift
//  ProtonCore-Keymaker-Tests - Created on 14/09/2023.
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

import Foundation
import ProtonCoreKeymaker
import ProtonCoreTestingToolkitUnitTestsCore

public final class SecItemMethodsProviderMock: SecItemMethodsProvider {

    @FuncStub(SecItemMethodsProviderMock.SecItemCopyMatching, initialReturn: .crash) public var SecItemCopyMatchingStub
    public func SecItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        SecItemCopyMatchingStub(query, result)
    }

    @FuncStub(SecItemMethodsProviderMock.SecItemAdd, initialReturn: .crash) public var SecItemAddStub
    public func SecItemAdd(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        SecItemAddStub(attributes, result)
    }

    @FuncStub(SecItemMethodsProviderMock.SecItemUpdate, initialReturn: .crash) public var SecItemUpdateStub
    public func SecItemUpdate(_ query: CFDictionary, _ attributesToUpdate: CFDictionary) -> OSStatus {
        SecItemUpdateStub(query, attributesToUpdate)
    }

    @FuncStub(SecItemMethodsProviderMock.SecItemDelete, initialReturn: .crash) public var SecItemDeleteStub
    public func SecItemDelete(_ query: CFDictionary) -> OSStatus {
        SecItemDeleteStub(query)
    }
}
