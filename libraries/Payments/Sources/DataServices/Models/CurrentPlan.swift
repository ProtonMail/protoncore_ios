//
//  CurrentPlan.swift
//  ProtonCorePayments - Created on 13.07.23.
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

/// `CurrentPlan` object is the data model for the plan
///  the user is currently subscribed to.
public struct CurrentPlan: Decodable, Equatable {
    public var subscriptions: [Subscription]
    
    public struct Subscription: Decodable, Equatable {
        public var vendorName: String
        public var title: String
        public var description: String
        public var cycleDescription: String
        public var currency: String?
        public var amount: Int?
        public var periodEnd: Int?
        public var renew: Bool?
        public var external: PaymentMethod?
        public var entitlements: [Entitlement]
        
        public enum PaymentMethod: Int, Decodable {
            case web = 0
            case apple = 1
            case google = 2
        }
        
        public enum Entitlement: Equatable {
            case progress(ProgressEntitlement)
            case description(DescriptionEntitlement)
        }
        
        public struct ProgressEntitlement: Decodable, Equatable {
            var type: String
            public var text: String
            public var min: Int
            public var max: Int
            public var current: Int
        }
        
        public struct DescriptionEntitlement: Decodable, Equatable {
            var type: String
            public var text: String
            public var iconName: String
            public var hint: String?
        }
    }
}

extension CurrentPlan.Subscription.Entitlement: Decodable {
    private enum EntitlementType: String, Decodable {
        case progress
        case description
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(EntitlementType.self, forKey: .type)
        
        switch type {
        case .progress:
            self = .progress(try .init(from: decoder))
        case .description:
            self = .description(try .init(from: decoder))
        }
    }
}
