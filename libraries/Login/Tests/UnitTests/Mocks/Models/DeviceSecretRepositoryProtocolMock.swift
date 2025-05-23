//
//  DeviceSecretRepositoryProtocolMock.swift
//  ProtonCore-Login-Tests - Created on 27.11.2024.
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

import ProtonCoreLogin

class DeviceSecretRepositoryProtocolMock: DeviceSecretRepositoryProtocol {
    var store: [String: DeviceSecret] = [:]

    func getByUserId(userId: String) throws -> ProtonCoreLogin.DeviceSecret? {
        store[userId]
    }

    func upsert(deviceSecret: ProtonCoreLogin.DeviceSecret) throws {
        store[deviceSecret.userId] = deviceSecret
    }

    func delete(for userId: String) throws {
        store[userId] = nil
    }
}
