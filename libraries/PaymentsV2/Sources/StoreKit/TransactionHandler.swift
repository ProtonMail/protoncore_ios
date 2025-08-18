//
//  TransactionHandler.swift
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
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreObservability
import StoreKit

public enum TransactionHandlerError: LocalizedError {

    case unableToFindPlanName(productID: String)
    case transactionIdNotEqualToOriginalTransactionId(originalID: UInt64, transactionId: UInt64)
    case unableToGetBundleIdentifier
    case unableToGetTransactionAmountOrCurrency(transactionId: UInt64)
    case fetchReceiptDidFail(description: String)

    public var errorDescription: String? {
        switch self {
        case .transactionIdNotEqualToOriginalTransactionId:
            return PaymentsV2Localizer.Transaction_Handler_repeated_purchase.l10n
        case .fetchReceiptDidFail:
            return PaymentsV2Localizer.Transaction_Handler_receipt_update_failed.l10n
        default:
            return PaymentsV2Localizer.Transaction_Handler_plan_not_found.l10n
        }
    }

    public var failureReason: String? {
        switch self {
        case .unableToFindPlanName(let productId):
            return "Impossible to find plan name for productId: \(productId)"
        case .transactionIdNotEqualToOriginalTransactionId(let originalId, let transactionId):
            return "\(originalId) != \(transactionId) this could indicate a repeated or renewal of an existing plan"
        case .unableToGetBundleIdentifier:
            return "App Bundle identifier not found"
        case .unableToGetTransactionAmountOrCurrency(let transactionId):
            return "Impossible to find transaction amount or currency for transactionId: \(transactionId)"
        case .fetchReceiptDidFail(let description):
            return "SKReceiptRefreshRequest failed with error: \(description)"
        }
    }
}

public enum TransactionHandlerState: String, Sendable {
    case idle
    case generatingReceipt
    case creatingTransactionToken
    case createNewSubscription
    case transactionCompleted
    // Error states:
    case transactionCancelledByUser
    case mismatchTransactionIDs
    case transactionProcessError
    case unableToGetUserTransactionUUID
    case unknownError

    public var localizedDescription: String? {
        switch self {
        default:
            return self.rawValue
        }
    }
}

public protocol TransactionHandlerProviding: Sendable {
    func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan, fail: Bool) async throws -> ComposedPlan
    func updateRemoteManager(remoteManager: RemoteManagerProviding) async
    func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool
}

public final class TransactionHandler: NSObject, TransactionHandlerProviding, @unchecked Sendable {

    private var remoteManager: RemoteManagerProviding
    private let paymentsAPIs: PaymentsAPIs
    private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    private let queue = DispatchQueue(label: "paymentsV2.transactionHandler.syncQueue")
    private var tokenContinuation: CheckedContinuation<Void, Error>?
    private var refresh: SKReceiptRefreshRequest?
    private let receiptManager: StoreKitReceiptManagerProviding

    public init(remoteManager: RemoteManagerProviding,
                paymentsAPIs: PaymentsAPIs,
                receiptManger: StoreKitReceiptManagerProviding = StoreKitReceiptManager()) {
        self.remoteManager = remoteManager
        self.paymentsAPIs = paymentsAPIs
        self.receiptManager = receiptManger
    }

    public func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan, fail: Bool = false) async throws -> ComposedPlan {
        debugPrint("Transaction in progress...")
        debugPrint(transaction.originalID)
        debugPrint(transaction.id)

        // NOTE:
        // This flag is used only in debug mode to force fail
        // a transaction after the product is has been successfully purchased on the AppleStore.
        // The purpose of the fail is testing the Apple transaction receipt recovery functionality.
        // For now the flag is internal only.
#if DEBUG
        if fail {
            debugPrint("Transaction FORCED to fail")
            throw TransactionHandlerError.unableToGetBundleIdentifier
        }
#endif

        try await receiptManager.refreshReceipt()

        guard transaction.originalID == transaction.id else {
            updateTransactionState(state: .mismatchTransactionIDs)
            let error = TransactionHandlerError.transactionIdNotEqualToOriginalTransactionId(originalID: transaction.originalID, transactionId: transaction.id)
            PMLog.error(error.failureReason ?? "Transaction: originaId (\(transaction.originalID)) different from transactionId (\(transaction.id)", sendToExternal: true)
            throw error
        }

        await TransactionsObserver.shared.logHelper.logEvent(["phase": "start_resolving_transaction"])
        try await resolveTransaction(transaction, plan: plan)

        // transaction.appAccountToken
        // add API to fetch account UUID from BE --> AccountUUID
        // if transaction.appAccountToken == AccountUUID --> Process
        return plan
    }

    public func updateRemoteManager(remoteManager: RemoteManagerProviding) {
        queue.sync {
            self.remoteManager = remoteManager
        }
    }

    public func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool {

        let request = try paymentsAPIs.url(for: .userTransactionUUID)
        debugPrint("Fetching user transaction UUID")

        let userUUID: UserTransactionUUIDResponse = try await remoteManager.getFromURL(request.url)
        return appAccountToken == userUUID.uuidValue
    }

    private func updateTransactionState(state: TransactionHandlerState) {
        let completableStates: [TransactionHandlerState] = [.transactionProcessError, .mismatchTransactionIDs, .transactionCompleted]
        queue.sync {
            transactionState.value = state
            if completableStates.contains(state) {
                transactionState.send(completion: .finished)
            }
        }
    }
}

// MARK: Private methods
private extension TransactionHandler {

    private func generateValidationTokenFromStoreKitReceipt(_ transaction: ProtonTransactionProviding) throws -> Token {

        debugPrint("Generating validation token..")
        let receipt = try receiptManager.fetchPurchaseReceipt()

        guard var bundleIdentifier = Bundle.main.bundleIdentifier else {
            debugPrint("bundle not obtainable")
            let error = TransactionHandlerError.unableToGetBundleIdentifier
            PMLog.error(error.failureReason ?? "Bundle identifier not found", sendToExternal: true)
            TransactionsObserver.shared.logHelper.logEventSync(["phase": "fetch_bundle_identifier",
                                                                "status": "failed"],
                                                               type: .close)
            throw error
        }

        var transactionIdentifier = String(transaction.originalID)

#if DEBUG && targetEnvironment(simulator)
        let envrionment = ProcessInfo.processInfo.environment
        if envrionment["test-transaction"] == "sandbox" {
            transactionIdentifier = "test-transaction"
        }
        if let bundle = envrionment["bundleIdentifier"] {
            bundleIdentifier = bundle
        }
#endif

        guard let amount = transaction.price, let currency = transaction.currencyIdentifier else {
            debugPrint("Impossible to get amount and currency from transaction")
            updateTransactionState(state: .transactionProcessError)
            let error = TransactionHandlerError.unableToGetTransactionAmountOrCurrency(transactionId: transaction.id)
            PMLog.error(error.failureReason ?? "Bundle identifier not found", sendToExternal: true)
            TransactionsObserver.shared.logHelper.logEventSync(["phase": "fetch_amount_currency",
                                                                "status": "failed"],
                                                               type: .close)
            throw error
        }

        updateTransactionState(state: .generatingReceipt)

        let formattedAmount = NSDecimalNumber(decimal: amount * 100).intValue
        let newToken = Token(amount: formattedAmount,
                             currency: currency,
                             payment: PaymentReceipt(details: ReceiptDetails(bundleID: bundleIdentifier,
                                                                             productID: transaction.productID,
                                                                             receipt: receipt,
                                                                             transactionID: transactionIdentifier),
                                                     type: "apple-recurring"),
                             paymentMethodID: nil)
        debugPrint("Validation token generated ✅")
         TransactionsObserver.shared.logHelper.logEventSync(["phase": "validation_token_creation",
                                                                  "token": newToken.toDictionary()])
        
        return newToken
    }

    private func createNewToken(_ transactionToken: Token) async throws -> NewToken {

        debugPrint("Creating payment token..")
        do {
            let request = try paymentsAPIs.url(for: .createToken(token: transactionToken))
            let newToken: NewToken = try await remoteManager.postToURL(request: request)
            ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(status: .http2xx, isDynamic: true))
            await TransactionsObserver.shared.logHelper.logEvent(["phase": "post_validation_token_request",
                                                                  "token": newToken.toDictionary()])
            return newToken
        } catch {

            if case let RemoteError.responseReturnedError(error, urlString) = error {
                let responseError = ResponseError(httpCode: nil, responseCode: error, userFacingMessage: "PaymentV2 - TransactionHandler: Error for requets: \(urlString)", underlyingError: nil)
                ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(error: responseError, isDynamic: true))
                PMLog.error("PaymentsV2 - Failed to create new token, error: \(error), url: \(urlString)", sendToExternal: true)
            }

            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper.logEvent(["phase": "post_validation_token_request",
                                                                  "status": "failed"])
            throw error
        }
    }

    private func createNewSubscription(token: NewToken, composedPlan: ComposedPlan, transaction: ProtonTransactionProviding) async throws -> Bool {

        guard let planName = composedPlan.plan.name else {
            let error = TransactionHandlerError.unableToFindPlanName(productID: transaction.productID)
            PMLog.error(error.failureReason ?? "PaymentsV2 - TransactionHandler unableToFindPlanName failure reason missing", sendToExternal: true)
            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper.logEvent(["phase": "create_new_subscription",
                                                                  "status": "failed",
                                                                  "reason": "plan name and compose plan mismatch"],
                                                                 type: .close)
            throw error
        }
        debugPrint("Creating new subscription..")
        let newSub = NewSubscription(newValues: NewSubscriptionValues(amount: nil,
                                                                      paymentMethodID: nil,
                                                                      payments: nil,
                                                                      paymentToken: token.token),
                                     subscription: Subscription(cycle: composedPlan.instance.cycle,
                                                                currency: transaction.currencyIdentifier,
                                                                currencyID: nil,
                                                                plans: [planName: 1],
                                                                planIDs: nil,
                                                                codes: nil,
                                                                couponCode: nil,
                                                                giftCode: nil))

        updateTransactionState(state: .createNewSubscription)

        do {
            let request = try paymentsAPIs.url(for: .createSubscription(newSubscription: newSub))
            _ = try await remoteManager.postToURL(request: request)
            debugPrint("New subscription successfully created ✅")
            await TransactionsObserver.shared.logHelper.logEvent(["phase": "create_new_subscription",
                                                                  "status": "success"],
                                                                 type: .close)
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .successful, isDynamic: true))
            updateTransactionState(state: .transactionCompleted)
            return true
        } catch {
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .failed, isDynamic: true))
            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper.logEvent(["phase": "create_new_subscription",
                                                                  "status": "failed",
                                                                  "reason": error.localizedDescription],
                                                                 type: .close)
            throw error
        }
    }

    private func resolveTransaction(_ transaction: ProtonTransactionProviding, plan: ComposedPlan) async throws {

        let transactionToken = try generateValidationTokenFromStoreKitReceipt(transaction)
        let newToken = try await createNewToken(transactionToken)
        debugPrint("New token created ✅")
        _ = try await createNewSubscription(token: newToken, composedPlan: plan, transaction: transaction)
    }
}
