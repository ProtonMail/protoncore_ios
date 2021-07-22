//
//  ValidationManager.swift
//  ProtonCore-Payments - Created on 19/03/2021.
//
//  Copyright (c) 2021 Proton Technologies AG
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

import Foundation
import StoreKit

protocol ValidationManagerDelegate: AnyObject {
    var servicePlanDataService: ServicePlanDataService? { get }
    var products: [SKProduct]? { get }
}

class ValidationManager {
    weak var delegate: ValidationManagerDelegate?

    func isValidPurchase(identifier: String) -> Bool {
        if case .success = canPurchaseProduct(identifier: identifier) {
            return true
        }
        return false
    }

    func canPurchaseProduct(identifier: String) -> Result<SKProduct, Error> {
        guard let availableProducts = delegate?.products, let product = availableProducts.first(where: { $0.productIdentifier == identifier }) else {
            return .failure(StoreKitManager.Errors.unavailableProduct)
        }
        guard let requestedPlan = AccountPlan(storeKitProductId: identifier), let servicePlanDataService = delegate?.servicePlanDataService else { return .failure(StoreKitManager.Errors.unavailableProduct) }
        let validPlans = [AccountPlan.mailPlus, AccountPlan.vpnBasic, AccountPlan.vpnPlus]
        let currentPlans = servicePlanDataService.currentSubscription?.plans.filter { $0 != .free } ?? []
        let addonPlans = servicePlanDataService.currentSubscription?.planDetails?.filter { $0.type == 0 } ?? []
        let currentOtherPlans = currentPlans.filter { $0 != requestedPlan }
        guard validPlans.contains(requestedPlan) else {
            return .failure(StoreKitManager.Errors.invalidPurchase)
        }

        // a1, b1 - allow purchase from free to validPlans
        if currentPlans.count == 0 && addonPlans.isEmpty {
            return .success(product)
        }

        // a2, b2 - don't allow purchase if there is any addon (addresses, custom domains, storage)
        else if !addonPlans.isEmpty {
            return .failure(StoreKitManager.Errors.invalidPurchase)
        }

        // a3 - allow buy credits if current account plan is mailPlus for 1 year and without addons
        else if requestedPlan == .mailPlus, currentPlans.count == 1, currentPlans.contains(.mailPlus), addonPlans.isEmpty, servicePlanDataService.currentSubscription?.cycle == 12 {
            return .success(product)
        }

        // b3 allow buy credits if current account plan is vpnBasic for 1 year and without addons and credit < 48
        else if isVpnCreditValid(plan: .vpnBasic, requestedPlan: requestedPlan, currentPlans: currentPlans, isNotAddon: addonPlans.isEmpty) {
            return .success(product)
        }

        // b3 allow buy credits if current account plan is vpnPlus for 1 year and without addons and credit < 96
        else if isVpnCreditValid(plan: .vpnPlus, requestedPlan: requestedPlan, currentPlans: currentPlans, isNotAddon: addonPlans.isEmpty) {
            return .success(product)
        }

        // a4, b4 - don't allow purchase if there is any other paid plan
        else if currentOtherPlans.count > 0 {
            return .failure(StoreKitManager.Errors.invalidPurchase)
        }
        return .failure(StoreKitManager.Errors.invalidPurchase)
    }

    private func isVpnCreditValid(plan: AccountPlan, requestedPlan: AccountPlan, currentPlans: [AccountPlan], isNotAddon: Bool) -> Bool {
        guard plan == .vpnBasic || plan == .vpnPlus else { return false }
        if requestedPlan == plan, currentPlans.count == 1, currentPlans.contains(plan), isNotAddon, delegate?.servicePlanDataService?.currentSubscription?.cycle == 12, delegate?.servicePlanDataService?.credits?.credit ?? 0 < Double(plan.yearlyCost) / 100 {
            return true
        }
        return false
    }
}
