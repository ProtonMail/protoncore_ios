//
//  Plan+Fixture.swift
//  ProtonCore-TestingToolkit - Created on 07/09/2021.
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

import ProtonCore_Payments

public extension Plan {
    
    static var dummy: Plan {
        Plan(name: .empty, iD: nil, maxAddresses: .zero, maxMembers: .zero, pricing: nil,
             maxDomains: .zero, maxSpace: .zero, maxRewardsSpace: nil, type: .zero, title: .empty, maxVPN: .zero, maxTier: nil,
             features: .zero, maxCalendars: nil, state: nil, cycle: nil)
    }

    func updated(name: String? = nil,
                 iD: String? = nil,
                 maxAddresses: Int? = nil,
                 maxMembers: Int? = nil,
                 pricing: [String: Int]? = nil,
                 maxDomains: Int? = nil,
                 maxSpace: Int64? = nil,
                 maxRewardsSpace: Int64? = nil,
                 type: Int? = nil,
                 title: String? = nil,
                 maxVPN: Int? = nil,
                 maxTier: Int? = nil,
                 features: Int? = nil,
                 maxCalendars: Int? = nil,
                 state: Int? = nil,
                 cycle: Int? = nil) -> Plan {
        Plan(name: name ?? self.name,
             iD: iD ?? self.iD,
             maxAddresses: maxAddresses ?? self.maxAddresses,
             maxMembers: maxMembers ?? self.maxMembers,
             pricing: pricing ?? self.pricing,
             maxDomains: maxDomains ?? self.maxDomains,
             maxSpace: maxSpace ?? self.maxSpace,
             maxRewardsSpace: maxRewardsSpace ?? self.maxRewardsSpace,
             type: type ?? self.type,
             title: title ?? self.title,
             maxVPN: maxVPN ?? self.maxVPN,
             maxTier: maxTier ?? self.maxTier,
             features: features ?? self.features,
             maxCalendars: maxCalendars ?? self.maxCalendars,
             state: state ?? self.state,
             cycle: cycle ?? self.cycle)
    }
}
