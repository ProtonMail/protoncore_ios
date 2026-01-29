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
    private var transactionIdInProgress: UInt64 = 0

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
        queue.sync {
            transactionIdInProgress = transaction.id
        }

        // Adding the transactions to the set of the resolved ones
        TransactionsObserver.shared.addTransactionInProgress(transactionIdInProgress)

        await TransactionsObserver.shared.logHelper?.logEvent(["phase": "start_resolving_transaction"])
        try await resolveTransaction(transaction, plan: plan)

        return plan
    }

    public func updateRemoteManager(remoteManager: RemoteManagerProviding) {
        queue.sync {
            self.remoteManager = remoteManager
        }
    }

    public func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool {

        guard let uuid = self.appAccountToken else {
            PMLog.info("TransactionHandler: UUID not provided, fetching it", sendToExternal: true)

            let userUUID: UserTransactionUUIDResponse = try await remoteManager.getUserUUID()
            return appAccountToken == userUUID.uuidValue
        }
        PMLog.info("OCTransactionHandler: UUID check", sendToExternal: true)
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

    func generateValidationTokenFromStoreKitReceipt(_ transaction: ProtonTransactionProviding) async throws -> Token {

        debugPrint("Generating validation token..")
        let receipt = try await receiptManager.refreshReceipt()

        guard var bundleIdentifier = Bundle.main.bundleIdentifier else {
            debugPrint("bundle not obtainable")
            let error = TransactionHandlerError.unableToGetBundleIdentifier
            PMLog.error("TransactionHandler: " + (error.failureReason ?? "Bundle identifier not found"), sendToExternal: true)
            TransactionsObserver.shared.logHelper?.logEventSync(["phase": "fetch_bundle_identifier",
                                                                 "status": "failed"],
                                                                type: .close)
            TransactionsObserver.shared.removeTransactionInProgress(transactionIdInProgress)
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

        debugPrint("Validation token generated ✅")
        TransactionsObserver.shared.logHelper?.logEventSync(["phase": "validation_token_creation",
                                                             "token": newToken.toDictionary()])
        PMLog.info("TransactionHandler: Validation token generated", sendToExternal: true)

        return newToken
    }
}

// MARK: Private methods
private extension TransactionHandler {

    private func createNewToken(_ transactionToken: Token) async throws -> NewToken {

        debugPrint("Creating payment token..")
        updateTransactionState(state: .creatingTransactionToken)

        do {
            let newToken: NewToken = try await remoteManager.post(transactionToken)
            ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(status: .http2xx, isDynamic: true))
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "post_validation_token_request",
                                                                   "token": newToken.toDictionary()])
            PMLog.info("TransactionHandler: Post validation token successful", sendToExternal: true)
            return newToken
        } catch {
            TransactionsObserver.shared.removeTransactionInProgress(transactionIdInProgress)
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

    private func createNewSubscription(token: NewToken, composedPlan: ComposedPlan, transaction: ProtonTransactionProviding) async throws -> Bool {

        guard let planName = composedPlan.plan.name else {
            let error = TransactionHandlerError.unableToFindPlanName(productID: transaction.productID)
            PMLog.error("TransactionHandler: Create new subscription - Plan name not found", sendToExternal: true)
            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "failed",
                                                                   "reason": "plan name and compose plan mismatch"],
                                                                  type: .close)

            TransactionsObserver.shared.removeTransactionInProgress(transactionIdInProgress)
            throw error
        }
        debugPrint("Creating new subscription..")
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
            debugPrint("New subscription successfully created ✅")
            PMLog.info("TransactionHandler: Create new subscription - New subscription successfully created ✅", sendToExternal: true)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "success"],
                                                                  type: .close)
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .successful, isDynamic: true))
            updateTransactionState(state: .transactionCompleted(planName: planName, cycle: composedPlan.instance.cycle))
            return true
        } catch {
            TransactionsObserver.shared.removeTransactionInProgress(transactionIdInProgress)
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

        debugPrint(FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled))

        let transactionToken = try await generateValidationTokenFromStoreKitReceipt(transaction)
        let newToken = try await createNewToken(transactionToken)
        debugPrint("New token created ✅")
        _ = try await createNewSubscription(token: newToken, composedPlan: plan, transaction: transaction)
    }
}
