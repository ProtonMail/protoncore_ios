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

public protocol TransactionsObserverProviding {
    func start() async throws
    func stop()
    func setConfiguration(_ configuration: TransactionsObserverConfiguration)
}

public enum TransactionsObserverError: Error {
    case missingOrInvalidConfiguration
    case impossibleToResolveRunningEnvironment
    case requiredSubComponentInitFailed
}

public struct TransactionsObserverConfiguration {
    let sessionID: String
    let authToken: String
    let appVersion: String
    let env: String
    let atlasSecret: String?

    public init(sessionID: String, authToken: String, appVersion: String, env: String, atlasSecret: String? = nil) {
        self.sessionID = sessionID
        self.authToken = authToken
        self.appVersion = appVersion
        self.env = env
        self.atlasSecret = atlasSecret
    }
}

public final class TransactionsObserver: TransactionsObserverProviding {

    public static let shared = TransactionsObserver()
    public var configuration: TransactionsObserverConfiguration?
    @Published public private(set) var isON: Bool = false
    @Published public private(set) var transactionStatus: TransactionType = .unknown

    private var updates: Task<Void, Never>?
    private var remoteManager: RemoteManagerProviding?
    private var paymentsAPI: PaymentsAPIs?
    private var planComposer: PlansComposerProviding?
    private var transactionHandler: TransactionHandler?

    private init() {}

    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await update in Transaction.updates {
                if let transaction = try? update.payloadValue {
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
            }
        }
    }

    // MARK: Private functions
    private func initRequiredComponents() throws {

        guard let config = configuration else {
            throw TransactionsObserverError.missingOrInvalidConfiguration
        }

        guard let env = config.env.toEnvURLType else {
            throw TransactionsObserverError.impossibleToResolveRunningEnvironment
        }

        self.remoteManager = RemoteManager(sessionID: config.sessionID,
                                           authToken: config.authToken,
                                           appVersion: config.appVersion,
                                           atlasSecret: config.atlasSecret)
        self.paymentsAPI = PaymentsAPIs(envURL: env)

        guard let remoteManager = self.remoteManager, let paymentsAPI = self.paymentsAPI else {
            throw TransactionsObserverError.requiredSubComponentInitFailed
        }

        self.transactionHandler = TransactionHandler(remoteManager: remoteManager, paymentsAPIs: paymentsAPI)
        self.planComposer = PlansComposer(remoteManager: remoteManager, paymentsAPIs: paymentsAPI)
    }

    // MARK: Public methods
    public func start() async throws {

        try initRequiredComponents()

        guard let planComposer = planComposer, let _ = transactionHandler else {
            assertionFailure("TransactionsObserver: TransactionsObserverConfiguration required to start the observer")
            throw TransactionsObserverError.requiredSubComponentInitFailed
        }

        if !planComposer.hasData {
            _ = try await planComposer.fetchAvailablePlans()
        }
        updates = newTransactionListenerTask()
        isON = true
        debugPrint("TransactionsObserver started: \(isON) ✅")
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
        self.configuration = configuration
    }
}
