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
import ProtonCoreFeatureFlags
import ProtonCoreNetworking
import ProtonCoreObservability
import StoreKit

public final class TransactionHandler: NSObject, TransactionHandlerProviding, @unchecked Sendable {

    private var remoteManager: RemoteManagerProviding
    public private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    private let queue = DispatchQueue(label: "paymentsV2.transactionHandler.syncQueue")
    private var tokenContinuation: CheckedContinuation<Void, Error>?
    private var refresh: SKReceiptRefreshRequest?
    private let receiptManager: StoreKitReceiptManagerProviding
    private var appAccountToken: UUID?
    private let tokenizationMaxRetry = 2

    public init(remoteManager: RemoteManagerProviding,
                receiptManger: StoreKitReceiptManagerProviding? = nil,
                appAccountToken: UUID? = nil) {
        self.remoteManager = remoteManager
        self.receiptManager = receiptManger ?? StoreKitReceiptManager()
        self.appAccountToken = appAccountToken
    }

    public func processTransaction(_ transaction: ProtonTransaction, jwsRepresentation: String, plan: ComposedPlan) async throws -> ComposedPlan {
        assertionFailure("TransactionHandler should never call this function, this is for Omnichannel only flow")
        throw TransactionHandlerError.wrongMethodCalled
    }

    public func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan) async throws -> ComposedPlan {
        debugPrint("Transaction in progress...")

        await TransactionsObserver.shared.logHelper?.logEvent(["phase": "start_resolving_transaction"])
        try await resolveTransaction(transaction, plan: plan)

        return plan
    }

    public func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool {

        guard let uuid = self.appAccountToken else {
            PMLog.info("TransactionHandler: UUID not provided, fetching it", sendToExternal: true)

            let userUUID: UserTransactionUUIDResponse = try await remoteManager.getUserUUID()
            return appAccountToken == userUUID.uuidValue
        }
        PMLog.info("TransactionHandler: UUID check", sendToExternal: true)
        return appAccountToken == uuid
    }

    public func setAppAccountToken(_ appAccountToken: UUID?) {
        queue.sync {
            self.appAccountToken = appAccountToken
        }
    }

    public func updateTransactionState(state: TransactionHandlerState) {
        queue.sync {
            transactionState.value = state
        }
    }

    func tokenizeTransaction(_ transaction: ProtonTransactionProviding) async throws -> NewToken {

        PMLog.info("Generating validation token..", sendToExternal: true)
        let receipt = try await receiptManager.refreshReceipt()

        guard var bundleIdentifier = Bundle.main.bundleIdentifier else {
            let error = TransactionHandlerError.unableToGetBundleIdentifier
            PMLog.error("TransactionHandler: " + (error.failureReason ?? "Bundle identifier not found"), sendToExternal: true)
            TransactionsObserver.shared.logHelper?.logEventSync(["phase": "fetch_bundle_identifier",
                                                                 "status": "failed"],
                                                                type: .close)
            throw error
        }

        var transactionIdentifier = String(transaction.id)

#if DEBUG && targetEnvironment(simulator)
        let envrionment = ProcessInfo.processInfo.environment
        if envrionment["test-transaction"] == "sandbox" {
            transactionIdentifier = "test-transaction"
        }
        if let bundle = envrionment["bundleIdentifier"] {
            bundleIdentifier = bundle
        }
#endif

        updateTransactionState(state: .generatingReceipt)

        let newToken = Token(
            payment: PaymentReceipt(
                details: ReceiptDetails(
                    bundleID: bundleIdentifier,
                    productID: transaction.productID,
                    receipt: receipt,
                    transactionID: transactionIdentifier
                ),
                type: "apple-recurring"
            ),
            paymentMethodID: nil
        )

        PMLog.info("Validation token generated ✅", sendToExternal: true)
        TransactionsObserver.shared.logHelper?.logEventSync(["phase": "validation_token_creation",
                                                             "token": newToken.toDictionary()])

        debugPrint("Creating payment token..")
        updateTransactionState(state: .creatingTransactionToken)

        do {
            let newToken: NewToken = try await remoteManager.post(newToken)
            ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(status: .http2xx, isDynamic: true))
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "post_validation_token_request",
                                                                   "token": newToken.toDictionary()])
            PMLog.info("TransactionHandler: Post validation token successful", sendToExternal: true)
            updateTransactionState(state: .transactionTokenizationCompleted)
            return newToken
        } catch {
            if let error = error as? APICodeError, error == APICodeError.invalidRequirements {
                let responseError = ResponseError(httpCode: nil, responseCode: error.rawValue, userFacingMessage: "POST /tokens failed", underlyingError: nil)
                ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(error: responseError, isDynamic: true))
                PMLog.error("TransactionHandler: Post validation token failed, error: \(error.rawValue), request: POST /tokens", sendToExternal: true)

                updateTransactionState(state: .transactionProcessErrorInvalidReq)
                throw TransactionHandlerError.invalidTokenRequirements
            }

            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "post_validation_token_request",
                                                                   "status": "failed"])
            PMLog.error("TransactionHandler: Post validation token failed", sendToExternal: true)

            throw error
        }
    }
}

// MARK: Private methods
private extension TransactionHandler {

    private func createNewSubscription(token: NewToken, composedPlan: ComposedPlan, transaction: ProtonTransactionProviding) async throws -> Bool {

        guard let planName = composedPlan.plan.name else {
            let error = TransactionHandlerError.unableToFindPlanName(productID: transaction.productID)
            PMLog.error("TransactionHandler: Create new subscription - Plan name not found", sendToExternal: true)
            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "failed",
                                                                   "reason": "plan name and compose plan mismatch"],
                                                                  type: .close)
            throw error
        }
        PMLog.info("Creating new subscription..", sendToExternal: true)
        let newSub = NewSubscription(
            newValues: NewSubscriptionValues(
                amount: nil,
                paymentMethodID: nil,
                payments: nil,
                paymentToken: token.token
            ),
            subscription: Subscription(
                cycle: composedPlan.instance.cycle,
                currency: transaction.currencyIdentifier,
                currencyID: nil,
                plans: [planName: 1],
                planIDs: nil,
                codes: nil,
                couponCode: nil,
                giftCode: nil
            )
        )

        updateTransactionState(state: .createNewSubscription)

        do {
            _ = try await remoteManager.create(newSubscription: newSub)
            PMLog.info("TransactionHandler: Create new subscription - New subscription successfully created ✅", sendToExternal: true)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "success"],
                                                                  type: .close)
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .successful, isDynamic: true))
            updateTransactionState(state: .transactionCompleted(planName: planName, cycle: composedPlan.instance.cycle))
            return true
        } catch {
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .failed, isDynamic: true))
            updateTransactionState(state: .transactionProcessError)
            PMLog.error("TransactionHandler: Create new subscription - New subscription creation failed", sendToExternal: true)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "failed",
                                                                   "reason": error.localizedDescription],
                                                                  type: .close)
            throw error
        }
    }

    private func resolveTransaction(_ transaction: ProtonTransactionProviding, plan: ComposedPlan) async throws {

        var newToken: NewToken!
        var tokenizationSuccess = false
        var tokenizationCounter = 0
        repeat {
            do {
                PMLog.info("tokenization in progress...", sendToExternal: true)
                newToken = try await tokenizeTransaction(transaction)
                tokenizationSuccess = true
                PMLog.info("Tokenization successful", sendToExternal: true)
            } catch {
                PMLog.info("tokenization failed, retry: \(tokenizationCounter)", sendToExternal: true)
                tokenizationCounter += 1
                if tokenizationCounter < tokenizationMaxRetry {
                    PMLog.error("Tokenization failed with error: \(error.localizedDescription), retry number: \(tokenizationCounter)", sendToExternal: true)
                    tokenizationSuccess = false
                } else {
                    self.updateTransactionState(state: .transactionProcessError)
                    PMLog.error("TransactionHandler: transaction tokenization failed", sendToExternal: true)
                    await TransactionsObserver.shared.logHelper?.logEvent(["get_token_polling": ["time": Date.now.description,
                                                                                                 "status": "failed",
                                                                                                 "reason": (error as? LocalizedError)?.failureReason]],
                                                                          type: .close)
                    throw error
                }
            }
        } while !tokenizationSuccess

        PMLog.info("New token created ✅", sendToExternal: true)
        _ = try await createNewSubscription(token: newToken, composedPlan: plan, transaction: transaction)
    }
}
