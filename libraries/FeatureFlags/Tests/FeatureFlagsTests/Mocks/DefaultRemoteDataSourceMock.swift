//
//  DefaultRemoteFeatureFlagsDataSourceMock.swift
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

import Foundation
@testable import ProtonCoreFeatureFlags

public class DefaultRemoteFeatureFlagsDataSourceMock: RemoteFeatureFlagsDataSourceProtocol {
    public init() {}

    public func getFlags() async throws -> [FeatureFlag] {
        guard let url = Bundle.module.url(forResource: "flags", withExtension: "json"),
              let data = try? Data(contentsOf: url, options: .mappedIfSafe),
              let response = try? JSONDecoder().decode(FeatureFlagResponse.self, from: data)
        else {
            return []
        }
        return response.toggles
    }
}
