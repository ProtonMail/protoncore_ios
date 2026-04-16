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

import Combine
import Foundation
import ProtonCoreDoh
import ProtonCoreServices
import ProtonCoreFeatureFlags
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

    var transactionProgress: CurrentValueSubject<TransactionHandlerState, Never> { get }

    func start() async throws
    func stop()
    func setConfiguration(_ configuration: TransactionsObserverConfiguration)
    func generateTransactionLog() -> URL?
    func deleteLogs()
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
    let remoteManager: RemoteManagerProviding

    public init(remoteManager: RemoteManagerProviding) {
        self.remoteManager = remoteManager
    }
}

public final class TransactionsObserver: TransactionsObserverProviding, @unchecked Sendable {

    public var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    public static let shared = TransactionsObserver()
    let logHelper: LogHelperProviding = LogHelper()
    private var configuration: TransactionsObserverConfiguration?
    @Published public private(set) var isON: Bool = false
    @Published public private(set) var transactionStatus: TransactionType = .unknown

    private var updates: Task<Void, Error>?
    private var remoteManager: RemoteManagerProviding?
    private var planComposer: PlansComposerProviding!
    var transactionHandler: TransactionHandlerProviding!
    private var transactionsInProgress = Set<UInt64>()
    private let queue = DispatchQueue(label: "ch.proton.payments.transactions.observer")
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    private func newTransactionListenerTask() -> Task<Void, Error> {
        Task(priority: .background) {
            for await unfinished in Transaction.unfinished {
                switch unfinished {
                case .verified(let transaction):
                    guard (await transaction.subscriptionStatus) != nil else {
                        PMLog.info("Transaction received is not a subscription")
                        transactionStatus = .failed
                        return
                    }

                    guard transaction.purchaseDate == transaction.originalPurchaseDate else {
                        PMLog.info("Transaction received is a renewal, no need to process it.")
                        transactionStatus = .successful
                        await transaction.finish()
                        return
                    }

                    PMLog.info("TransactionsObserver: Resolving unfinished transaction", sendToExternal: true)
                    _ = await processTransactionImmediately(transaction, jwsRepresentation: unfinished.jwsRepresentation)
                case .unverified(let transaction, let transactionError):
                    debugPrint("Unverified unfinished transaction:\n \(transaction)\n \(transactionError)")
                    return
                }
            }

            try Task.checkCancellation()

            for await update in Transaction.updates {
                switch update {
                case .verified(let transaction):
                    guard (await transaction.subscriptionStatus) != nil else {
                        PMLog.info("Transaction received is not a subscription")
                        transactionStatus = .failed
                        return
                    }

                    guard transaction.purchaseDate == transaction.originalPurchaseDate else {
                        PMLog.info("Transaction received is a renewal, no need to process it.")
                        transactionStatus = .successful
                        await transaction.finish()
                        return
                    }

                    PMLog.info("TransactionsObserver: Resolving transaction", sendToExternal: true)
                    _ = await processTransactionImmediately(transaction, jwsRepresentation: update.jwsRepresentation)
                case .unverified(let transaction, let transactionError):
                    PMLog.info("Unverified update transaction:\n \(transaction)\n \(transactionError)", sendToExternal: true)
                    debugPrint("Unverified update transaction:\n \(transaction)\n \(transactionError)")
                    return
                }
            }

            PMLog.info("Exited transaction update observer loops")
        }
    }

    // MARK: Private functions
    private func initRequiredComponents() async throws {

        guard let config = configuration else {
            let error = TransactionsObserverError.missingOrInvalidConfiguration
            PMLog.error(error.failureReason ?? "No configuration provided to PaymentsV2 - TransactionObserver", sendToExternal: true)
            throw error
        }

        self.remoteManager = config.remoteManager

        guard let remoteManager = self.remoteManager else {
            let error = TransactionsObserverError.requiredSubComponentInitFailed
            PMLog.error(error.failureReason ?? "Impossible to initilize sub-components required by PaymentsV2 - TransactionObserver", sendToExternal: true)
            throw error
        }

#if DEBUG
        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled) {
            PMLog.info("TransactionsObserver: Omnichannel flow started")
            self.transactionHandler = OCTransactionHandler(remoteManager: remoteManager)
        } else {
            PMLog.info("TransactionsObserver: Legacy flow started")
            self.transactionHandler = TransactionHandler(remoteManager: remoteManager)
        }
#else
        self.transactionHandler = TransactionHandler(remoteManager: remoteManager)
#endif
        self.transactionHandler.transactionState.sink { [weak self] state in
            self?.transactionProgress.send(state)
        }
        .store(in: &cancellables)

        self.planComposer = PlansComposer(remoteManager: remoteManager)
        _ = try await self.planComposer.fetchProtonPlans()
    }

    private func processTransaction(_ transaction: Transaction, jwsRepresentation: String) async {

        do {
            if !planComposer.hasData {
                _ = try await planComposer.fetchAvailablePlans()
            }

            guard let plan = planComposer.matchPlanToStoreProduct(transaction.productID), let appAccountToken = transaction.appAccountToken else {
                return
            }

            guard let accountMatching = try await transactionHandler?.verifyTransactionUUIDs(appAccountToken: appAccountToken) else {
                transactionStatus = .unableToVerifyAccountsUUIDs
                return
            }
            if accountMatching {
                // Omnichannel FF check
#if DEBUG
                if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.paymentsOmnichannelEnabled) {
                    _ = try await transactionHandler?.processTransaction(transaction.toProtonTransaction(),
                                                                         jwsRepresentation: jwsRepresentation,
                                                                         plan: plan)
                } else {
                    _ = try await transactionHandler?.processTransaction(transaction.toProtonTransaction(),
                                                                         plan: plan)
                }
#else
                _ = try await transactionHandler?.processTransaction(transaction.toProtonTransaction(),
                                                                     plan: plan)
#endif
                await transaction.finish()
                transactionStatus = .successful
                
                logHelper.logEvent(["phase": "create_sub", "apple_transaction_completed": true])
                PMLog.info("ProtonPlansManager: Proton subscription creation successful ✅", sendToExternal: true)
            } else {
                transactionStatus = .transactionUUIDNotFoundOrMismatching
                return
            }
        } catch {
            PMLog.info("Unable to process transaction: \(error)")

            if let error = error as? APICodeError, error == APICodeError.invalidRequirements {
                await transaction.finish()
                transactionStatus = .alreadyProcessed
                return
            }
            transactionStatus = .failed
        }
    }

    @discardableResult
    func beginProcessingTransaction(id: UInt64) -> Bool {
        queue.sync {
            let (inserted, _) = transactionsInProgress.insert(id)
            PMLog.info("transaction: \(id) added to process queue", sendToExternal: true)
            return inserted
        }
    }

    func endProcessingTransaction(id: UInt64) {
        queue.sync {
            transactionsInProgress.remove(id)
            PMLog.info("transaction: \(id) removed from process queue", sendToExternal: true)
        }
    }

    // MARK: Public methods

    @discardableResult
    public func processTransactionImmediately(_ transaction: Transaction, jwsRepresentation: String) async -> Bool {
        guard beginProcessingTransaction(id: transaction.id) else {
            PMLog.info("Transaction already in progress, skipping immediate processing", sendToExternal: true)
            return false
        }
        defer { endProcessingTransaction(id: transaction.id) }

        PMLog.info("Processing transaction started at \(Date.now)", sendToExternal: true)
        await processTransaction(transaction, jwsRepresentation: jwsRepresentation)
        PMLog.info("Processing transaction completed at \(Date.now)", sendToExternal: true)
        return true
    }

    public func start() async throws {
        let isOn: Bool = await withCheckedContinuation { c in
            queue.async {
                let value = self.isON
                self.isON = true
                c.resume(returning: value)
            }
        }

        guard !isOn else {
            PMLog.info("TransactionsObserver already running, nothing to start")
            return
        }

        do {
            try await initRequiredComponents()
        } catch {
            PMLog.info("Aborting TransactionsObserver start due to error: \(error)")
            queue.async { self.isON = false }
            throw error
        }

        guard let planComposer = planComposer, transactionHandler != nil else {
            assertionFailure("TransactionsObserver: TransactionsObserverConfiguration required to start the observer")
            let error = TransactionsObserverError.requiredSubComponentInitFailed
            PMLog.error(error.failureReason ?? "Impossible to initilize sub-components required by PaymentsV2 - TransactionObserver", sendToExternal: true)
            throw error
        }

        if !planComposer.hasData {
            do {
                _ = try await planComposer.fetchAvailablePlans()
            } catch {
                // Don't cause this to fail to initialize the transaction listener task, plans also get fetched later
                PMLog.error("Couldn't fetch available plans: \(error)", sendToExternal: true)
            }
        }

        updates?.cancel()
        updates = newTransactionListenerTask()

        PMLog.info("TransactionsObserver started ✅", sendToExternal: true)
    }

    public func stop() {
        updates?.cancel()

        queue.async {
            self.isON = false
        }
    }

    public func setConfiguration(_ configuration: TransactionsObserverConfiguration) {
        queue.sync {
            self.configuration = configuration
        }
    }

    public func generateTransactionLog() -> URL? {
        return logHelper.returnTransactionLog()
    }

    public func deleteLogs() {
        logHelper.deleteLog()
    }
}
