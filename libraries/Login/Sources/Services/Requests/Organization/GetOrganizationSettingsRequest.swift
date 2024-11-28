//
//  GetOrganizationSettingsRequest.swift
//  ProtonCore-Login - Created on 28.11.24.
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

import ProtonCoreNetworking

public final class OrganizationSettingsResponse: Response, APIDecodableResponse, Encodable {
    public let showName: Bool
    public let showScribeWritingAssistant: Bool
    public let videoConferencingEnabled: Bool
    public let logoID: String?
}

public final class GetOrganizationSettingsRequest: Request {
    public var path: String {
        "/core/v4/organizations/settings"
    }

    public let isAuth: Bool = true

    public let method: HTTPMethod = .get

    public var parameters: [String: Any]?
}
