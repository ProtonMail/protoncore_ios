//
//  TransactionHandlerProviding.swift
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
import Combine

public protocol TransactionHandlerProviding: Sendable {
    var transactionState: CurrentValueSubject<TransactionHandlerState, Never> { get }
    func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan) async throws -> ComposedPlan
    // Only Omnichannel TransactionHandler implements this
    func processTransaction(_ transaction: ProtonTransaction, jwsRepresentation: String, plan: ComposedPlan) async throws -> ComposedPlan
    func updateRemoteManager(remoteManager: RemoteManagerProviding)
    func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool
    func setAppAccountToken(_ appAccountToken: UUID?)
}
