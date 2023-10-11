//
//  FeatureFlagTestHelper.swift
//  ProtonCore-TestingToolkit - Created on 06.10.2023.
//
//  Copyright (c) 2022 Proton Technologies AG
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
//

import Foundation
import XCTest
import ProtonCoreFeatureFlag

/// Performs the included closure in a separate environment in which only the specified flags are enabled
extension XCTestCase {
    public func withFeatureFlags<T>(_ flags: [FeatureFlag], perform block: () throws -> T) rethrows -> T {
        let emptyRepo = FeatureFlagsRepository(configuration: .init(userId: "testuser",
                                                                    currentBUFlags: [FeatureFlag]),
                                               localDatasource: DefaultLocalFeatureFlagsDatasource(),
                                               remoteDatasource: MockFlagsDatasource(flags: [FeatureFlag]))

        FeatureFlagsRepository.shared = emptyRepo

        return try block()
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func withFeatureFlags<T>(_ flags: [FeatureFlag], perform block: () async throws -> T) rethrows -> T {
        let emptyRepo = FeatureFlagsRepository(configuration: .init(userId: "testuser",
                                                                    currentBUFlags: [FeatureFlag]),
                                               localDatasource: DefaultLocalFeatureFlagsDatasource(),
                                               remoteDatasource: MockFlagsDatasource(flags: [FeatureFlag]))

        FeatureFlagsRepository.shared = emptyRepo

        return try await block()
    }
}
