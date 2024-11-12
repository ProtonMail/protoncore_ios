//
//  NewDeviceRequest.swift
//  ProtonCore-Login - Created on 30.09.24.
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
import ProtonCoreNetworking

public final class CreateAuthDeviceResponse: Response, APIDecodableResponse, Encodable {
    var authDevice: AuthDevice?
}

public final class CreateAuthDeviceRequest: Request {
    public var path: String {
        "/auth/v4/devices"
    }

    public var isAuth: Bool {
        true
    }

    public var method: HTTPMethod {
        .post
    }

    public let name: String
    public let activationToken: String

    public init(name: String, activationToken: String) {
        self.name = name
        self.activationToken = activationToken
    }

    public var parameters: [String: Any]? {
        return [
            "Name": self.name,
            "ActivationToken": self.activationToken
        ]
    }
}
