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

public struct CurrentPlan: Decodable, Equatable {
    var code: Int
    var subscription: Subscription
    var upcomingSubscription: Subscription?
    
    public struct Subscription: Decodable, Equatable {
        var name: String
        var description: String
        var ID: String
        var parentMetaPlanID: String
        var type: Int
        var title: String
        var cycle: Int?
        var cycleDescription: String
        var currency: String
        var amount: Int
        var offer: String
        var quantity: Int
        var periodStart: Int
        var periodEnd: Int
        var createTime: Int
        var couponCode: String?
        var discount: Int
        var renewDiscount: Int
        var renewAmount: Int
        var renew: Int
        var external: Int
        var entitlements: [Entitlements]
        var decorations: [Decoration]
        
        enum Entitlements: Equatable {
            case storage(StorageBenefit)
            case description(DescriptionBenefit)
        }
        
        struct StorageBenefit: Decodable, Equatable {
            var type: String
            var max: Int
            var current: Int
        }
        
        struct DescriptionBenefit: Decodable, Equatable {
            var type: String
            var text: String
            var icon: String
            var hint: String
        }
        
        struct Decoration: Decodable, Equatable {
            var type: String
            var icon: String?
            var color: String?
        }
    }
}

extension CurrentPlan.Subscription.Entitlements: Decodable {
    private enum BenefitType: String, Decodable {
        case storage = "Storage"
        case description = "Description"
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(BenefitType.self, forKey: .type)
        
        switch type {
        case .storage:
            self = .storage(try .init(from: decoder))
        case .description:
            self = .description(try .init(from: decoder))
        }
    }
}
