//
//  CredentiallessEndpoint.swift
//  ProtonCore
//
//  Copyright (c) 2025 Proton Technologies AG
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
import ProtonCoreNetworking

public final class CredentiallessRequestResponse: Response, Codable {
    public let UID: String
    public let userID: String
    public let localID: Int
    public let scopes: [String]
    public let eventID: String
    public let tokenType: String
    public let accessToken: String
    public let refreshToken: String
}

public final class CredentiallessRequest: Request {
    public let path = "/auth/v4/credentialless"
    public let method: HTTPMethod = .post
    public var isAuth: Bool = true
    public let challenge: ChallengeProperties?

    public var challengeProperties: ChallengeProperties? {
        return challenge
    }

    public init(challenge: ChallengeProperties?) {
        self.challenge = challenge
    }
}
