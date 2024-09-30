//
//  AuthDevice.swift
//  ProtonCorePayments - Created on 30.09.24.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation

/// `AuthDevice` object is the data model for the devices for which an SSO user
/// currently has authenticated/.
public struct AuthDevice: Codable, Equatable {

    public var id: String
    public var deviceToken: String
    public var activationAddressId: String
    public var state: State
    public var name: String
    public var localizedClientName: String
    public var platform: String // make enum?
    public var createTime: Int
    public var activateTime: Int?
    public var rejectTime: Int?
    public var activationToken: String?
    public var lastActivityTime: Int

    public enum State: Int, Codable, Equatable {
        case inactive = 0
        case active = 1
        case pendingActivation = 2
        case pendingAdminActivation = 3
        case rejected = 4
        case activeNoAssociatedSession = 5
    }

    public init(id: String, deviceToken: String, activationAddressId: String, state: State, name: String, localizedClientName: String, platform: String, createTime: Int, activateTime: Int? = nil, rejectTime: Int? = nil, activationToken: String? = nil, lastActivityTime: Int) {
        self.id = id
        self.deviceToken = deviceToken
        self.activationAddressId = activationAddressId
        self.state = state
        self.name = name
        self.localizedClientName = localizedClientName
        self.platform = platform
        self.createTime = createTime
        self.activateTime = activateTime
        self.rejectTime = rejectTime
        self.activationToken = activationToken
        self.lastActivityTime = lastActivityTime
    }
}
