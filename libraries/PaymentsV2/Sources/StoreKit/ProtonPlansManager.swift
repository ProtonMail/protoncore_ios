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
import ProtonCoreLog
import ProtonCoreDoh
import StoreKit
import ProtonCoreFeatureFlags

public protocol ProtonPlansManagerProviding: Sendable {

    var transactionProgress: CurrentValueSubject<TransactionHandlerState, Never> { get }
    var countryCode: String? { get async }
    func fetchAppleStatus() async throws -> IAPSupportStatusV2
    func getProtonPlans() async throws -> AvailablePlans
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func getAvailablePlans() async throws -> [ComposedPlan]
    func getCurrentPlan() async throws -> CurrentSubscriptionResponse
    func getIntroductoryOfferPrice(product: Product) -> String?
    func purchase(_ product: Product, planName: String, planCycle: Int) async throws -> ComposedPlan
}

public enum ProtonPlansManagerError: LocalizedError {
    case unableToMatchProtonPlanToStoreProduct(productId: String)
    case unableToGetUserTransactionUUID
    case unableToRestorePurchases

    // Transaction error
    case transactionCancelledByUser
    case transactionPending
    case transactionUnknownError

    public var errorDescription: String? {
        switch self {
        case .unableToMatchProtonPlanToStoreProduct:
            return PaymentsV2Localizer.Plans_Manager_impossible_to_match_plan.l10n
        case .unableToGetUserTransactionUUID:
            return PaymentsV2Localizer.Plans_Manager_impossible_to_get_user_uuid.l10n
        case .unableToRestorePurchases:
            return PaymentsV2Localizer.Plans_Manager_impossible_to_restore_transactions.l10n
        case .transactionCancelledByUser:
            return PaymentsV2Localizer.Plans_Manager_Transaction_cancelled_by_user.l10n
        case .transactionUnknownError:
            return PaymentsV2Localizer.Plans_Manager_Transaction_unknown_error.l10n
        case .transactionPending:
            return PaymentsV2Localizer.Plans_Managere_peding_transaction_received.l10n
        }
    }

    public var failureReason: String? {
        switch self {
        case .unableToMatchProtonPlanToStoreProduct(let productId):
            return "Impossible to find AppleStore product with id: \(productId)"
        default:
            return nil
        }
    }
}

public final class ProtonPlansManager: NSObject, ProtonPlansManagerProviding, @unchecked Sendable {

    public var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

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

    public var countryCode: String? {
        get async {
            await Storefront.current?.countryCode.lowercased()
        }
    }

    public init(doh: DoHInterface & ServerConfig,
                remoteManager: RemoteManagerProviding,
                plansComposer: PlansComposerProviding? = nil) {
        self.remoteManager = remoteManager
        self.paymentsAPI = PaymentsAPIs(doh: doh)
        self.transactionHandler = TransactionHandler(remoteManager: remoteManager,
                                                     paymentsAPIs: paymentsAPI)
        if let composer = plansComposer {
            self.planComposer = composer
        } else {
            self.planComposer = PlansComposer(remoteManager: remoteManager,
                                              paymentsAPIs: paymentsAPI)
        }

        super.init()

        // Assiging TransactionHandler currentValue subject to ProtonPlansManager transactionProgress currentValue subject to receive changes.
        // Values received from TransactionHandler are not currently used here, we rely on the throwable processTransaction in TransactionHandler
        // But changes sent from TransactionHandler.transactionState will be passed anyway and can be used, if necessary, from any subscriber
        transactionProgress = transactionHandler.transactionState
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
                let error = ProtonPlansManagerError.unableToMatchProtonPlanToStoreProduct(productId: transaction.productID)
                PMLog.error(error.failureReason ?? "PaymentsV2 - unable to match Proton and AppleStore plans", sendToExternal: true)
                throw error
            }

            do {
                TransactionsObserver.shared.addTransactionInProgress(transaction.id)
                _ = try await transactionHandler.processTransaction(transaction.toProtonTransaction(), plan: matchingPlan)
                TransactionsObserver.shared.removeTransactionInProgress(transaction.id)
                await transaction.finish()
                debugPrint("Transaction completed ✅")
                return matchingPlan
            } catch {
                debugPrint(error)
                throw error
            }
        case .pending:
            let error = ProtonPlansManagerError.transactionPending
            PMLog.error(error.errorDescription ?? "PaymentsV2 - Transaction cancelled by the user", sendToExternal: true)
            throw error
        case .userCancelled:
            transactionProgress.value = .transactionCancelledByUser
            transactionProgress.send(completion: .finished)
            let error = ProtonPlansManagerError.transactionCancelledByUser
            PMLog.error(error.errorDescription ?? "PaymentsV2 - Transaction cancelled by the user", sendToExternal: true)
            throw error
        @unknown default:
            transactionProgress.value = .unknownError
            transactionProgress.send(completion: .finished)
            let error = ProtonPlansManagerError.transactionUnknownError
            PMLog.error(error.errorDescription ?? "PaymentsV2 - unknown transaction error", sendToExternal: true)
            throw error
        }
    }

    public func restorePurchases() async throws -> CurrentSubscriptionResponse {
        do {
            try await AppStore.sync()
            return try await getCurrentPlan()
        } catch {
            debugPrint(error)
            if error is PlansComposerError {
                throw error
            } else {
                let error = ProtonPlansManagerError.unableToRestorePurchases
                PMLog.error(error.errorDescription ?? "PaymentsV2 - impossible to restore transactions", sendToExternal: true)
                throw error
            }
        }
    }

    private func generateUserTransactionUUID() async throws -> UUID {
        let request = try paymentsAPI.url(for: .userTransactionUUID)

        let uuidStrign: UserTransactionUUIDResponse = try await remoteManager.getFromURL(request.url)
        guard let uuid = UUID(uuidString: uuidStrign.uuid) else {
            transactionProgress.value = .unableToGetUserTransactionUUID
            transactionProgress.send(completion: .finished)
            let error = ProtonPlansManagerError.unableToGetUserTransactionUUID
            PMLog.error(error.errorDescription ?? "PaymentsV2 - impossible to get user uuid", sendToExternal: true)
            throw error
        }

        return uuid
    }

    private func findMatchingPlan(productID: String) -> ComposedPlan? {
        planComposer.matchPlanToStoreProduct(productID)
    }

    public func fetchAppleStatus() async throws -> IAPSupportStatusV2 {
        let iapStatusRequest = try paymentsAPI.url(for: .appleStatus)
        let iapStatus: IAPSupportStatusV2
        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsV6Status) {
            let iapV6Response: V6PaymentStatusResponse = try await remoteManager.getFromURL(iapStatusRequest.url)
            iapStatus = iapV6Response.status
        } else {
            let iapV5Response: V5PaymentStatusResponse = try await remoteManager.getFromURL(iapStatusRequest.url)
            iapStatus = iapV5Response.status
        }
        return iapStatus
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
