//
//  ActivateAuthDeviceRequest.swift
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
import ProtonCoreKeymaker

public protocol DeviceSecretRepositoryProtocol {
    func getByUserId(userId: String) throws -> DeviceSecret?
    func upsert(deviceSecret: DeviceSecret) throws
    func delete(for userId: String) throws
}

public final class DeviceSecretRepository: DeviceSecretRepositoryProtocol {
    public enum Constants {
        public static let defaultKeychainService = "me.proton.protoncore.account"
        public static let defaultKeychainAccesGroup = "me.proton.protoncore.account"
        
        static let keychainPrefix = "authdevice-secret-"
        static func deviceKey(for userId: String) -> String {
            "\(Constants.keychainPrefix)\(userId)"
        }
    }

    let keychain: Keychain

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    public init(keychain: Keychain = .init(
        service: Constants.defaultKeychainService,
        accessGroup: Constants.defaultKeychainAccesGroup
    )) {
        self.keychain = keychain
    }

    public func getByUserId(userId: String) throws -> DeviceSecret? {
        guard let secretData = try keychain.dataOrError(forKey: Constants.deviceKey(for: userId)) else { return nil }
        return try decoder.decode(DeviceSecret.self, from: secretData)
    }

    public func upsert(deviceSecret: DeviceSecret) throws {
        let secretData = try encoder.encode(deviceSecret)
        try keychain.setOrError(secretData, forKey: Constants.deviceKey(for: deviceSecret.userId))
    }

    public func delete(for userId: String) throws {
        try keychain.removeOrError(forKey: Constants.deviceKey(for: userId))
    }

}
