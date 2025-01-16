//
//  RequestAdminHelp.swift
//  ProtonCore-Login - Created on 31.12.24.
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

import ProtonCoreCrypto
import ProtonCoreDataModel
import ProtonCoreServices

public struct RequestAdminHelp {
    private let apiService: APIService
    private let deviceSecretRepository: DeviceSecretRepositoryProtocol

    public init(
        apiService: APIService,
        deviceSecretRepository: DeviceSecretRepositoryProtocol
    ) {
        self.apiService = apiService
        self.deviceSecretRepository = deviceSecretRepository
    }

    public func invoke(userId: String) async throws {
        guard let deviceSecret = try deviceSecretRepository.getByUserId(userId: userId) else {
            throw SSOLoginError.deviceSecretNotFound
        }
        let request = PingAdminHelpRequest(deviceID: deviceSecret.deviceId)
        let _: (_, DefaultResponse) = try await apiService.perform(request: request)
    }
}
