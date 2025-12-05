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

public protocol PublicProtonPlansManagerProviding: Sendable {

    var countryCode: String? { get async }
    func getProtonPlans() async throws -> AvailablePlans
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func getAvailablePlans() async throws -> [ComposedPlan]
    func getCurrentPlan() async throws -> CurrentSubscriptionResponse
    func purchase(_ product: Product, options: Set<Product.PurchaseOption>?) async throws -> ComposedPlan?
    func purchaseWinBackOffer(_ product: Product, offerId: String) async throws -> ComposedPlan?
    func recoverTransactionReceipt() async throws
    func updateUserSession(sessionID: String, authToken: String)
    func checkIAPStatus() async throws -> IAPStatus
}

internal protocol InternalProtonPlansManagerProviding: Sendable {
    func buildPurchaseOptions(_ options: Set<Product.PurchaseOption>?) async throws -> Set<Product.PurchaseOption>
}

public enum ProtonPlansManagerError: LocalizedError {
    case unableToMatchProtonPlanToStoreProduct(productId: String)
    case unableToGetUserTransactionUUID
    case unableToRestorePurchases
    case iapNotAvailable(reason: String)
    case noOfferFound(id: String, offerType: String)
    case iOSVersionError

    // Transaction error
    case transactionCancelledByUser
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
        case .iapNotAvailable, .noOfferFound, .iOSVersionError:
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
        case .noOfferFound(let id, let offerType):
            return "No offer found of type: \(offerType) and id: \(id)"
        case .iOSVersionError:
            return "Functionality not supported in the current OS version: \(SystemHelpers.currentOS)"
        default:
            return nil
        }
    }
}

public final class ProtonPlansManager: NSObject, PublicProtonPlansManagerProviding, InternalProtonPlansManagerProviding, @unchecked Sendable {

    private var products: [Product] = []

    private let paymentsAPI: PaymentsAPIs
    private let remoteManager: RemoteManagerProviding
    private let planComposer: PlansComposerProviding
    private var userTransactionUUID: UUID?
    private var cancellables = Set<AnyCancellable>()

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

        if let composer = plansComposer {
            self.planComposer = composer
        } else {
            self.planComposer = PlansComposer(remoteManager: remoteManager,
                                              paymentsAPIs: paymentsAPI)
        }

        super.init()

        if TransactionsObserver.shared.transactionHandler == nil {
            fatalError("TransactionsObserver not started. It's required in order to process transactions")
        }
    }

    public func updateUserSession(sessionID: String, authToken: String) {
        remoteManager.updateSession(sessionID: sessionID, authToken: authToken)
        TransactionsObserver.shared.transactionHandler.updateRemoteManager(remoteManager: remoteManager)
        planComposer.updateRemoteManager(remoteManager: remoteManager)
    }

    public func checkIAPStatus() async throws -> IAPStatus {
        debugPrint("checkIAPStatus called \(Date.now)")
        TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .iapStatusCheck)
        do {
            let iapStatus = try paymentsAPI.url(for: .appleStatus)
            let iapStatusResponse: IAPStatus = try await remoteManager.getFromURL(iapStatus.url)
            PMLog.info("ProtonPlansManager - IAP Status check successful", sendToExternal: true)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "iap status check",
                                                                   "status": "available"])
            return iapStatusResponse
        } catch {
            debugPrint(error)
            PMLog.error("ProtonPlansManager - IAP Status check failed: \(error)", sendToExternal: true)
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
        TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .fetchProtonPlans)
        return try await planComposer.fetchProtonPlans()
    }

    public func getAvailablePlans() async throws -> [ComposedPlan] {
        do {
            TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .fetchAvailablePlans)
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

    func buildPurchaseOptions(_ options: Set<Product.PurchaseOption>? = []) async throws -> Set<Product.PurchaseOption> {
        var purchaseOptions = Set<Product.PurchaseOption>()
        userTransactionUUID = try await generateUserTransactionUUID()
        // Request UUID and pass it as a purchase option
        guard let userUUID = userTransactionUUID else {
            let error = ProtonPlansManagerError.unableToGetUserTransactionUUID
            PMLog.error(error.errorDescription ?? "PaymentsV2 - impossible to get user uuid", sendToExternal: true)
            throw error
        }
        purchaseOptions.insert(.appAccountToken(userUUID))
        // Add any passed purchase options
        purchaseOptions.formUnion(options ?? [])

        return purchaseOptions
    }

    public func purchase(_ product: Product, options: Set<Product.PurchaseOption>? = []) async throws -> ComposedPlan? {

        let iapStatus = try await checkIAPStatus()
        if !iapStatus.isAvailable {
            throw ProtonPlansManagerError.iapNotAvailable(reason: iapStatus.unavailabilityReason ?? "")
        }

        PMLog.info("ProtonPlansManager - IAP Purchase product: \(product.id)", sendToExternal: true)
        await TransactionsObserver.shared.logHelper?.logEvent(["phase": "iap purchase",
                                                               "productId": product.id])
        let purchaseOptions = try await buildPurchaseOptions(options)
        TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .iapPurchase)
        let result = try await product.purchase(options: purchaseOptions)

        switch result {
        case .success(let verificationResult):
            PMLog.info("ProtonPlansManager - IAP purchase successful", sendToExternal: true)
            let transaction = try verificationResult.payloadValue
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "apple_transaction",
                                                                   "status": "success"])

            guard let matchingPlan = await findMatchingPlan(productID: transaction.productID) else {
                let error = ProtonPlansManagerError.unableToMatchProtonPlanToStoreProduct(productId: transaction.productID)
                await TransactionsObserver.shared.logHelper?.logEvent(["phase": "proton_plan_match",
                                                                       "success": false,
                                                                       "error": error.failureReason ?? error.localizedDescription],
                                                                      type: .close)
                PMLog.error("ProtonPlansManager - unable to match Proton and AppleStore plans", sendToExternal: true)
                throw error
            }

            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "proton_plan_match",
                                                                   "time": Date.now.description,
                                                                   "success": true])

            do {
                TransactionsObserver.shared.addTransactionInProgress(transaction.id)

                TransactionsObserver.shared.transactionHandler.setAppAccountToken(userTransactionUUID)
                // Omnichannel FF check
#if DEBUG
                if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled) {
                    _ = try await TransactionsObserver.shared.transactionHandler.processTransaction(transaction.toProtonTransaction(),
                                                                                                    jwsRepresentation: verificationResult.jwsRepresentation,
                                                                                                    plan: matchingPlan)
                } else {
                    _ = try await TransactionsObserver.shared.transactionHandler.processTransaction(transaction.toProtonTransaction(),
                                                                                                    plan: matchingPlan)
                }
#else
                _ = try await TransactionsObserver.shared.transactionHandler.processTransaction(transaction.toProtonTransaction(),
                                                                                                plan: matchingPlan)
#endif
                TransactionsObserver.shared.removeTransactionInProgress(transaction.id)
                await transaction.finish()
                debugPrint("Transaction completed ✅")
                await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_sub",
                                                                       "apple_transction_completed": true])
                PMLog.info("ProtonPlansManager: Proton subscription creation successful ✅", sendToExternal: true)
                return matchingPlan
            } catch {
                await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_sub",
                                                                       "error:": error.localizedDescription])
                PMLog.error("ProtonPlansManager: Create sub error: \(error.localizedDescription)", sendToExternal: true)
                TransactionsObserver.shared.removeTransactionInProgress(transaction.id)
                debugPrint(error)
                throw error
            }
        case .pending:
            // pending transactions will be returned by the TransactionObserver once the necessary requirements are fulfilled.
            // In case shouldn't trigger an error, the user should be notified.
            // Once the transaction will be ready to be processed it will be received by the TransactionObserver's Transaction.updates.
            TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .transactionPending)
            PMLog.info("ProtonPlansManager: IAP Transaction pending", sendToExternal: true)
            return nil
        case .userCancelled:
            TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .transactionCancelledByUser)
            let error = ProtonPlansManagerError.transactionCancelledByUser
            PMLog.info("ProtonPlansManager: IAP Transaction cancelled by the user", sendToExternal: true)
            throw error
        @unknown default:
            TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .unknownError)
            let error = ProtonPlansManagerError.transactionUnknownError
            PMLog.error("ProtonPlansManager: unknown IAP result error", sendToExternal: true)
            throw error
        }
    }

    public func purchaseWinBackOffer(_ product: Product, offerId: String) async throws -> ComposedPlan? {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            guard let offers = product.subscription?.winBackOffers.filter({ $0.id == offerId }), let offer = offers.first else {
                throw ProtonPlansManagerError.noOfferFound(id: offerId, offerType: Offer.Kind.Winback.rawValue)
            }
            let option: Set<Product.PurchaseOption> = [Product.PurchaseOption.winBackOffer(offer)]
            return try await purchase(product, options: option)
        } else {
            throw ProtonPlansManagerError.noOfferFound(id: offerId, offerType: Offer.Kind.Winback.rawValue)
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
            _ = try await TransactionsObserver.shared.transactionHandler.processTransaction(pendingTransaction.transaction.toProtonTransaction(), plan: matchingPlan)
            TransactionsObserver.shared.removeTransactionInProgress(pendingTransaction.transaction.id)
            await pendingTransaction.transaction.finish()
            debugPrint("RECOVERY FLOW SUCCESSFUL ✅")
        } catch {
            TransactionsObserver.shared.removeTransactionInProgress(pendingTransaction.transaction.id)
            throw error
        }
    }

    @discardableResult
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

        TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .fetchUserUUID)
        let request = try paymentsAPI.url(for: .userTransactionUUID)

        let uuidString: UserTransactionUUIDResponse = try await remoteManager.getFromURL(request.url)
        guard let uuid = UUID(uuidString: uuidString.uuid) else {
            TransactionsObserver.shared.transactionHandler.updateTransactionState(state: .unableToGetUserTransactionUUID)
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
