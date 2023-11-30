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

public enum SessionType {
    case unauth
    case auth(userId: String)
}

public protocol FeatureFlagsRepositoryProtocol: AnyObject {
    func updateLocalDataSource(_ localDatasource: Atomic<LocalFeatureFlagsProtocol>)
    func setUserId(_ userId: String)
    func setApiService(_ apiService: APIService)
    func fetchFlags(for sessionType: SessionType, using apiService: APIService?) async throws
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, for userId: String?, reloadingValue: Bool) -> Bool

    // MARK: - Commons
    func resetFlags()
    func resetFlags(for userId: String)
}

public extension FeatureFlagsRepositoryProtocol {

    // MARK: - For single-user clients
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, for userId: String? = nil, reloadingValue: Bool = false) -> Bool {
        isEnabled(flag, for: userId, reloadingValue: reloadingValue)
    }
}
