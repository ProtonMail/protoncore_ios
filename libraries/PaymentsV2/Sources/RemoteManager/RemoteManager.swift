//
//  RemoteManager.swift
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
import ProtonCoreLog
import ProtonCoreEnvironment
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreUtilities

public protocol RemoteManagerProviding: Sendable {

    func getAvailablePlans() async throws -> AvailablePlans
    func getCurrentPlan() async throws -> CurrentSubscription

    func post(_ token: Token) async throws -> NewToken
    func post(_ token: OCToken) async throws -> NewToken
    func fetch(token: String) async throws -> ResponseStatus

    func getUserUUID() async throws -> UserTransactionUUIDResponse

    func create(newOCSubscription: OCNewSubscription) async throws -> StatusResponse
    func create(newSubscription: NewSubscription) async throws -> StatusResponse

    func checkIAPStatus() async throws -> IAPStatus
}

/// This class is a shim to ``APIService`` for easy mocking in payments unit tests.
public final class RemoteManager: RemoteManagerProviding, @unchecked Sendable {
    private let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    // MARK: Private methods

    public func getCurrentPlan() async throws -> CurrentSubscription {
        try await execute(.currentPlan)
    }

    public func getAvailablePlans() async throws -> AvailablePlans {
        try await execute(.availablePlans)
    }

    public func fetch(token: String) async throws -> ResponseStatus {
        try await execute(.fetch(token: token))
    }

    public func post(_ token: Token) async throws -> NewToken {
        try await execute(.post(token: token))
    }

    public func post(_ token: OCToken) async throws -> NewToken {
        try await execute(.post(ocToken: token))
    }

    public func create(newOCSubscription: OCNewSubscription) async throws -> StatusResponse {
        try await execute(.create(ocSubscription: newOCSubscription.newSubscription))
    }

    public func create(newSubscription: NewSubscription) async throws -> StatusResponse {
        try await execute(.create(subscription: newSubscription.newSubscription))
    }

    public func getUserUUID() async throws -> UserTransactionUUIDResponse {
        try await execute(.userUuid)
    }

    public func checkIAPStatus() async throws -> IAPStatus {
        try await execute(.status)
    }

    // MARK: Private methods
    private func execute<R>(_ request: PaymentsRequest<R>) async throws -> R {
        try await (apiService.perform(request: request) as (URLSessionDataTask?, R)).1
    }
}
