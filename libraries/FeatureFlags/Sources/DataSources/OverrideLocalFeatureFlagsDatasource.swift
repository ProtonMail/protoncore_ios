//
//  Created on 10/07/2024.
//
//  Copyright (c) 2024 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCoreUtilities
import ProtonCoreLog

public class OverrideLocalFeatureFlagsDatasource: OverrideFeatureFlagDataSourceProtocol {
    private let serialAccessQueue = DispatchQueue(label: "ch.proton.featureflags_queue")

    static let overrideFeatureFlagsKey = "protoncore.overrideFeatureflag"
    static let userIdKey = "protoncore.featureflag.userId"
    static let globalUserId = ""
    
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Get flags

    public func getFeatureFlags() -> FeatureFlags? {
        serialAccessQueue.sync {
            let globalOverriddenFlags: [String: FeatureFlags]? = userDefaults.decodableValue(forKey: Self.overrideFeatureFlagsKey)
            return globalOverriddenFlags?[Self.globalUserId]
        }
    }

    // MARK: - Clean flags

    public func cleanAllFlags() {
        serialAccessQueue.sync {
            userDefaults.removeObject(forKey: Self.overrideFeatureFlagsKey)
        }
    }

    // MARK: - Flag Override and Revert Override

    public func addFlag(_ flag: FeatureFlag) {
        serialAccessQueue.sync {
            var globalOverriddenFlags: [String: FeatureFlags] = userDefaults.decodableValue(forKey: Self.overrideFeatureFlagsKey) ?? [:]
            if globalOverriddenFlags[Self.globalUserId] == nil {
                globalOverriddenFlags[Self.globalUserId] = FeatureFlags.default
            }
            globalOverriddenFlags[Self.globalUserId]?.setFlag(flag)
            PMLog.debug("⚠️ flag: \(flag.name) overridden 💣 ⚠️")
            userDefaults.setEncodableValue(globalOverriddenFlags, forKey: Self.overrideFeatureFlagsKey)
        }
    }

    public func removeFlag(_ flag: FeatureFlag) {
        serialAccessQueue.sync {
            var globalOverriddenFlags: [String: FeatureFlags] = userDefaults.decodableValue(forKey: Self.overrideFeatureFlagsKey) ?? [:]

            // Overridden Flag found --> remove it
            if let existingFlag = globalOverriddenFlags[Self.globalUserId]?.getFlag(flag) {
                globalOverriddenFlags[Self.globalUserId]?.removeFlag(existingFlag)
                PMLog.debug("Overridden flag: \(flag.name) successfully removed ✅")
                userDefaults.setEncodableValue(globalOverriddenFlags, forKey: Self.overrideFeatureFlagsKey)
            }
        }
    }
}
