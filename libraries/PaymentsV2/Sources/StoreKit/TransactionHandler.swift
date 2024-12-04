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
import ProtonCoreObservability
import ProtonCoreNetworking
import StoreKit

public enum TransactionHandlerError: Error {

    case unableToCreateRequest
    case unableToFindPlanName
    case unableToFindMatchingPlan
    case transactionIdNotEqualToOriginalTransactionId
    case userTransactionUUIDNotMatching
    case unableToGetBundleIdentifier
    case unableToGetTransactionAmountOrCurrency
}

public enum TransactionHandlerState: String {
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

public final class TransactionHandler {

    private var remoteManager: RemoteManagerProviding
    private let paymentsAPIs: PaymentsAPIs
    private let receiptManager: StoreKitReceiptManagerProviding
    private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

    public init(remoteManager: RemoteManagerProviding,
                paymentsAPIs: PaymentsAPIs,
                receiptManager: StoreKitReceiptManagerProviding = StoreKitReceiptManager()) {
        self.remoteManager = remoteManager
        self.paymentsAPIs = paymentsAPIs
        self.receiptManager = receiptManager
    }

    public func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan) async throws -> ComposedPlan {
        debugPrint("Transaction in progress...")
        debugPrint(transaction.originalID)
        debugPrint(transaction.id)
        guard transaction.originalID == transaction.id else {
            transactionState.value = .mismatchTransactionIDs
            transactionState.send(completion: .finished)
            throw TransactionHandlerError.transactionIdNotEqualToOriginalTransactionId
        }

        try await resolveTransaction(transaction, plan: plan)

        // transaction.appAccountToken
        // add API to fetch account UUID from BE --> AccountUUID
        // if transaction.appAccountToken == AccountUUID --> Process
        return plan
    }

    public func updateRemoteManager(remoteManager: RemoteManagerProviding) {
        self.remoteManager = remoteManager
    }

    public func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool {

        guard let request = try? paymentsAPIs.url(for: .userTransactionUUID) else {
            throw TransactionHandlerError.unableToCreateRequest
        }
        debugPrint("Fetching user transaction UUID")

        let userUUID: UserTransactionUUIDResponse = try await remoteManager.getFromURL(request.url)
        return appAccountToken == userUUID.uuidValue
    }
}

// MARK: Private methods
private extension TransactionHandler {

    private func generateValidationTokenFromStoreKitReceipt(_ transaction: ProtonTransactionProviding) throws -> Token {

        debugPrint("Generating validation token..")

        let receipt = try receiptManager.fetchPurchaseReceipt()

        let transactionIdentifier = transaction.originalID
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            debugPrint("bundle not obtainable")
            throw TransactionHandlerError.unableToGetBundleIdentifier
        }

        guard let amount = transaction.price, let currency = transaction.currencyIdentifier else {
            debugPrint("Impossible to get amount and currency from transaction")
            transactionState.value = .transactionProcessError
            transactionState.send(completion: .finished)
            throw TransactionHandlerError.unableToGetTransactionAmountOrCurrency
        }

        transactionState.send(.generatingReceipt)

        let formattedAmount = NSDecimalNumber(decimal: amount * 100).intValue
        let newToken = Token(amount: formattedAmount,
                             currency: currency,
                             payment: PaymentReceipt(details: ReceiptDetails(bundleID: bundleIdentifier,
                                                                             productID: transaction.productID,
                                                                             receipt: receipt,
                                                                             transactionID: String(transactionIdentifier)),
                                                     type: "apple-recurring"),
                             paymentMethodID: nil)
        debugPrint("Validation token generated ✅")
        return newToken
    }

    private func createNewToken(_ transactionToken: Token) async throws -> NewToken {

        guard let request = try? paymentsAPIs.url(for: .createToken(token: transactionToken)) else {
            transactionState.value = .transactionProcessError
            transactionState.send(completion: .finished)
            throw TransactionHandlerError.unableToCreateRequest
        }
        debugPrint("Creating payment token..")
        do {
            let newToken: NewToken = try await remoteManager.postToURL(request: request)
            ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(status: .http2xx, isDynamic: true))
            return newToken
        } catch {
            if let responseError = error as? ResponseError {
                ObservabilityEnv.report(.paymentCreatePaymentTokenTotal(error: responseError, isDynamic: true))
            }
            transactionState.value = .transactionProcessError
            transactionState.send(completion: .finished)
            throw error
        }
    }

    private func createNewSubscription(token: NewToken, composedPlan: ComposedPlan, transaction: ProtonTransactionProviding) async throws -> Bool {

        guard let planName = composedPlan.plan.name else {
            transactionState.value = .transactionProcessError
            transactionState.send(completion: .finished)
            throw TransactionHandlerError.unableToFindPlanName
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

        guard let request = try? paymentsAPIs.url(for: .createSubscription(newSubscription: newSub)) else {
            transactionState.value = .transactionProcessError
            transactionState.send(completion: .finished)
            throw TransactionHandlerError.unableToCreateRequest
        }

        transactionState.send(.createNewSubscription)

        do {
            _ = try await remoteManager.postToURL(request: request)
            debugPrint("New subscription successfully created ✅")
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .successful, isDynamic: true))
            transactionState.value = .transactionCompleted
            transactionState.send(completion: .finished)
            return true
        } catch {
            ObservabilityEnv.report(.paymentSubscribeTotal(status: .failed, isDynamic: true))
            transactionState.value = .transactionProcessError
            transactionState.send(completion: .finished)
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
