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
import StoreKit

public struct ComposedPlan: Equatable, Hashable, Sendable {

    public let plan: AvailablePlan
    public let instance: PlanInstance
    public let product: any ProductProtocol

    private static let minimumVisibleDiscount = 5

    public init(plan: AvailablePlan, instance: PlanInstance, product: any ProductProtocol) {
        self.plan = plan
        self.instance = instance
        self.product = product
    }

    public var pricePerMonth: Double {
        switch instance.cycle {
        case 1, 12:
            return (NSDecimalNumber(decimal: product.price).doubleValue / Double(instance.cycle)) / 100
        default:
            debugPrint("\(instance.cycle) cycle not supported")
            return 0
        }
    }

    public func discount(comparedTo plan: ComposedPlan) -> Int? {
        let pricePerMonthCurrentPlan: Double = pricePerMonth
        let pricePerMonthComparedPlan: Double = plan.pricePerMonth

        guard pricePerMonthComparedPlan != 0 else { return nil }
        guard pricePerMonthCurrentPlan != 0 else { return 100 }
        let discountDouble = (1 - (pricePerMonthCurrentPlan / pricePerMonthComparedPlan)) * 100
        // don't round to 100% if it's not exactly 100%
        let discountInt = min(Int(discountDouble.rounded()), 99)
        return discountInt >= Self.minimumVisibleDiscount ? discountInt : nil
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
