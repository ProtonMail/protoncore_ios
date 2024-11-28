//
//  Organization.swift
//  ProtonCore-Login - Created on 13.11.24.
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

public struct Organization: Codable {
    let name: String
    let displayName: String
    let planName: String
    let planFlags: PlanFlags
    let twoFactorRequired: Int
    let twoFactorGracePeriod: Int?
    let theme: String?
    let email: String?
    let maxDomains: Int
    let maxAddresses: Int
    let maxCalendars: Int
    let maxSpace: Int
    let maxMembers: Int
    let maxVPN: Int
    let features: Int // Bits, 1 = catch-all addresses
    let flags: Int // Bits, 1 = loyalty
    let usedDomains: Int
    let usedAddresses: Int
    let usedCalendars: Int
    let usedSpace: Int
    let assignedSpace: Int
    let usedMembers: Int
    let usedVPN: Int
    let hasKeys: Int
    let toMigrate: Int
    let brokenSKL: Int
    let invitationsRemaining: Int
    let requiresKey: Int
    let requiresDomain: Int

    public enum PlanFlags: Int, Codable {
        case mail = 1
        case drive = 2
        case vpn = 3
    }
}
