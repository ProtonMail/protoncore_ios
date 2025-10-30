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
import ProtonCoreFeatureFlags
import ProtonCoreObservability
import ProtonCoreLog
import ProtonCoreDoh
import StoreKit

public protocol ProtonPlansManagerProviding: Sendable {

    var transactionProgress: CurrentValueSubject<TransactionHandlerState, Never> { get }
    var countryCode: String? { get async }
    func getProtonPlans() async throws -> AvailablePlans
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func getAvailablePlans() async throws -> [ComposedPlan]
    func getCurrentPlan() async throws -> CurrentSubscriptionResponse
    func purchase(_ product: Product) async throws -> ComposedPlan
    func recoverTransactionReceipt() async throws
    func updateUserSession(sessionID: String, authToken: String)
    func checkIAPStatus() async throws -> IAPStatus
}

public enum ProtonPlansManagerError: LocalizedError {
    case unableToMatchProtonPlanToStoreProduct(productId: String)
    case unableToGetUserTransactionUUID
    case unableToRestorePurchases
    case iapNotAvailable(reason: String)

    // Transaction error
    case transactionCancelledByUser
    case transactionPending
    case transactionUnknownError
    case noUnfinshedTransactionsFound

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
        case .noUnfinshedTransactionsFound:
            return PaymentsV2Localizer.Plans_Manager_pending_transaction_received.l10n
        case .transactionPending, .iapNotAvailable:
            return nil
        }
    }

    public var failureReason: String? {
        switch self {
        case .unableToMatchProtonPlanToStoreProduct(let productId):
            return "Impossible to find AppleStore product with id: \(productId)"
        case .noUnfinshedTransactionsFound:
            return "Receipt recover attempt: No unfinished verified transaction found"
        case .iapNotAvailable(let reason):
            return "IAP error: \(reason)"
        default:
            return nil
        }
    }
}

public final class ProtonPlansManager: NSObject, ProtonPlansManagerProviding, @unchecked Sendable {

    public var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

    private var products: [Product] = []

    private let paymentsAPI: PaymentsAPIs
    private let remoteManager: RemoteManagerProviding
    private let transactionHandler: TransactionHandlerProviding
    private let planComposer: PlansComposerProviding

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

#if DEBUG
        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled) {
            debugPrint("OM Transaction flow")
            self.transactionHandler = OCTransactionHandler(remoteManager: remoteManager,
                                                           paymentsAPIs: paymentsAPI)
        } else {
            debugPrint("Legacy Transaction flow")
            self.transactionHandler = TransactionHandler(remoteManager: remoteManager,
                                                         paymentsAPIs: paymentsAPI)
        }
#else
        self.transactionHandler = TransactionHandler(remoteManager: remoteManager,
                                                     paymentsAPIs: paymentsAPI)
#endif
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

    public func checkIAPStatus() async throws -> IAPStatus {
        do {
            let iapStatus = try paymentsAPI.url(for: .appleStatus)
            let iapStatusResponse: IAPStatus = try await remoteManager.getFromURL(iapStatus.url)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "iap status check",
                                                                   "status": "available"])
            return iapStatusResponse
        } catch {
            debugPrint(error)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "iap status check",
                                                                   "status": error.localizedDescription])
            throw ProtonPlansManagerError.iapNotAvailable(reason: error.localizedDescription)
        }
    }

    public func getStoreProducts(_ plans: [String]) async throws -> [Product] {

        products = try await planComposer.getStoreProducts(plans)
        return products
    }

    public func getProtonPlans() async throws -> AvailablePlans {
        try await planComposer.fetchProtonPlans()
    }

    public func getAvailablePlans() async throws -> [ComposedPlan] {
        do {
            if try await checkIAPStatus().isAvailable == false {
                return []
            }
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

    public func purchase(_ product: Product) async throws -> ComposedPlan {

        let iapStatus = try await checkIAPStatus()
        if !iapStatus.isAvailable {
            throw ProtonPlansManagerError.iapNotAvailable(reason: iapStatus.unavailabilityReason ?? "")
        }

        await TransactionsObserver.shared.logHelper?.logEvent(["phase": "iap purchase",
                                                               "productId": product.id])

        let userTransactionUUID = try await generateUserTransactionUUID()

        let result = try await product.purchase(options: [.appAccountToken(userTransactionUUID)])

        switch result {
        case .success(let verificationResult):
            let transaction = try verificationResult.payloadValue
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "apple_transaction",
                                                                   "status": "success",
                                                                   "jwsRepresentation": verificationResult.jwsRepresentation])

            guard let matchingPlan = await findMatchingPlan(productID: transaction.productID) else {
                let error = ProtonPlansManagerError.unableToMatchProtonPlanToStoreProduct(productId: transaction.productID)
                await TransactionsObserver.shared.logHelper?.logEvent(["phase": "proton_plan_match",
                                                                       "success": false,
                                                                       "error": error.failureReason ?? error.localizedDescription],
                                                                      type: .close)
                PMLog.error(error.failureReason ?? "PaymentsV2 - unable to match Proton and AppleStore plans", sendToExternal: true)
                throw error
            }

            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "proton_plan_match",
                                                                   "time": Date.now.description,
                                                                   "success": true])

            do {
                TransactionsObserver.shared.addTransactionInProgress(transaction.id)

                // Omnichannel FF check
#if DEBUG
                if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled) {
                    _ = try await transactionHandler.processTransaction(transaction.toProtonTransaction(),
                                                                        jwsRepresentation: verificationResult.jwsRepresentation,
                                                                        plan: matchingPlan)
                } else {
                    _ = try await transactionHandler.processTransaction(transaction.toProtonTransaction(),
                                                                        plan: matchingPlan)
                }
#else
                _ = try await transactionHandler.processTransaction(transaction.toProtonTransaction(),
                                                                    plan: matchingPlan)
#endif

                TransactionsObserver.shared.removeTransactionInProgress(transaction.id)
                await transaction.finish()
                debugPrint("Transaction completed ✅")
                await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_sub",
                                                                       "apple_transction_completed": true])
                return matchingPlan
            } catch {
                await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_sub",
                                                                       "error:": error.localizedDescription])
                TransactionsObserver.shared.removeTransactionInProgress(transaction.id)
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

    public func recoverTransactionReceipt() async throws {
        // Recovery TransactionTest
        debugPrint("RECOVERY FLOW INITIATED 🤞🏻🤞🏻")
        guard let pendingTransaction = try await StoreKitReceiptManager().recoverTransaction() else {
            debugPrint("No transaction returned")
            throw ProtonPlansManagerError.noUnfinshedTransactionsFound
        }

        guard let matchingPlan = await findMatchingPlan(productID: pendingTransaction.transaction.productID) else {
            let error = ProtonPlansManagerError.unableToMatchProtonPlanToStoreProduct(productId: pendingTransaction.transaction.productID)
            PMLog.error(error.failureReason ?? "PaymentsV2 - unable to match Proton and AppleStore plans", sendToExternal: true)
            throw error
        }

        do {
            TransactionsObserver.shared.addTransactionInProgress(pendingTransaction.transaction.id)
            _ = try await transactionHandler.processTransaction(pendingTransaction.transaction.toProtonTransaction(), plan: matchingPlan)
            TransactionsObserver.shared.removeTransactionInProgress(pendingTransaction.transaction.id)
            await pendingTransaction.transaction.finish()
            debugPrint("RECOVERY FLOW SUCCESSFUL ✅")
        } catch {
            TransactionsObserver.shared.removeTransactionInProgress(pendingTransaction.transaction.id)
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

    private func findMatchingPlan(productID: String) async -> ComposedPlan? {
        do {
            if !planComposer.hasData {
                _ = try await planComposer.fetchProtonPlans()
            }
            return planComposer.matchPlanToStoreProduct(productID)
        } catch {
            debugPrint("ProtonPlanManager failed to match plan: \(error)")
            return nil
        }
    }
}
