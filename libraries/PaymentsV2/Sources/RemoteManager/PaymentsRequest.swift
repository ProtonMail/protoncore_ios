//
//  PaymentsRequest.swift
//  ProtonCore-PaymentsV2 - Created on 11/12/2025.
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
import ProtonCoreUtilities
import ProtonCoreNetworking
import ProtonCoreServices

public struct PaymentsRequest<Response: Decodable>: Request {
    public var path: String
    public var method: HTTPMethod
    public var parameters: [String: Any]?

    private init(
        _ path: Path,
        appending component: String? = nil,
        method: HTTPMethod,
        parameters: [String: Any]? = nil
    ) {
        self.path = if let component {
            path.rawValue + "/\(component)"
        } else {
            path.rawValue
        }

        self.method = method
        self.parameters = parameters
    }

    private enum Path: String {
        case plans = "/payments/v5/plans"
        case tokens = "/payments/v5/tokens"
        case subscription = "/payments/v5/subscription"
        case icons = "/payments/v5/resources/icons"
        case status = "/payments/v6/status/apple"
        case userUuid = "/auth/v4/sessions/uuid"
    }
}

extension PaymentsRequest<CurrentSubscription> {
    public static let currentPlan: Self = .init(.subscription, method: .get)
}

extension PaymentsRequest<AvailablePlans> {
    public static let availablePlans: Self = .init(.plans, method: .get)
}

extension PaymentsRequest<UserTransactionUUIDResponse> {
    public static let userUuid: Self = .init(.userUuid, method: .get)
}

extension PaymentsRequest<IAPStatus> {
    public static let status: Self = .init(.status, method: .get)
}

extension PaymentsRequest<NewToken> {
    public static func post(token: Token) -> Self {
        .init(.tokens, method: .post, parameters: token.toDictionary())
    }

    public static func post(ocToken: OCToken) throws -> Self {
        .init(.tokens, method: .post, parameters: try ocToken.dictionary())
    }
}

extension PaymentsRequest<ResponseStatus> {
    public static func fetch(token: String) -> Self {
        .init(.tokens, appending: token, method: .get)
    }
}

extension PaymentsRequest<StatusResponse> {
    public static func create(subscription: CreateSubscription) -> Self {
        .init(.subscription, method: .post, parameters: subscription.toDictionary())
    }

    public static func create(ocSubscription: OCreateSubscription) throws -> Self {
        .init(.subscription, method: .post, parameters: try ocSubscription.dictionary())
    }
}
