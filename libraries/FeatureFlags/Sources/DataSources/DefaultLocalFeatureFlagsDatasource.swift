//
//  DefaultLocalFeatureFlagsDatasource.swift
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

import ProtonCoreUtilities

public class DefaultLocalFeatureFlagsDatasource: LocalFeatureFlagsProtocol {
    private var currentFlags: Atomic<[String: FeatureFlags]>

    public init(currentFlags: Atomic<[String: FeatureFlags]> = Atomic<[String: FeatureFlags]>([:])) {
        self.currentFlags = currentFlags
    }

    public func getFeatureFlags(userId: String) -> FeatureFlags? {
        currentFlags.value[userId]
    }

    public func upsertFlags(_ flags: FeatureFlags, userId: String) {
        currentFlags.mutate { $0[userId] = flags }
    }

    public func cleanAllFlags() {
        currentFlags.mutate { $0.removeAll() }
    }

    public func cleanFlags(for userId: String) {
        currentFlags.mutate { $0.removeValue(forKey: userId) }
    }
}
