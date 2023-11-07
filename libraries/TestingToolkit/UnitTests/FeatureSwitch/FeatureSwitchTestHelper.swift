//
//  FeatureSwitchTestHelper.swift
//  ProtonCore-QuarkCommands - Created on 28.11.2021.
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

import XCTest
import ProtonCoreUtilities
import ProtonCoreFeatureSwitch
@testable import ProtonCoreFeatureFlags

/// Performs the included closure in a separate environment in which only the specified switches are enabled
extension XCTestCase {
    public func withUnleashFeatureSwitches<T>(_ switches: [ProtonCoreFeatureFlags.FeatureFlag], perform block: () throws -> T) rethrows -> T {
        let currentLocalDataSource = FeatureFlagsRepository.shared.localDatasource
        let currentUserId = FeatureFlagsRepository.shared.userId.value

        defer {
            FeatureFlagsRepository.shared.updateLocalDataSource(with: currentLocalDataSource)
            FeatureFlagsRepository.shared.setUserId(with: currentUserId)
        }

        let testUserId = "testUserId"
        FeatureFlagsRepository.shared.setUserId(with: testUserId)
        FeatureFlagsRepository.shared.updateLocalDataSource(
            with: Atomic<LocalFeatureFlagsProtocol>(
                DefaultLocalFeatureFlagsDatasource(
                    currentFlags: Atomic<[String: FeatureFlags]>(
                        [testUserId: .init(flags: switches)]
                    )
                )
            )
        )

        return try block()
    }

    public func withFeatureSwitches<T>(_ switches: [Feature], perform block: () throws -> T) rethrows -> T {
        let currentValues = FeatureFactory.shared.getCurrentFeatures()

        defer { FeatureFactory.shared.setCurrentFeatures(features: currentValues) }

        FeatureFactory.shared.clear()
        FeatureFactory.shared.setCurrentFeatures(features: switches)
        return try block()
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func withUnleashFeatureSwitches<T>(_ switches: [ProtonCoreFeatureFlags.FeatureFlag], perform block: () async throws -> T) async rethrows -> T {
        let currentLocalDataSource = FeatureFlagsRepository.shared.localDatasource
        let currentUserId = FeatureFlagsRepository.shared.userId.value

        defer {
            FeatureFlagsRepository.shared.updateLocalDataSource(with: currentLocalDataSource)
            FeatureFlagsRepository.shared.setUserId(with: currentUserId)
        }

        let testUserId = "testUserId"
        FeatureFlagsRepository.shared.setUserId(with: testUserId)
        FeatureFlagsRepository.shared.updateLocalDataSource(
            with: Atomic<LocalFeatureFlagsProtocol>(
                DefaultLocalFeatureFlagsDatasource(
                    currentFlags: Atomic<[String: FeatureFlags]>(
                        [testUserId: .init(flags: switches)]
                    )
                )
            )
        )
        return try await block()
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func withFeatureSwitches<T>(_ switches: [Feature], perform block: () async throws -> T) async rethrows -> T {
        let currentValues = FeatureFactory.shared.getCurrentFeatures()

        defer { FeatureFactory.shared.setCurrentFeatures(features: currentValues) }

        FeatureFactory.shared.clear()
        FeatureFactory.shared.setCurrentFeatures(features: switches)
        return try await block()
    }
}

public extension ProtonCoreFeatureFlags.FeatureFlag {
    static var dynamicPlans: Self {
        .init(name: "DynamicPlan", enabled: true, variant: nil)
    }
}
