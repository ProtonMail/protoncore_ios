//
//  PlansComposer.swift
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
import ProtonCoreObservability

public enum PlansComposerError: Error {
    case unableToCreateAvailablePlansRequest
    case unableToFetchCurrentSub
}

public protocol PlansComposerProviding: Sendable {

    var hasData: Bool { get }
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func fetchProtonPlans() async throws -> AvailablePlans
    func matchPlanToStoreProduct(_ productId: String) -> ComposedPlan?
    func fetchAvailablePlans() async throws -> [ComposedPlan]
    func updateRemoteManager(remoteManager: RemoteManagerProviding)
    func fetchCurrentSubscription() async throws -> CurrentSubscriptionResponse
}

public final class PlansComposer: PlansComposerProviding, @unchecked Sendable {

    public var hasData: Bool {
        return !availablePlans.plans.isEmpty && !storeProducts.isEmpty
    }

    private var remoteManager: RemoteManagerProviding
    private let paymentsAPIs: PaymentsAPIs
    private var availablePlans: AvailablePlans = AvailablePlans(code: 0, plans: [], defaultCycle: 0)
    private var storeProducts: [Product] = []
    private let queue = DispatchQueue(label: "paymentsV2.plansComposer.syncQueue")

    public init(remoteManager: RemoteManagerProviding, paymentsAPIs: PaymentsAPIs) {
        self.remoteManager = remoteManager
        self.paymentsAPIs = paymentsAPIs
    }

    public func getStoreProducts(_ plans: [String]) async throws -> [Product] {
        do {
            storeProducts = try await Product.products(for: plans)
            ObservabilityEnv.report(.paymentQuerySubscriptionsTotal(status: .successful, isDynamic: true))
            return storeProducts
        } catch {
            ObservabilityEnv.report(.paymentQuerySubscriptionsTotal(status: .failed, isDynamic: true))
            throw error
        }
    }

    public func fetchProtonPlans() async throws -> AvailablePlans {
        guard let availablePlansRequests = try? paymentsAPIs.url(for: .availablePlans(currency: nil, vendor: nil, state: nil, timeStamp: nil)) else {
            throw PlansComposerError.unableToCreateAvailablePlansRequest
        }

        availablePlans = try await remoteManager.getFromURL(availablePlansRequests.url)
        return availablePlans
    }

    public func matchPlanToStoreProduct(_ productId: String) -> ComposedPlan? {
        if storeProducts.isEmpty || availablePlans.plans.isEmpty {
            debugPrint("no store products or available plans found, fetch them before calling this function")
            return nil
        }

        let products = storeProducts.filter { $0.id == productId }

        return availablePlans.plans.modelsMatchingProducts(in: products).first
    }

    public func fetchAvailablePlans() async throws -> [ComposedPlan] {

        availablePlans = try await fetchProtonPlans()
        storeProducts = try await getStoreProducts(availablePlans.plans.identifiersForAppleInstances())
        return availablePlans.plans.modelsMatchingProducts(in: storeProducts)
    }

    public func fetchCurrentSubscription() async throws -> CurrentSubscriptionResponse {
        let request = try paymentsAPIs.url(for: .getCurrentSubscription)
        let currentSubResponse: CurrentSubscription = try await remoteManager.getFromURL(request.url)

        guard let currentSub = currentSubResponse.subscriptions.first else {
            throw PlansComposerError.unableToFetchCurrentSub
        }

        return currentSub
    }

    public func updateRemoteManager(remoteManager: RemoteManagerProviding) {
        queue.sync {
            self.remoteManager = remoteManager
        }
    }
}
