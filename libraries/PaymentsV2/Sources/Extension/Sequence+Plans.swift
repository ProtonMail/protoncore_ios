//
//  Sequence+Plans.swift
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

extension Sequence where Element == AvailablePlan {
    func identifiersForAppleInstances() -> [String] {
        flatMap { $0.instances }
            .compactMap { $0.vendors.apple?.productID ?? $0.vendors.safari?.productID }
    }

    func modelsMatchingProducts(in products: any Sequence<Product>) -> [ComposedPlan] {
        flatMap { plan in
            // build tuples of (Plan, Instance) for every plan and their children instances
            plan.instances.map { (plan, $0) }
        }
        .compactMap { plan, instance -> ComposedPlan? in
            // when instance.productID and Product.id match, build a model with the plan, instance and product
            guard let matchingProduct = products.first(where: {
                $0.id == instance.vendors.apple?.productID ||
                $0.id == instance.vendors.safari?.productID
            }) else { return nil }
            return ComposedPlan(plan: plan, instance: instance, product: matchingProduct)
        }
    }
}

extension Sequence {

    func asyncCompactMap<T>(_ transform: (Self.Element) async throws -> T?) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            if let transformedElement = try await transform(element) {
                values.append(transformedElement)
            }
        }

        return values
    }
}
