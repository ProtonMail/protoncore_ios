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

public struct AvailablePlan: Decodable, Hashable, Identifiable, Sendable {

    public let description: String
    public let instances: [PlanInstance]
    public let name: String?
    public let state: Int
    public let type: Int?
    public let title: String
    public let features: Int
    public let entitlements: [Entitlement]
    public let decorations: [Decoration]
    public let id: String
    public let services: Int
}

public struct PlanInstance: Decodable, Hashable, Equatable, Sendable {
    public let price: [Price]
    public let description: String
    public let cycle: Int
    public let periodEnd: Int
    public let vendors: Vendors
}

public struct Price: Decodable, Hashable, Equatable, Identifiable, Sendable {

    public let current: Int
    public let currency: String
    public let id: String
}

public struct Vendors: Decodable, Hashable, Equatable, Sendable {
    public let apple: Vendor?
}

public struct Vendor: Decodable, Hashable, Equatable, Sendable {

    public let productID: String?
    public let customerID: String?
}
