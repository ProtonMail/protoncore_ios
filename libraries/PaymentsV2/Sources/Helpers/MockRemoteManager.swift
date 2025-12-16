//
//  MockRemoteManager.swift
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

#if DEBUG
public final class MockRemoteManager: RemoteManagerProviding {
    public init() {}

    public func getAvailablePlans() async throws -> AvailablePlans {
        Bundle.main.decode(AvailablePlans.self, from: "availablePlans.json")
    }

    public func getCurrentPlan() async throws -> CurrentSubscription{
        Bundle.main.decode(CurrentSubscription.self, from: "current_sub_response.json")
    }

    public func post(_ token: Token) async throws -> NewToken {
        NewToken(code: 1000, status: 1, token: "abc")
    }

    public func post(_ token: OCToken) async throws -> NewToken {
        NewToken(code: 1000, status: 1, token: "abc")
    }

    public func fetch(token: String) async throws -> ResponseStatus {
        ResponseStatus(code: 1000, status: 1)
    }

    public func getUserUUID() async throws -> UserTransactionUUIDResponse {
        return UserTransactionUUIDResponse(code: 1000, uuid: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    }

    public func create(newOCSubscription: OCNewSubscription) async throws -> StatusResponse {
        StatusResponse(code: 1000)
    }

    public func create(newSubscription: NewSubscription) async throws -> StatusResponse {
        StatusResponse(code: 1000)
    }

    public func checkIAPStatus() async throws -> IAPStatus {
        Bundle.main.decode(IAPStatus.self, from: "IAPStatus.json")
    }
}
#endif
