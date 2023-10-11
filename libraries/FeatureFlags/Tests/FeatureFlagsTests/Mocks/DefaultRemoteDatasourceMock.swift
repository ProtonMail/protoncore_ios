//
// DefaultRemoteDatasourceMock.swift
// Proton - Created on 29/09/2023.
// Copyright (c) 2023 Proton Technologies AG
//
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton. If not, see https://www.gnu.org/licenses/.

import Foundation
@testable import ProtonCoreFeatureFlags

public class DefaultRemoteDatasourceMock: RemoteFeatureFlagsProtocol {
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
