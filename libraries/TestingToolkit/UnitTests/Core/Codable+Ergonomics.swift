//
//  Codable+Ergonomics.swift
//  ProtonCore-TestingToolkit - Created on 08/09/2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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

public extension Encodable {
    var toJsonDict: [String: Any] {
        try! JSONSerialization.jsonObject(with: JSONEncoder().encode(self)) as! [String: Any]
    }

    var toSuccessfulResponse: [String: Any] {
        var result = try! JSONSerialization.jsonObject(with: JSONEncoder().encode(self)) as! [String: Any]
        result["Code"] = 1000
        return result
    }

    func toSuccessfulResponse(underKey key: String) -> [String: Any] {
        var result: [String: Any] = [:]
        result[key] = try! JSONSerialization.jsonObject(with: JSONEncoder().encode(self))
        result["Code"] = 1000
        return result
    }
}

public extension Decodable {
    func from(_ dict: [String: Any]?) -> Self {
        try! JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dict!))
    }
}
