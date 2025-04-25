//
//  SettingsEndpoint.swift
//  ProtonCore-Service - Created on 02/05/2024.
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

public class SettingsResponse: APIDecodableResponse {
    public let code: Int
    public let userSettings: UserSettings

    public init(code: Int, userSettings: UserSettings) {
        self.code = code
        self.userSettings = userSettings
    }
}

public struct UserSettings: Codable {
    public let password: Password
    public let _2FA: TwoFA

    public init(password: Password,
                _2FA: TwoFA) {
        self.password = password
        self._2FA = _2FA
    }

    public struct Password: Codable {
        public let mode: PasswordMode

        public init(mode: PasswordMode) {
            self.mode = mode
        }

        public enum PasswordMode: Int, Sendable, Codable {
            case singlePassword = 1
            case loginAndMailboxPassword = 2
        }

        enum CodingKeys: String, CodingKey {
            case mode
        }
    }

    public struct TwoFA: Codable {
        public var enabled: EnabledMechanism
        public let registeredKeys: [RegisteredKey]

        public init(enabled: EnabledMechanism, registeredKeys: [RegisteredKey]) {
            self.enabled = enabled
            self.registeredKeys = registeredKeys
        }
    }
}

public extension UserSettings {
    static var `default`: UserSettings {
        .init(password: .init(mode: .singlePassword), _2FA: .init(enabled: .off, registeredKeys: []))
    }
}

public final class SettingsEndpoint: Request {

    public var path: String {
        "/core/v4/settings"
    }

    public var auth: AuthCredential?
    public var authCredential: AuthCredential? {
        return self.auth
    }

    public init() { }
}
