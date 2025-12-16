//
//  AvailablePlans.swift
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

public struct AvailablePlans: Decodable, Hashable, Sendable {
    public let code: Int
    public let plans: [AvailablePlan]
    public let defaultCycle: Int
}

public struct AvailablePlan: Decodable, Hashable, Sendable {
    public let description: String
    public let instances: [PlanInstance]
    public let name: String?
    public let state: Int
    public let title: String
    public let features: Int
    public let entitlements: [Entitlement]
    public let decorations: [Decoration]
    public let ID: String
    public let services: Int

    public init(description: String,
                instances: [PlanInstance],
                name: String?,
                state: Int,
                title: String,
                features: Int,
                entitlements: [Entitlement],
                decorations: [Decoration],
                ID: String,
                services: Int) {
        self.description = description
        self.instances = instances
        self.name = name
        self.state = state
        self.title = title
        self.features = features
        self.entitlements = entitlements
        self.decorations = decorations
        self.ID = ID
        self.services = services
    }
}

public struct PlanInstance: Decodable, Hashable, Equatable, Sendable {
    public let price: [Price]
    public let description: String
    public let cycle: Int
    public let periodEnd: Int
    public let vendors: Vendors
}

public struct Price: Decodable, Hashable, Equatable, Sendable {

    public let current: Int
    public let currency: String
    public let ID: String

    public init(current: Int, currency: String, ID: String) {
        self.current = current
        self.currency = currency
        self.ID = ID
    }
}

public struct Vendors: Decodable, Hashable, Equatable, Sendable {
    public let apple: Vendor?

    // Only applicable to Safari extension
    public var safari: Vendor?
}

public struct Vendor: Decodable, Hashable, Equatable, Sendable {

    public let productID: String?
    public let customerID: String?
}
