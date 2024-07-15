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

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Get flags

    public func getFeatureFlags(userId: String) -> FeatureFlags? {
        serialAccessQueue.sync {
            let dynamicFlags: [String: FeatureFlags]? = userDefaults.decodableValue(forKey: Self.overrideFeatureFlagsKey)
            return dynamicFlags?[userId]
        }
    }

    // MARK: - Clean flags

    public func cleanAllFlags() {
        serialAccessQueue.sync {
            userDefaults.removeObject(forKey: Self.overrideFeatureFlagsKey)
        }
    }

    // MARK: - Flag Override and Revert Override

    public func addFlag(_ flag: FeatureFlag, userId: String) {
        serialAccessQueue.sync {
            var overrideFlags: [String: FeatureFlags] = userDefaults.decodableValue(forKey: Self.overrideFeatureFlagsKey) ?? [:]

            // Flag already overridden --> replace existing value with new value
            // Otherwise append new flag
            if let existingFlag = overrideFlags[userId]?.getFlag(flag) {
                overrideFlags[userId]?.setFlag(existingFlag)
            } else {
                if overrideFlags[userId] == nil {
                    overrideFlags[userId] = FeatureFlags.default
                }
                overrideFlags[userId]?.setFlag(flag)
            }

            PMLog.debug("⚠️ flag: \(flag.name) overridden 💣 ⚠️")
            userDefaults.setEncodableValue(overrideFlags, forKey: Self.overrideFeatureFlagsKey)
        }
    }

    public func removeFlag(_ flag: FeatureFlag, userId: String) {
        serialAccessQueue.sync {
            var overrideFlags: [String: FeatureFlags] = userDefaults.decodableValue(forKey: Self.overrideFeatureFlagsKey) ?? [:]

            // Overridden Flag found --> remove it
            if let existingFlag = overrideFlags[userId]?.getFlag(flag) {
                overrideFlags[userId]?.removeFlag(existingFlag)
                PMLog.debug("Overridden flag: \(flag.name) successfully removed ✅")
                userDefaults.setEncodableValue(overrideFlags, forKey: Self.overrideFeatureFlagsKey)
            }
        }
    }
    
    // MARK: - User ID

    public var userIdForActiveSession: String? {
        serialAccessQueue.sync {
            userDefaults.object(forKey: Self.userIdKey) as? String
        }
    }

    public func setUserIdForActiveSession(_ userId: String) {
        serialAccessQueue.sync {
            userDefaults.set(userId, forKey: Self.userIdKey)
        }
    }

    public func clearUserId() {
        serialAccessQueue.sync {
            userDefaults.removeObject(forKey: Self.userIdKey)
        }
    }
}
