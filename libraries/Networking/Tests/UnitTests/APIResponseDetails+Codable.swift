//
//  APIResponseDetails+Codable.swift
//  ProtonCore-Networking-iOS-Unit-Tests - Created on 19.04.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

@testable import ProtonCoreNetworking

extension APIResponseDetails: Codable, Equatable {
    public static func == (lhs: APIResponseDetails, rhs: APIResponseDetails) -> Bool {
        switch (lhs, rhs) {
        case (.humanVerification(let lhsDetails), .humanVerification(let rhsDetails)): return lhsDetails == rhsDetails
        case (.deviceVerification(let lhsDetails), .deviceVerification(let rhsDetails)): return lhsDetails == rhsDetails
        case (.missingScopes(let lhsDetails), .missingScopes(let rhsDetails)): return lhsDetails == rhsDetails
        case (.empty, .empty): return true
        default: return false
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .humanVerification(let details):
            var container = encoder.container(keyedBy: HumanVerificationDetails.CodingKeys.self)
            try container.encode(details.token, forKey: .token)
            try container.encode(details.title, forKey: .title)
            try container.encode(details.methods, forKey: .methods)
        case .deviceVerification(let details):
            var container = encoder.container(keyedBy: DeviceVerificationDetails.CodingKeys.self)
            try container.encode(details.type, forKey: .type)
            try container.encode(details.payload, forKey: .payload)
        case .missingScopes(let details):
            var container = encoder.container(keyedBy: MissingScopesDetails.CodingKeys.self)
            try container.encode(details.missingScopes, forKey: .missingScopes)
        case .empty:
            break
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let humanVerificationDetails = try? HumanVerificationDetails(from: decoder) {
            self = .humanVerification(humanVerificationDetails)
        } else if let deviceVerificationDetails = try? DeviceVerificationDetails(from: decoder) {
            self = .deviceVerification(deviceVerificationDetails)
        } else if let missingScopesDetails = try? MissingScopesDetails(from: decoder) {
            self = .missingScopes(missingScopesDetails)
        } else {
            self = .empty
        }
    }
}
