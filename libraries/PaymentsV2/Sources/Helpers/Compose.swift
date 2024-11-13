//
//  Compose.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

@dynamicMemberLookup
public struct Compose<Element1, Element2> {

    var element1: Element1
    var element2: Element2
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Element1, T>) -> T {
        get { element1[keyPath: keyPath] }
        set { element1[keyPath: keyPath] = newValue }
    }
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Element2, T>) -> T {
        get { element2[keyPath: keyPath] }
        set { element2[keyPath: keyPath] = newValue }
    }
    init(_ element1: Element1, _ element2: Element2) {
        self.element1 = element1
        self.element2 = element2
    }
}

extension Compose: DictionaryConvertible where Element1: DictionaryConvertible, Element2: DictionaryConvertible {

    internal func toDictionary() -> [String: Any] {
        element1.toDictionary().merging(element2.toDictionary()) { (_, new) in new }
    }
}

extension Compose: Encodable where Element1: Encodable, Element2: Encodable {
    public func encode(to encoder: Encoder) throws {
        try element1.encode(to: encoder)
        try element2.encode(to: encoder)
    }
}
extension Compose: Decodable where Element1: Decodable, Element2: Decodable {
    public init(from decoder: Decoder) throws {
        self.element1 = try Element1(from: decoder)
        self.element2 = try Element2(from: decoder)
    }
}
