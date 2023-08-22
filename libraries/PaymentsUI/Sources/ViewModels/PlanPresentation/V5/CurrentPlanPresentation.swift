//
//  CurrentPlanPresentation.swift
//  ProtonCorePaymentsUI - Created on 10/08/2023.
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

import ProtonCorePayments

class CurrentPlanPresentation {
    let currentPlan: InAppPurchasePlan
    let details: CurrentPlanDetailsV5
    var storeKitProductId: String? { currentPlan.storeKitProductId }
    
    init(currentPlan: InAppPurchasePlan,
         details: CurrentPlanDetailsV5) {
        self.currentPlan = currentPlan
        self.details = details
    }
    
    static func createCurrentPlan(from currentPlanSubscription: CurrentPlan.Subscription,
                                  storeKitManager: StoreKitManagerProtocol,
                                  price protonPrice: String?) -> CurrentPlanPresentation? {
        
        guard let inAppPurchasePlan = InAppPurchasePlan(currentPlanSubscription: currentPlanSubscription) else {
            return nil
        }
        
        guard let details = CurrentPlanDetailsV5.createPlan(
            from: currentPlanSubscription,
            iapPlan: inAppPurchasePlan,
            storeKitManager: storeKitManager,
            protonPrice: protonPrice
        ) else { return nil }
        
        return .init(currentPlan: inAppPurchasePlan, details: details)
    }
}

#endif
