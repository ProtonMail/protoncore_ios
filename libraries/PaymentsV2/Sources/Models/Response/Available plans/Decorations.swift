//
//  Decorations.swift
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

public struct StarredDecoration: Decodable, Equatable, Hashable {

    public let type: String
    public let iconName: String

    public init(type: String, iconName: String) {
        self.type = type
        self.iconName = iconName
    }
}

public struct BadgeDecoration: Decodable, Equatable, Hashable {

    public let type: String
    public let text: String
    public let anchor: String
    public let planId: String?

    public init(type: String, text: String, anchor: String, planId: String?) {
        self.type = type
        self.text = text
        self.anchor = anchor
        self.planId = planId
    }
}

public enum DecorationType: String, Decodable, Equatable, Hashable {

    case starred
    case badge
}

public enum Decoration: Decodable, Equatable, Hashable {

    case starred(StarredDecoration)
    case badge(BadgeDecoration)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(DecorationType.self, forKey: .type)

        let singleContainer = try decoder.singleValueContainer()

        switch type {
        case .starred:
            self = .starred(try singleContainer.decode(StarredDecoration.self))
        case .badge:
            self = .badge(try singleContainer.decode(BadgeDecoration.self))
        }
    }
}
