//
//  AssociateAuthDeviceRequest.swift
//  ProtonCore-Login - Created on 13.11.24.
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

public final class AssociateAuthDeviceResponse: Response, APIDecodableResponse, Encodable {
    var device: AssociateAuthDeviceOutput?
}

public struct AssociateAuthDeviceOutput: Codable {
    let ID: String
    let encryptedSecret: String
}

public final class AssociateAuthDeviceRequest: Request {
    public var path: String {
        "/auth/v4/devices/\(deviceID)/associate"
    }

    public let isAuth: Bool = true

    public let method: HTTPMethod = .post

    public let deviceID: String
    public let deviceToken: String

    public init(deviceID: String, deviceToken: String) {
        self.deviceID = deviceID
        self.deviceToken = deviceToken
    }

    public var parameters: [String: Any]? {
        return ["DeviceToken": deviceToken]
    }
}
