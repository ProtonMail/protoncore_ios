//
//  ComposedPlan.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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

import Foundation
import ProtonCoreFeatureFlags
import StoreKit

public struct ComposedPlan: Equatable, Hashable, Sendable {

    public let plan: AvailablePlan
    public let instance: PlanInstance
    public let product: any ProductProtocol
    public private(set) var offers: [Offer] = []

    private static let minimumVisibleDiscount = 5

    public init(plan: AvailablePlan, instance: PlanInstance, product: any ProductProtocol) {
        self.plan = plan
        self.instance = instance
        self.product = product
        offersAvailable()
    }

    @available(*, deprecated, message: "This will be removed; please use `storePricePerMonth` instead")
    public var pricePerMonth: Double {
        switch instance.cycle {
        case 1, 12:
            return (NSDecimalNumber(decimal: product.price).doubleValue / Double(instance.cycle)) / 100
        default:
            debugPrint("\(instance.cycle) cycle not supported")
            return 0
        }
    }

    public var amountOfMonths: Int {
        // subsription will be `nil` only if it's not autorenewable
        guard let subscription = product.subscription else { return 0 }
        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value
        switch unit {
            // we don't support these
        case .day, .week:
            return 0
        case .month:
            return value
        case .year:
            return 12 * value
        @unknown default:
            return 0
        }
    }

    public var storePricePerMonth: Decimal {
        guard amountOfMonths != 0 else { return product.price / Decimal(instance.cycle) }
        return product.price / Decimal(amountOfMonths)
    }

    public var pricePerMonthLabel: String {
        product.priceFormatStyle.format(storePricePerMonth)
    }

    public var durationLabel: String? {
        // subsription will be `nil` only if it's not autorenewable
        guard let subscription = product.subscription else {
            // should not happen; if it did then it's a single purchase that we don't have now
            return nil
        }
        return subscription.subscriptionPeriod.formatted(Date.ComponentsFormatStyle.init(style: .wide))
    }

    public func discount(comparedTo plan: ComposedPlan) -> Int? {
        let pricePerMonthCurrentPlan: Decimal = storePricePerMonth
        let pricePerMonthComparedPlan: Decimal = plan.storePricePerMonth
        return Self.discount(currentPrice: pricePerMonthCurrentPlan, comparedPrice: pricePerMonthComparedPlan)
    }

    public static func discount(currentPrice: Decimal, comparedPrice: Decimal) -> Int? {
        guard comparedPrice != 0 else { return nil }
        guard currentPrice != 0 else { return 100 }
        let discountDecimal = (1 - (currentPrice / comparedPrice)) * 100
        // don't round to 100% if it's not exactly 100%
        let discountInt = min(Int(NSDecimalNumber(decimal: discountDecimal).doubleValue.rounded()), 99)
        return discountInt >= Self.minimumVisibleDiscount ? discountInt : nil
    }

    public func isEligibleForIntroOffer() async -> Bool {
        return await self.product.subscription?.isEligibleForIntroOffer ?? false
    }

    private mutating func offersAvailable() {
        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled) {
            if let introOffer = product.subscription?.introductoryOffer {
                offers.append(introOffer.toOffer())
            }
            if let promoOffers = product.subscription?.promotionalOffers.compactMap({ $0.toOffer() }) {
                offers.append(contentsOf: promoOffers)
            }

            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *){
                if let winBackOffers = product.subscription?.winBackOffers.compactMap({ $0.toOffer() }) {
                    offers.append(contentsOf: winBackOffers)
                }
            }
        }
    }
}

extension ComposedPlan {
    public static func == (lhs: ComposedPlan, rhs: ComposedPlan) -> Bool {
        lhs.plan == rhs.plan &&
        lhs.instance == rhs.instance
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(plan.id)
        hasher.combine(product.id)
    }
}
