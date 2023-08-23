//
//  AvailablePlansDetails.swift
//  ProtonCorePaymentsUI - Created on 18.08.23.
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

#if os(iOS)

import Foundation
import ProtonCorePayments

struct AvailablePlansDetails {
    let iapID: String
    let title: String // "VPN Plus"
    let description: String // "Your privacy are our priority."
    let cycleDescription: String? // "for 1 year"
    let price: String // "$71.88"
    let decorations: [Decoration]
    let entitlements: [Entitlement]
    
    enum Decoration {
        case percentage(percentage: String, decription: String)
        case star(iconName: String)
        case border(color: String)
    }
    
    struct Entitlement {
        var text: String
        var iconName: String
        var hint: String?
    }
    
    static func createPlan(from plan: AvailablePlans.AvailablePlan,
                           for instance: AvailablePlans.AvailablePlan.Instance,
                           iapPlan: InAppPurchasePlan,
                           storeKitManager: StoreKitManagerProtocol) -> AvailablePlansDetails? {
        guard let price = iapPlan.planPrice(from: storeKitManager) else {
            return nil
        }
        
        let decorations: [Decoration] = plan.decorations.map {
            switch $0 {
            case .border(let decoration):
                return .border(color: decoration.color)
            case .star(let decoration):
                return .star(iconName: decoration.icon)
            }
        }
        
        let entitlements: [Entitlement] = plan.entitlements.map {
            switch $0 {
            case .description(let entitlement):
                return .init(
                    text: entitlement.text,
                    iconName: entitlement.iconName,
                    hint: entitlement.hint)
            }
        }
        
        return .init(
            iapID: instance.vendors?.apple.ID ?? "",
            title: plan.title,
            description: plan.description,
            cycleDescription: instance.description,
            price: price,
            decorations: decorations,
            entitlements: entitlements
        )
    }
}

#endif
