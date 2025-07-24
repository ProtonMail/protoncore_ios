//
//  TransactionsObserver.swift
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

import Foundation
import ProtonCoreDoh
import ProtonCoreLog
import StoreKit

public enum TransactionType {
    case successful
    case failed
    case renewal
    case alreadyProcessed
    case transactionUUIDNotFoundOrMismatching
    case unableToVerifyAccountsUUIDs
    case unknown
}

public protocol TransactionsObserverProviding: Sendable {
    func start() async throws
    func stop()
    func setConfiguration(_ configuration: TransactionsObserverConfiguration)
    func addTransactionInProgress(_ transactionId: UInt64)
    func removeTransactionInProgress(_ transactionId: UInt64)
    func generateTransactionLog() -> URL?
}

public enum TransactionsObserverError: LocalizedError {
    case missingOrInvalidConfiguration
    case requiredSubComponentInitFailed

    public var failureReason: String? {
        switch self {
        case .missingOrInvalidConfiguration:
            return "No configuration find for PaymentsV2 - TransactionObserver"
        case .requiredSubComponentInitFailed:
            return "Impossible to initilize sub-components required by PaymentsV2 - TransactionObserver"
        }
    }
}

public struct TransactionsObserverConfiguration: Sendable {
    let sessionID: String
    let authToken: String
    let appVersion: String
    let doh: DoHInterface & ServerConfig

    public init(sessionID: String,
                authToken: String,
                appVersion: String,
                doh: DoHInterface & ServerConfig) {
        self.sessionID = sessionID
        self.authToken = authToken
        self.appVersion = appVersion
        self.doh = doh
    }
}

public final class TransactionsObserver: TransactionsObserverProviding, @unchecked Sendable {

    public static let shared = TransactionsObserver()
    public var logHelper = LogHelper()
    private var configuration: TransactionsObserverConfiguration?
    @Published public private(set) var isON: Bool = false
    @Published public private(set) var transactionStatus: TransactionType = .unknown

    private var updates: Task<Void, Never>?
    private var remoteManager: RemoteManagerProviding?
    private var paymentsAPI: PaymentsAPIs?
    private var planComposer: PlansComposerProviding?
    private var transactionHandler: TransactionHandler?
    private var transactionsInProgress = Set<UInt64>()
    private let queue = DispatchQueue(label: "paymentsV2.transactionObserver.syncQueue")

    private init() {}

    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {

            for await unfinished in Transaction.unfinished {
                switch unfinished {
                case .verified(let transaction):
                    guard !transactionsInProgress.contains(transaction.id) else {
                        debugPrint("Transaction already in progress, no action required")
                        return
                    }
                    guard (await transaction.subscriptionStatus) != nil else {
                        debugPrint("Transaction received is not a subscription")
                        transactionStatus = .failed
                        return
                    }
                    await processTransaction(transaction)
                case .unverified(let transaction, let transactionError):
                    debugPrint("Unverified unfinished transaction:\n \(transaction)\n \(transactionError)")
                    return
                }
            }

            for await update in Transaction.updates {
                switch update {
                case .verified(let transaction):
                    guard let status = await transaction.subscriptionStatus else {
                        debugPrint("Transaction received is not a subscription")
                        return
                    }
                    switch status.state {
                    case .subscribed:
                        debugPrint("Transaction already processed")
                        return
                    default:
                        debugPrint("Transaction state: \(status.state)")
                    }
                case .unverified(let transaction, let transactionError):
                    debugPrint("Unverified update transaction:\n \(transaction)\n \(transactionError)")
                    return
                }
            }
        }
    }

    // MARK: Private functions
    private func initRequiredComponents() throws {

        guard let config = configuration else {
            let error = TransactionsObserverError.missingOrInvalidConfiguration
            PMLog.error(error.failureReason ?? "No configuration provided to PaymentsV2 - TransactionObserver", sendToExternal: true)
            throw error
        }

        self.remoteManager = RemoteManager(sessionID: config.sessionID,
                                           authToken: config.authToken,
                                           appVersion: config.appVersion,
                                           atlasSecret: config.doh.getProxyToken())
        self.paymentsAPI = PaymentsAPIs(doh: config.doh)

        guard let remoteManager = self.remoteManager, let paymentsAPI = self.paymentsAPI else {
            let error = TransactionsObserverError.requiredSubComponentInitFailed
            PMLog.error(error.failureReason ?? "Impossible to initilize sub-components required by PaymentsV2 - TransactionObserver", sendToExternal: true)
            throw error
        }

        self.transactionHandler = TransactionHandler(remoteManager: remoteManager, paymentsAPIs: paymentsAPI)
        self.planComposer = PlansComposer(remoteManager: remoteManager, paymentsAPIs: paymentsAPI)
    }

    private func processTransaction(_ transaction: Transaction) async {

        guard let plan = planComposer?.matchPlanToStoreProduct(transaction.productID), let appAccountToken = transaction.appAccountToken else {
            return
        }
        do {
            guard let accountMatching = try await transactionHandler?.verifyTransactionUUIDs(appAccountToken: appAccountToken) else {
                transactionStatus = .unableToVerifyAccountsUUIDs
                return
            }
            if accountMatching {
                _ = try await transactionHandler?.processTransaction(transaction.toProtonTransaction(), plan: plan)
                await transaction.finish()
                transactionStatus = .successful
            } else {
                transactionStatus = .transactionUUIDNotFoundOrMismatching
                return
            }
        } catch {
            debugPrint(error)

            if let error = error as? APICodeError, error == APICodeError.invalidRequirements {
                await transaction.finish()
                transactionStatus = .alreadyProcessed
                return
            }
            transactionStatus = .failed
        }
    }

    // MARK: Public methods

    public func start() async throws {
        if !isON {
            try initRequiredComponents()

            guard let planComposer = planComposer, transactionHandler != nil else {
                assertionFailure("TransactionsObserver: TransactionsObserverConfiguration required to start the observer")
                let error = TransactionsObserverError.requiredSubComponentInitFailed
                PMLog.error(error.failureReason ?? "Impossible to initilize sub-components required by PaymentsV2 - TransactionObserver", sendToExternal: true)
                throw error
            }

            if !planComposer.hasData {
                _ = try await planComposer.fetchAvailablePlans()
            }
            updates?.cancel()
            updates = newTransactionListenerTask()
            isON = true
            debugPrint("TransactionsObserver started: \(isON) ✅")
        } else {
            debugPrint("TransactionsObserver already running, nothing to start")
        }
    }

    public func stop() {
        if isON {
            updates?.cancel()
            isON = false
            debugPrint("TransactionsObserver stopped 🛑")
        } else {
            debugPrint("TransactionsObserver not started, nothing to stop 👍🏻")
        }
    }

    public func setConfiguration(_ configuration: TransactionsObserverConfiguration) {
        queue.sync {
            self.configuration = configuration
        }
    }

    public func addTransactionInProgress(_ transactionId: UInt64) {
        queue.sync {
            _ = self.transactionsInProgress.insert(transactionId)
        }
    }

    public func removeTransactionInProgress(_ transactionId: UInt64) {
        queue.sync {
            _ = self.transactionsInProgress.remove(transactionId)
        }
    }

    public func generateTransactionLog() -> URL? {
        logHelper.returnTransactionLog()
    }
}
