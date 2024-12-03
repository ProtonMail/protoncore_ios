//
//  ProtonPlansManager.swift
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

import Combine
import Foundation
import ProtonCoreObservability
import StoreKit

public protocol ProtonPlansManagerProviding {

    var transactionStatePublisher: Published<TransactionHandlerState>.Publisher { get }
    func getProtonPlans() async throws -> AvailablePlans
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func getAvailablePlans() async throws -> [ComposedPlan]
    func getCurrentPlan() async throws -> CurrentSubscriptionResponse
    func getIntroductoryOfferPrice(product: Product) -> String?
    func purchase(_ product: Product, planName: String, planCycle: Int) async throws -> ComposedPlan
}

public enum ProtonPlansManagerError: Error {
    case unableToExtractReceiptData
    case unableToGetBundleIdentifier
    case unableToGetTransactionAmountOrCurrency
    case unableToCreateRequest
    case unableToFetchProductsFromStore
    case unableToMatchProtonPlanToStoreProduct
    case unableToGetUserTransactionUUID

    // Transaction error
    case transactionNotFound
    case transactionCancelledByUser
    case transactionPending
    case transactionUnknownError
}

public final class ProtonPlansManager: NSObject, ProtonPlansManagerProviding {

    @Published private var transactionState: TransactionHandlerState = .idle
    public var transactionStatePublisher: Published<TransactionHandlerState>.Publisher{ $transactionState }

    private var products: [Product] = []
    private var transactionToken: Token!
    private var refresh: SKReceiptRefreshRequest?
    private var transaction: Transaction?

    private let paymentsAPI: PaymentsAPIs
    private let remoteManager: RemoteManagerProviding
    private let transactionHandler: TransactionHandler
    private let planComposer: PlansComposerProviding

    private var tokenContinuation: CheckedContinuation<Void, Error>?
    private var paymentsToken: NewToken!
    private var planName: String!
    private var planCycle: Int!

    public init(environment: EnvURLType, remoteManager: RemoteManagerProviding, plansComposer: PlansComposerProviding? = nil) {
        self.remoteManager = remoteManager
        self.paymentsAPI = PaymentsAPIs(envURL: environment)
        self.transactionHandler = TransactionHandler(remoteManager: remoteManager,
                                                     paymentsAPIs: paymentsAPI)
        if let composer = plansComposer {
            self.planComposer = composer
        } else {
            self.planComposer = PlansComposer(remoteManager: remoteManager,
                                              paymentsAPIs: paymentsAPI)
        }

        super.init()

        // assing transaction state subscriber
        transactionHandler.$transactionState
            .assign(to: &$transactionState)
    }

    public func updateUserSession(sessionID: String, authToken: String) {
        remoteManager.updateSession(sessionID: sessionID, authToken: authToken)
        transactionHandler.updateRemoteManager(remoteManager: remoteManager)
        planComposer.updateRemoteManager(remoteManager: remoteManager)
    }

    public func getStoreProducts(_ plans: [String]) async throws -> [Product] {

        products = try await planComposer.getStoreProducts(plans)
        return products
    }

    public func getProtonPlans() async throws -> AvailablePlans {
        try await planComposer.fetchProtonPlans()
    }

    public func getIntroductoryOfferPrice(product: Product) -> String? {
        guard let introductoryOffer = product.subscription?.introductoryOffer else { return nil }

        return introductoryOffer.displayPrice
    }

    public func getAvailablePlans() async throws -> [ComposedPlan] {
        do {
            let availablePlans = try await planComposer.fetchAvailablePlans()
            ObservabilityEnv.report(.availablePlansLoad(status: .http2xx))
            return availablePlans
        } catch {
            ObservabilityEnv.report(.availablePlansLoad(httpCode: error.httpCode))
            throw error
        }
    }

    public func getCurrentPlan() async throws -> CurrentSubscriptionResponse {
        do {
            let currentPlan = try await planComposer.fetchCurrentSubscription()
            ObservabilityEnv.report(.currentPlanLoad(status: .http2xx))
            return currentPlan
        } catch {
            ObservabilityEnv.report(.currentPlanLoad(httpCode: error.httpCode))
            throw error
        }
    }

    public func purchase(_ product: Product, planName: String, planCycle: Int) async throws -> ComposedPlan {

        self.planName = planName
        self.planCycle = planCycle

        let userTransactionUUID = try await generateUserTransactionUUID()
        let result = try await product.purchase(options: [.appAccountToken(userTransactionUUID)])

        switch result {
        case .success(let verificationResult):
            let transaction = try verificationResult.payloadValue
            self.transaction = transaction

            try await withCheckedThrowingContinuation { continuation in
                tokenContinuation = continuation
                refresh = SKReceiptRefreshRequest()
                refresh?.delegate = self
                refresh?.start()
            }

            guard let matchingPlan = findMatchingPlan(productID: transaction.productID) else {
                throw ProtonPlansManagerError.unableToMatchProtonPlanToStoreProduct
            }

            _ = try await transactionHandler.processTransaction(transaction.toProtonTransaction(), plan: matchingPlan)
            debugPrint("Transaction completed ✅")
            return matchingPlan
        case .pending:
            throw ProtonPlansManagerError.transactionPending
        case .userCancelled:
            transactionState = .transactionCancelledByUser
            throw ProtonPlansManagerError.transactionCancelledByUser
        @unknown default:
            transactionState = .unknownError
            throw ProtonPlansManagerError.transactionUnknownError
        }
    }

    private func generateUserTransactionUUID() async throws -> UUID {
        guard let request = try? paymentsAPI.url(for: .userTransactionUUID) else {
            throw ProtonPlansManagerError.unableToGetUserTransactionUUID
        }
        
        do {
            let uuidStrign: UserTransactionUUIDResponse = try await remoteManager.getFromURL(request.url)
            guard let uuid = UUID(uuidString: uuidStrign.uuid) else {
                transactionState = .unableToGetUserTransactionUUID
                throw ProtonPlansManagerError.unableToGetUserTransactionUUID
            }

            return uuid
        } catch {
            transactionState = .unableToGetUserTransactionUUID
            throw ProtonPlansManagerError.unableToGetUserTransactionUUID
        }
    }

    private func findMatchingPlan(productID: String) -> ComposedPlan? {
        planComposer.matchPlanToStoreProduct(productID)
    }
}

extension ProtonPlansManager: SKRequestDelegate {

    public func requestDidFinish(_ request: SKRequest) {
        cancelActiveRequest(request)
        ObservabilityEnv.report(.paymentQuerySubscriptionsTotal(status: .successful, isDynamic: true))
        tokenContinuation?.resume()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        cancelActiveRequest(request)
        ObservabilityEnv.report(.paymentQuerySubscriptionsTotal(status: .failed, isDynamic: true))
        tokenContinuation?.resume(throwing: error)
        debugPrint(error)
    }

    private func cancelActiveRequest(_ request: SKRequest) {
        request.cancel()
        refresh = nil
    }
}
