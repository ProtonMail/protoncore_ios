//
//  StoreObserver.swift
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

public protocol StoreObserverProviding {
    func start()
    func stop()
}

public typealias StoreObserverConfiguration = (sessionID: String, authToken: String, appVersion: String, env: EnvURLType, atlasSecret: String)

public final class StoreObserver {

    public var configuration: StoreObserverConfiguration? {
        didSet {
            guard let sessionId = configuration?.sessionID,
                    let authToken = configuration?.authToken,
                    let appVersion = configuration?.appVersion,
                    let env = configuration?.env,
                    let secret = configuration?.atlasSecret else {
                return
            }
            self.remoteManager = RemoteManager(sessionID: sessionId,
                                               authToken: authToken,
                                               appVersion: appVersion,
                                               atlasSecret: secret)
            self.paymentsAPI = PaymentsAPIs(envURL: env)

            guard let remoteManager = self.remoteManager, let paymentsAPI = self.paymentsAPI else {
                return
            }

            self.transactionHandler = TransactionHandler(remoteManager: remoteManager, paymentsAPIs: paymentsAPI)
            self.planComposer = PlansComposer(remoteManager: remoteManager, paymentsAPIs: paymentsAPI)
        }
    }

    private var updates: Task<Void, Never>?
    private var remoteManager: RemoteManagerProviding?
    private var paymentsAPI: PaymentsAPIs?
    private var planComposer: PlansComposerProviding?
    private var transactionHandler: TransactionHandler?

    public static let shared = StoreObserver()

    @Published public private(set) var isON: Bool = false
    @Published public private(set) var transactionStatus: TransactionType = .unknown


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

    // MARK: Public methods
    public func start() async throws {
        guard let _ = remoteManager, let _ = paymentsAPI, let planComposer = planComposer else {
            assertionFailure("StoreObserver: StoreObserverConfiguration required to start the observer")
            return
        }

        if !planComposer.hasData {
            _ = try await planComposer.fetchAvailablePlans()
        }
        updates = newTransactionListenerTask()
        isON = true
        debugPrint("StoreObserver started: \(isON)")
    }

    public func stop() {
        if isON {
            updates?.cancel()
            isON = false
            debugPrint("StoreObserver stopped")
        } else {
            debugPrint("StoreObserver not started, nothing to stop")
        }
    }
}
