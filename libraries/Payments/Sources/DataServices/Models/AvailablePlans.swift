//
//  AvailablePlans.swift
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

import Foundation

/// `AvailablePlans` object is the data model for the
/// list of available plans a user can subscribe to.
public struct AvailablePlans: Decodable, Equatable {
    public var plans: [AvailablePlan]
    
    public struct AvailablePlan: Decodable, Equatable {
        var name: String
        public var title: String
        var state: Int
        var type: Int?
        public var description: String
        var feature: Int
        var layout: String
        public var instances: [Instance]
        public var entitlements: [Entitlement]
        public var decorations: [Decoration]
        
        public struct Instance: Decodable, Equatable {
            var ID: String
            public var cycle: Int // enum: 1, 12, 24
            public var description: String
            var periodEnd: Int
            public var price: [Price]
            public var vendors: Vendors?
            
            /// `Price` is used to determine offers.
            /// If `default != current`, we need to show an offer
            /// percentage is calculate by the diff between `current` and `default`
            /// The percentage is displayed as a Decoration
            public struct Price: Decodable, Equatable {
                public var current: Int
                public var `default`: Int // same as current if no offer, higher otherwise
            }
            
            public struct Vendors: Decodable, Equatable {
                public var apple: Vendor
                
                public struct Vendor: Decodable, Equatable {
                    public var ID: String
                }
            }
        }
        
        public enum Entitlement: Equatable {
            case description(DescriptionEntitlement)
            
            public struct DescriptionEntitlement: Decodable, Equatable {
                var type: String
                public var iconName: String
                public var text: String
                public var hint: String?
            }
        }
        
        public enum Decoration: Equatable {
            case border(BorderDecoration)
            case star(StarDecoration)
            
            public struct BorderDecoration: Decodable, Equatable {
                public var type: String
                public var color: String
            }
            
            public struct StarDecoration: Decodable, Equatable {
                public var type: String
                public var icon: String
            }
        }
    }
}

extension AvailablePlans.AvailablePlan.Entitlement: Decodable {
    private enum EntitlementType: String, Decodable {
        case description
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(EntitlementType.self, forKey: .type)
        
        switch type {
        case .description:
            self = .description(try .init(from: decoder))
        }
    }
}

extension AvailablePlans.AvailablePlan.Decoration: Decodable {
    private enum EntitlementType: String, Decodable {
        case border
        case star
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(EntitlementType.self, forKey: .type)
        
        switch type {
        case .border:
            self = .border(try .init(from: decoder))
        case .star:
            self = .star(try .init(from: decoder))
        }
    }
}
