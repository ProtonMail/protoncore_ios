//
//  Plan.swift
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

public struct Plan: Decodable, Identifiable, Equatable, Hashable, Sendable {

    public let id: String
    public let type: Int
    public let state: Int
    public let cycle: Int
    public let name: String
    public let title: String
    public let currency: String
    public let amount: Int
    public let maxDomains: Int
    public let maxAddresses: Int
    public let maxCalendars: Int
    public let maxSpace: Int
    public let maxMembers: Int
    public let maxVPN: Int
    public let services: Int
    public let features: Int
    public let quantity: Int
    public let maxTier: Int

    public init(id: String,
                type: Int,
                state: Int,
                cycle: Int,
                name: String,
                title: String,
                currency: String,
                amount: Int,
                maxDomains: Int,
                maxAddresses: Int,
                maxCalendars: Int,
                maxSpace: Int,
                maxMembers: Int,
                maxVPN: Int,
                services: Int,
                features: Int,
                quantity: Int,
                maxTier: Int) {
        self.id = id
        self.type = type
        self.state = state
        self.cycle = cycle
        self.name = name
        self.title = title
        self.currency = currency
        self.amount = amount
        self.maxDomains = maxDomains
        self.maxAddresses = maxAddresses
        self.maxCalendars = maxCalendars
        self.maxSpace = maxSpace
        self.maxMembers = maxMembers
        self.maxVPN = maxVPN
        self.services = services
        self.features = features
        self.quantity = quantity
        self.maxTier = maxTier
    }
}
