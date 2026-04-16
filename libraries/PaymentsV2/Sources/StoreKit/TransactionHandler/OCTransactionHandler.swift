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
    public private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    private let queue = DispatchQueue(label: "paymentsV2.transactionHandler.syncQueue")
    private var appAccountToken: UUID?
    private let tokenStatusMaxPollAttempts = 30
    private let tokenStatusPollInterval: Duration = .seconds(1)

    public init(remoteManager: RemoteManagerProviding,
                appAccountToken: UUID? = nil) {
        self.remoteManager = remoteManager
        self.appAccountToken = appAccountToken
    }

    public func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan) async throws -> ComposedPlan {
        assertionFailure("OCTransactionHandler should never call this function, this is not part of the Omnichannel flow")
        throw TransactionHandlerError.wrongMethodCalled
    }

    public func processTransaction(_ transaction: ProtonTransaction,
                                   jwsRepresentation: String,
                                   plan: ComposedPlan) async throws -> ComposedPlan {
        debugPrint("Transaction in progress...")

        TransactionsObserver.shared.logHelper.logEvent(["phase": "start_resolving_transaction"])
        try await resolveTransaction(transaction, plan: plan, jwsRepresentation: jwsRepresentation)

        return plan
    }

    public func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool {

        guard let uuid = self.appAccountToken else {
            PMLog.info("OCTransactionHandler: UUID not provided, fetching it", sendToExternal: true)
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
}

// MARK: Private methods
private extension OCTransactionHandler {

    private func generateValidationTokenFromStoreKitReceipt(_ transaction: ProtonTransactionProviding, jwsRepresentation: String) throws -> OCToken {

        debugPrint("Generating validation token..")
        updateTransactionState(state: .generatingReceipt)

        let newToken = OCToken(payment: OCPaymentReceipt(details: OCReceiptDetails(jws: jwsRepresentation)))

        debugPrint("Validation token generated ✅")
        TransactionsObserver.shared.logHelper.logEvent([
            "phase": "validation_token_creation",
            "token": newToken.toDictionary(),
        ])
        PMLog.info("OCTransactionHandler: Validation token generated", sendToExternal: true)

        return newToken
    }

    private func createNewToken(_ transactionToken: OCToken) async throws -> NewToken {

        debugPrint("Creating payment token..")
        do {
            let newToken: NewToken = try await remoteManager.post(transactionToken)

            ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(status: .http2xx, isDynamic: true))
            TransactionsObserver.shared.logHelper.logEvent([
                "phase": "post_validation_token_request",
                "token": newToken.toDictionary(),
            ])
            PMLog.info("OCTransactionHandler: Post validation token successful", sendToExternal: true)

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
            
            TransactionsObserver.shared.logHelper.logEvent([
                "phase": "post_validation_token_request",
                "status": "failed",
            ])
            PMLog.error("OCTransactionHandler: Post validation token failed", sendToExternal: true)

            throw error
        }
    }

    private func getToken(token: NewToken) async throws {
        debugPrint("Transaction validation..")
        updateTransactionState(state: .waitingTokenResponse)

        for attempt in 1...tokenStatusMaxPollAttempts {
            let status = try await self.remoteManager.fetch(token: token.token)

            if status.status == 1 {
                debugPrint("Transaction validated ✅")
                PMLog.info("OCTransactionHandler: Polling token status success", sendToExternal: true)
                TransactionsObserver.shared.logHelper.logEvent([
                    "get_token_polling": ["time": Date.now.description, "status": "success"],
                ])

                return
            }

            debugPrint("Pending validation results..")
            if attempt < tokenStatusMaxPollAttempts {
                try await Task.sleep(for: tokenStatusPollInterval)
            }
        }

        updateTransactionState(state: .transactionProcessError)
        PMLog.error("OCTransactionHandler: Polling token status timed out", sendToExternal: true)
        TransactionsObserver.shared.logHelper.logEvent([
            "get_token_polling": ["time": Date.now.description, "status": "timed_out"],
        ])
        throw TransactionHandlerError.tokenStatusPollingTimedOut
    }

    private func createNewSubscription(token: NewToken, composedPlan: ComposedPlan, transaction: ProtonTransactionProviding) async throws -> Bool {

        guard let planName = composedPlan.plan.name else {
            let error = TransactionHandlerError.unableToFindPlanName(productID: transaction.productID)
            updateTransactionState(state: .transactionProcessError)
            PMLog.error("OCTransactionHandler: Create new subscription - Plan name not found", sendToExternal: true)
            TransactionsObserver.shared.logHelper.logEvent([
                "phase": "create_new_subscription",
                "status": "failed",
                "reason": "Plan name not found",
            ])

            throw error
        }
        debugPrint("Creating new subscription..")
        let newSub = OCNewSubscription(newValues: OCNewSubscriptionValues(paymentToken: token.token),
                                       subscription: OCSubscription(cycle: composedPlan.instance.cycle,
                                                                    currency: transaction.currencyIdentifier,
                                                                    plans: [planName: 1]))

        updateTransactionState(state: .createNewSubscription)

        do {
            _ = try await remoteManager.create(newOCSubscription: newSub)
            debugPrint("New subscription successfully created ✅")
            PMLog.info("OCTransactionHandler: Create new subscription - New subscription successfully created ✅", sendToExternal: true)
            TransactionsObserver.shared.logHelper.logEvent([
                "phase": "create_new_subscription",
                "status": "success",
            ])
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .successful, isDynamic: true))
            updateTransactionState(state: .transactionCompleted(planName: planName, cycle: composedPlan.instance.cycle))

            return true
        } catch {
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .failed, isDynamic: true))
            updateTransactionState(state: .transactionProcessError)
            PMLog.error("OCTransactionHandler: Create new subscription - New subscription creation failed", sendToExternal: true)
            TransactionsObserver.shared.logHelper.logEvent([
                "phase": "create_new_subscription",
                "status": "failed",
                "reason": error.localizedDescription,
            ])

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
