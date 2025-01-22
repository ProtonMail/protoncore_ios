//
//  GetOrganizationSignatureRequest.swift
//  ProtonCore-Login - Created on 22.01.25.
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

import ProtonCoreNetworking

public final class OrganizationSignatureResponse: Response, APIDecodableResponse, Encodable {
    public let publicKey: String
    public let fingerprintSignature: String
    public let fingerprintSignatureAddress: String
}

public final class GetOrganizationSignatureRequest: Request {
    public var path: String {
        "/core/v4/organizations/keys/signature"
    }

    public let isAuth: Bool = true

    public let method: HTTPMethod = .get

    public var parameters: [String: Any]?
}
