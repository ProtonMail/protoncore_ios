//
//  OCTransactionHandler.swift
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

public final class OCTransactionHandler: NSObject, TransactionHandlerProviding, @unchecked Sendable {

    private var remoteManager: RemoteManagerProviding
    private let paymentsAPIs: PaymentsAPIs
    public private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    private let queue = DispatchQueue(label: "paymentsV2.transactionHandler.syncQueue")
    private var tokenContinuation: CheckedContinuation<Void, Error>?

    public init(remoteManager: RemoteManagerProviding,
                paymentsAPIs: PaymentsAPIs) {
        self.remoteManager = remoteManager
        self.paymentsAPIs = paymentsAPIs
    }

    public func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan) async throws -> ComposedPlan {
        assertionFailure("OCTransactionHandler should never call this function, this is not part of the Omnichannel flow")
        throw TransactionHandlerError.wrongMethodCalled
    }

    public func processTransaction(_ transaction: ProtonTransaction,
                                   jwsRepresentation: String,
                                   plan: ComposedPlan) async throws -> ComposedPlan {
        debugPrint("Transaction in progress...")
        debugPrint(transaction.originalID)
        debugPrint(transaction.id)

        guard transaction.originalID == transaction.id else {
            updateTransactionState(state: .mismatchTransactionIDs)
            let error = TransactionHandlerError.transactionIdNotEqualToOriginalTransactionId(originalID: transaction.originalID, transactionId: transaction.id)
            PMLog.error(error.failureReason ?? "Transaction: originaId (\(transaction.originalID)) different from transactionId (\(transaction.id)", sendToExternal: true)
            throw error
        }

        await TransactionsObserver.shared.logHelper?.logEvent(["phase": "start_resolving_transaction"])
        try await resolveTransaction(transaction, plan: plan, jwsRepresentation: jwsRepresentation)

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
private extension OCTransactionHandler {

    private func generateValidationTokenFromStoreKitReceipt(_ transaction: ProtonTransactionProviding, jwsRepresentation: String) throws -> OCToken {

        debugPrint("Generating validation token..")

#if DEBUG && targetEnvironment(simulator)
        // TODO: Refactor this to make it testable
        //        let envrionment = ProcessInfo.processInfo.environment
        //        if envrionment["test-transaction"] == "sandbox" {
        //            transactionIdentifier = "test-transaction"
        //        }
        //        if let bundle = envrionment["bundleIdentifier"] {
        //            bundleIdentifier = bundle
        //        }
#endif
        updateTransactionState(state: .generatingReceipt)

        let newToken = OCToken(payment: OCPaymentReceipt(details: OCReceiptDetails(jws: jwsRepresentation)))

        debugPrint("Validation token generated ✅")
        TransactionsObserver.shared.logHelper?.logEventSync(["phase": "validation_token_creation",
                                                             "token": newToken.toDictionary()])
        print("NEW TOKEN:\n", newToken)
        return newToken
    }

    private func createNewToken(_ transactionToken: OCToken) async throws -> NewToken {

        debugPrint("Creating payment token..")
        do {
            let request = try paymentsAPIs.url(for: .createOCToken(token: transactionToken))
            let newToken: NewToken = try await remoteManager.postToURL(request: request)
            ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(status: .http2xx, isDynamic: true))
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "post_validation_token_request",
                                                                   "token": newToken.toDictionary()])

            print("POST NEW TOKEN:\n", newToken)
            return newToken
        } catch {

            if case let RemoteError.responseReturnedError(error, urlString) = error {
                let responseError = ResponseError(httpCode: nil, responseCode: error, userFacingMessage: "PaymentV2 - TransactionHandler: Error for requets: \(urlString)", underlyingError: nil)
                ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(error: responseError, isDynamic: true))
                PMLog.error("PaymentsV2 - Failed to create new token, error: \(error), url: \(urlString)", sendToExternal: true)
            }

            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "post_validation_token_request",
                                                                   "status": "failed"])
            print(error)
            throw error
        }
    }

    private func getToken(token: NewToken) async throws {

        debugPrint("Transaction validation..")
        updateTransactionState(state: .waitingTokenResponse)
        var expectedStatus = 0
        repeat {
            do {
                let request = try self.paymentsAPIs.url(for: .getToken(token: token.token))
                let status: ResponseStatus = try await self.remoteManager.getFromURL(request.url)
                if status.status == 1 {
                    debugPrint("Transaction validated ✅")
                    await TransactionsObserver.shared.logHelper?.logEvent(["get_token_polling": ["time": Date.now.description,
                                                                                                 "status": "success"]])
                    expectedStatus = 1
                } else {
                    debugPrint("Pending validation results..")
                }
            } catch {
                self.updateTransactionState(state: .transactionProcessError)
                await TransactionsObserver.shared.logHelper?.logEvent(["get_token_polling": ["time": Date.now.description,
                                                                                             "status": "failed",
                                                                                             "reason": (error as? LocalizedError)?.failureReason]],
                                                                      type: .close)
                print(error)
                throw error
            }
        } while expectedStatus != 1
    }

    private func createNewSubscription(token: NewToken, composedPlan: ComposedPlan, transaction: ProtonTransactionProviding) async throws -> Bool {

        guard let planName = composedPlan.plan.name else {
            let error = TransactionHandlerError.unableToFindPlanName(productID: transaction.productID)
            PMLog.error(error.failureReason ?? "PaymentsV2 - TransactionHandler unableToFindPlanName failure reason missing", sendToExternal: true)
            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "failed",
                                                                   "reason": "plan name and compose plan mismatch"],
                                                                  type: .close)
            print(error)
            throw error
        }
        debugPrint("Creating new subscription..")
        let newSub = OCNewSubscription(newValues: OCNewSubscriptionValues(paymentToken: token.token),
                                       subscription: OCSubscription(cycle: composedPlan.instance.cycle,
                                                                    currency: transaction.currencyIdentifier,
                                                                    plans: [planName: 1]))

        updateTransactionState(state: .createNewSubscription)
        print("NEW SUB:\n", newSub)

        do {
            let request = try paymentsAPIs.url(for: .createOmnichannelSubscription(newSubscription: newSub))
            _ = try await remoteManager.postToURL(request: request)
            debugPrint("New subscription successfully created ✅")
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "success"],
                                                                  type: .close)
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .successful, isDynamic: true))
            updateTransactionState(state: .transactionCompleted)
            return true
        } catch {
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .failed, isDynamic: true))
            updateTransactionState(state: .transactionProcessError)
            await TransactionsObserver.shared.logHelper?.logEvent(["phase": "create_new_subscription",
                                                                   "status": "failed",
                                                                   "reason": error.localizedDescription],
                                                                  type: .close)
            print(error)
            throw error
        }
    }

    private func resolveTransaction(_ transaction: ProtonTransactionProviding, plan: ComposedPlan, jwsRepresentation: String) async throws {

        let transactionToken = try generateValidationTokenFromStoreKitReceipt(transaction,
                                                                              jwsRepresentation: jwsRepresentation)
        let newToken = try await createNewToken(transactionToken)
        try await getToken(token: newToken)
        _ = try await self.createNewSubscription(token: newToken, composedPlan: plan, transaction: transaction)
    }
}
