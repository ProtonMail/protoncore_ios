//
//  CurrentPlanDetailsV5.swift
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

struct CurrentPlanDetailsV5 {
    let title: String // "Proton Free"
    let description: String // "Current Plan"
    let cycleDescription: String? // "for 1 month"
    let price: String // "$0"
    let endDate: NSAttributedString? // "Current plan will expire on 10.10.24"
    let entitlements: [Entitlement]
    
    enum Entitlement {
        case progress(ProgressEntitlement)
        case description(DescriptionEntitlement)
        
        struct ProgressEntitlement: Decodable, Equatable {
            var text: String
            var min: Int
            var max: Int
            var current: Int
        }
        
        struct DescriptionEntitlement: Decodable, Equatable {
            var text: String
            var iconName: String
            var hint: String?
        }
    }
    
    static func createPlan(from details: CurrentPlan.Subscription,
                           iapPlan: InAppPurchasePlan,
                           storeKitManager: StoreKitManagerProtocol,
                           protonPrice: String?) -> CurrentPlanDetailsV5? {
        var price: String?
        
        if case .apple = details.external {
            price = protonPrice
        } else {
            price = iapPlan.planPrice(from: storeKitManager)
        }
        
        guard let price else { return nil }
        
        let entitlements = details.entitlements.map { entitlement -> CurrentPlanDetailsV5.Entitlement in
            switch entitlement {
            case .progress(let entitlement):
                return .progress(.init(
                    text: entitlement.text,
                    min: entitlement.min,
                    max: entitlement.max,
                    current: entitlement.current
                ))
            case .description(let entitlement):
                return .description(.init(
                    text: entitlement.text,
                    iconName: entitlement.iconName,
                    hint: entitlement.hint
                ))
            }
        }
        
        return .init(
            title: details.title,
            description: details.description,
            cycleDescription: details.cycleDescription,
            price: price,
            endDate: endDateString(date: details.periodEnd, renew: details.renew ?? false),
            entitlements: entitlements
        )
    }
    
    static func endDateString(date: Int?, renew: Bool) -> NSAttributedString? {
        guard let date = date else { return nil }
        let endDate = Date(timeIntervalSince1970: .init(date))
        guard endDate.isFuture else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let endDateString = dateFormatter.string(from: endDate)
        var string: String
        
        if renew {
            string = String(format: PUITranslations.plan_details_renew_auto_expired.l10n, endDateString)
        } else {
            string = String(format: PUITranslations.plan_details_renew_expired.l10n, endDateString)
        }
        
        return string.getAttributedString(replacement: endDateString, attrFont: .systemFont(ofSize: 13, weight: .bold))
    }
}

#endif
