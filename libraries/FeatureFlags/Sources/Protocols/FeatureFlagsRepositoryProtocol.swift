//
//  FeatureFlagsRepositoryProtocol.swift
//  ProtonCore-FeatureFlags - Created on 29.09.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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

import ProtonCoreServices
import ProtonCoreUtilities

public protocol FeatureFlagsRepositoryProtocol: AnyObject {

    func updateLocalDataSource(with localDatasource: Atomic<LocalFeatureFlagsProtocol>)

    // MARK: - For single-user clients
    func setUserId(with userId: String)
    func setApiService(with apiService: APIService)
    func fetchFlags(for userId: String, with apiService: APIService?) async throws
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, reloadValue: Bool) -> Bool
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, reloadValue: Bool) async throws -> Bool

    // - MARK: For multi-users clients
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, for userId: String, reloadValue: Bool) -> Bool

    // MARK: - Commons
    func resetFlags()
    func resetFlags(for userId: String)
}

public extension FeatureFlagsRepositoryProtocol {

    // MARK: - For single-user clients
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, reloadValue: Bool = false) -> Bool {
        isEnabled(flag, reloadValue: reloadValue)
    }

    func isEnabled(_ flag: any FeatureFlagTypeProtocol, reloadValue: Bool = false) async throws -> Bool {
        try await isEnabled(flag, reloadValue: reloadValue)
    }

    // - MARK: For multi-user clients
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, for userId: String, reloadValue: Bool = false) -> Bool {
        isEnabled(flag, for: userId, reloadValue: reloadValue)
    }
}
