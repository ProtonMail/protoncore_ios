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
    public let name: String
    public let displayName: String
    public let planName: String
    public let planFlags: PlanFlags
    public let twoFactorRequired: Int
    public let twoFactorGracePeriod: Int?
    public let theme: String?
    public let email: String?
    public let maxDomains: Int
    public let maxAddresses: Int
    public let maxCalendars: Int
    public let maxSpace: Int64
    public let maxMembers: Int
    public let maxVPN: Int
    public let features: Int // Bits, 1 = catch-all addresses
    public let flags: Int // Bits, 1 = loyalty
    public let usedDomains: Int
    public let usedAddresses: Int
    public let usedCalendars: Int
    public let usedSpace: Int64
    public let assignedSpace: Int64
    public let usedMembers: Int
    public let usedVPN: Int
    public let hasKeys: Int
    public let toMigrate: Int
    public let brokenSKL: Int
    public let invitationsRemaining: Int
    public let requiresKey: Int
    public let requiresDomain: Int

    public enum PlanFlags: Int, Codable {
        case mail = 1
        case drive = 2
        case vpn = 3
        case unknown

        public init(from decoder: Decoder) throws {
            self = try PlanFlags(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
