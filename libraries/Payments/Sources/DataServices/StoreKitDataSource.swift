//
//  StoreKitDataSource.swift
//  ProtonCore-Payments - Created on 23/08/2023.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCoreLog
import ProtonCoreObservability
import StoreKit

public protocol StoreKitDataSourceProtocol {
    var availableProducts: [SKProduct] { get }
    var unavailableProductsIdentifiers: [String] { get }

    func fetchAvailableProducts(productIdentifiers: Set<String>) async throws
}

extension StoreKitDataSourceProtocol {
    func fetchAvailableProducts(availablePlans: AvailablePlans) async throws {
        let planVendorIdentifiers = availablePlans.plans.flatMap(\.instances).compactMap(\.vendors).map(\.apple.productID)
        try await fetchAvailableProducts(productIdentifiers: Set(planVendorIdentifiers))
    }

    func filterAccordingToAvailableProducts(availablePlans originalPlans: AvailablePlans) -> AvailablePlans {
        let availableProductIdentifiers = availableProducts.map(\.productIdentifier)
        let updatedPlans = originalPlans.plans.map { originalPlan in
            let originalInstances = originalPlan.instances
            let updatedInstances = originalInstances.filter {
                guard let vendors = $0.vendors else { return false }
                return availableProductIdentifiers.contains(vendors.apple.productID)
            }
            let updatedPlan = AvailablePlans.AvailablePlan(
                ID: originalPlan.ID,
                type: originalPlan.type,
                name: originalPlan.name,
                title: originalPlan.title,
                description: originalPlan.description,
                instances: updatedInstances,
                entitlements: originalPlan.entitlements,
                decorations: originalPlan.decorations
            )
            return updatedPlan
        }
        return AvailablePlans(plans: updatedPlans, defaultCycle: originalPlans.defaultCycle)
    }
}

final class StoreKitDataSource: StoreKitDataSourceProtocol {
    private(set) var availableProducts: [SKProduct] = []
    private(set) var unavailableProductsIdentifiers: [String] = []

    private let requestFactory: (Set<String>) -> SKProductsRequest

    final class RequestDelegate: NSObject, SKProductsRequestDelegate {
        typealias ResultClosure = (Result<SKProductsResponse, Error>) -> ()

        static var outstandingRequests: [UUID: RequestDelegate] = [:]
        static let queue = DispatchQueue(label: "StoreKitDataSourceRequests")

        let id = UUID()
        private let request: SKProductsRequest
        private let closure: ResultClosure

        init(request: SKProductsRequest, closure: @escaping ResultClosure) {
            self.request = request
            self.closure = closure

            super.init()

            Self.queue.sync {
                Self.outstandingRequests[id] = self
            }

            request.delegate = self
        }

        func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
            closure(.success(response))

            Self.queue.async { [unowned self] in
                Self.outstandingRequests.removeValue(forKey: self.id)
            }
        }

        func request(_ request: SKRequest, didFailWithError error: any Error) {
            closure(.failure(error))

            Self.queue.async { [unowned self] in
                Self.outstandingRequests.removeValue(forKey: self.id)
            }
        }

        func resume() {
            request.start()
        }
    }

    init(requestFactory: @escaping (Set<String>) -> SKProductsRequest = { .init(productIdentifiers: $0) }) {
        self.requestFactory = requestFactory
    }

    func fetchAvailableProducts(productIdentifiers: Set<String>) async throws {
        let skRequest = requestFactory(productIdentifiers)
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = RequestDelegate(request: skRequest) { [weak self] result in
                switch result {
                case .success(let response):
                    if !response.invalidProductIdentifiers.isEmpty {
                        PMLog.debug("Some IAP identifiers are reported as invalid by the AppStore: \(response.invalidProductIdentifiers)")
                    }
                    self?.unavailableProductsIdentifiers = response.invalidProductIdentifiers
                    self?.availableProducts = response.products
                    ObservabilityEnv.report(.paymentQuerySubscriptionsTotal(status: .successful, isDynamic: true))
                    continuation.resume()
                case .failure(let error):
                    PMLog.error("SKProduct fetch failed with error \(error)", sendToExternal: true)
                    ObservabilityEnv.report(.paymentQuerySubscriptionsTotal(status: .failed, isDynamic: false))
                    continuation.resume(throwing: error)
                }
            }
            delegate.resume()
        }
    }
}
