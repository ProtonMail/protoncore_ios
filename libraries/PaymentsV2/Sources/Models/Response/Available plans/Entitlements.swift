//
//  Entitlements.swift
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

public struct DescriptionEntitlement: Decodable, Equatable, Hashable, Sendable {

    public let type: String
    public let text: String
    public let iconName: String
    public let hint: String?

    public init(type: String, text: String, iconName: String, hint: String? = nil) {
        self.type = type
        self.text = text
        self.iconName = iconName
        self.hint = hint
    }
}

public struct ProgressEntitlement: Decodable, Equatable, Hashable, Sendable {

    public let title: String
    public let type: String
    public let text: String
    public let min: Int
    public let max: Int
    public let current: Int
    public let iconName: String?

    public init(title: String, type: String, text: String, min: Int, max: Int, current: Int, iconName: String? = nil) {
        self.title = title
        self.type = type
        self.text = text
        self.min = min
        self.max = max
        self.current = current
        self.iconName = iconName
    }
}

public enum EntitlementType: String, Decodable, Equatable, Sendable {
    case description
    case progress
}

public enum Entitlement: Decodable, Equatable, Hashable, Sendable {

    case progress(ProgressEntitlement)
    case description(DescriptionEntitlement)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EntitlementType.self, forKey: .type)

        let singleContainer = try decoder.singleValueContainer()

        switch type {
        case .progress:
            self = .progress(try singleContainer.decode(ProgressEntitlement.self))
        case .description:
            self = .description(try singleContainer.decode(DescriptionEntitlement.self))
        }
    }
}
