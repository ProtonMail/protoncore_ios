//
//  Encodable+Extensions.swift
//  ProtonCore-PaymentsV2 - Created on 17/04/2026.
//
//  Copyright (c) 2026 Proton Technologies AG
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

private enum EncodableDictionaryError: Error {
    /// Casting from the encoded JSON object to a `Dictionary` failed.
    case castFailed
}

extension Encodable {

    /// Maps an `Encodable` object to an `Any` dictionary. This is achieved through first encoding the object as JSON, serializing it as a JSON object and
    /// then finally attempting a direct cast to a dictionary.
    ///
    /// - Returns: A dictionary representation of the encoded `self` object.
    /// - Throws: `EncodingError` if the object cannot be encoded, or `EncodableDictionaryError.castFailed` if the resulting object fails
    ///   casting to a `Dictionary`.
    func dictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let dictionary = object as? [String: Any] else {
            throw EncodableDictionaryError.castFailed
        }

        return dictionary
    }
}
