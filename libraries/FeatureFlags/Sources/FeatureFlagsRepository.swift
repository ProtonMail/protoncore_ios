//
//  FeatureFlagsRepository.swift
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

import ProtonCoreLog
import ProtonCoreServices
import ProtonCoreUtilities

/**
 The FeatureFlagsRepository class is responsible for managing feature flags and their state.
 It conforms to the FeatureFlagsRepositoryProtocol.
 */
public class FeatureFlagsRepository: FeatureFlagsRepositoryProtocol {

    /// The local data source for feature flags.
    private(set) var localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>

    /// The local data source for overridden feature flags.
    internal var overrideLocalDataSource = Atomic<OverrideFeatureFlagDataSourceProtocol>(OverrideLocalFeatureFlagsDatasource())

    /// The remote data source for feature flags.
    private(set) var remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>

    /// The configuration for feature flags.
    private(set) var userId: String {
        get {
            return _userId ?? ""
        }
        set {
            _userId = newValue
            localDataSource.value.setUserIdForActiveSession(newValue)
            overrideLocalDataSource.value.setUserIdForActiveSession(newValue)
        }
    }

    private var _userId: String?

    public internal(set) static var shared: FeatureFlagsRepository = .init(
        localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>(DefaultLocalFeatureFlagsDatasource()),
        remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(nil)
    )

    /**
     Private initialization of the shared FeatureFlagsRepository instance.
     
     - Parameters:
     - localDataSource: The local data source for feature flags.
     - remoteDataSource: The remote data source for feature flags.
     */
    init(localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>,
         remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self._userId = localDataSource.value.userIdForActiveSession
    }

    // Internal func for testing
    func updateRemoteDataSource(with remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>) {
        self.remoteDataSource = remoteDataSource
    }
}

// MARK: - For single-user clients

public extension FeatureFlagsRepository {

    /**
     Updates the local data source conforming to the `LocalFeatureFlagsProtocol` protocol
     */
    func updateLocalDataSource(_ localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>) {
        self.localDataSource = localDataSource
    }

    /**
     Sets the FeatureFlagsRepository configuration with the given user id.
     
     - Parameters:
     - userId: The user id used to initialize the configuration for feature flags.
     */
    func setUserId(_ userId: String) {
        self.userId = userId
    }

    /**
     Sets the FeatureFlagsRepository remote data source with the given api service.
     
     - Parameters:
     - apiService: The api service used to initialize the remote data source for feature flags.
     */
    func setApiService(_ apiService: APIService) {
        self.remoteDataSource = Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSource(apiService: apiService))
    }

    /**
     Asynchronously fetches the feature flags from the remote data source and updates the local data source.
     
     - Throws: An error if the operation fails.
     */
    func fetchFlags() async throws {
        guard let remoteDataSource = self.remoteDataSource.value else {
            assertionFailure("No apiService was set. You need to set the apiService of by calling `setApiService` in order to fetch the feature flags.")
            return
        }

        let (flags, userID) = try await remoteDataSource.getFlags()
        localDataSource.value.upsertFlags(.init(flags: flags), userId: userID)
    }

    /**
     A Boolean function indicating if a feature flag is enabled or not.
     The flag is fetched from the local data source and is intended for use in a single-user context.
     If an overridden flag is found, it gets returned instead of the local value.
     
     - Parameters:
     - flag: The flag we want to know the state of.
     - reloadValue: Pass `true` if you want the latest stored value for the flag. Pass `false` if  you want the "static" value, which is always the same as the first returned.
     */
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, reloadValue: Bool = false) -> Bool {

        let overriddenFlag = overrideLocalDataSource.value.getFeatureFlags(
            userId: self.userId
        )?.getFlag(for: flag)

        if let overriddenFlag = overriddenFlag {
            return overriddenFlag.enabled
        }
        
        // Search for the flag for no userId set
        let overriddenNoIdFlag = overrideLocalDataSource.value.getFeatureFlags(
            userId: ""
        )?.getFlag(for: flag)

        if let overriddenNoIdFlag = overriddenNoIdFlag {
            return overriddenNoIdFlag.enabled
        }

        let flag = localDataSource.value.getFeatureFlags(
            userId: self.userId,
            reloadFromLocalDataSource: reloadValue
        )?.getFlag(for: flag)

        if let flag = flag {
            return flag.enabled
        }

        return false
    }

    /**
     A Boolean function indicating if a feature flag is enabled or not.
     The flag is fetched from the local data source and is intended for use in multi-user contexts.
     If an overridden flag is found, it gets returned instead of the local value.
     
     - Parameters:
     - flag: The flag we want to know the state of.
     - userId: The user id for which we want to check the flag value. If the userId is `nil`, the first-set userId will be used.  See ``setUserId(_)``.
     - reloadValue: Pass `true` if you want the latest stored value for the flag. Pass `false` if  you want the "static" value, which is always the same as the first returned.
     */
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, for userId: String?, reloadValue: Bool) -> Bool {

        let tempUserId: String = userId ?? self.userId

        let overriddenFlag = overrideLocalDataSource.value.getFeatureFlags(
            userId: tempUserId
        )?.getFlag(for: flag)

        if let overriddenFlag = overriddenFlag {
            return overriddenFlag.enabled
        }

        let flag = localDataSource.value.getFeatureFlags(
            userId: tempUserId,
            reloadFromLocalDataSource: reloadValue
        )?.getFlag(for: flag)

        if let flag = flag {
            return flag.enabled
        }

        return false
    }
}

// MARK: - Flag Override
public extension FeatureFlagsRepository {

    func setFlagOverride(_ flag: any FeatureFlagTypeProtocol, overrideWithValue: Bool, userId: String? = nil) {

        let userId: String = userId ?? self.userId

        // Check if the flag is already overridden
        // If NOT, we fetch it from the localDataSource
        let flagToUpdate: FeatureFlag
        if let existingOverriddenFlag = overrideLocalDataSource.value.getFeatureFlags(
            userId: userId
        )?.getFlag(for: flag) {
            flagToUpdate = existingOverriddenFlag
        } else if let existingLocalFlag = localDataSource.value.getFeatureFlags(
            userId: userId,
            reloadFromLocalDataSource: false
        )?.getFlag(for: flag) {
            flagToUpdate = existingLocalFlag
        } else {
            PMLog.error("⚠️ This flag is not present on Unleash ⚠️")
            flagToUpdate = FeatureFlag(name: flag.rawValue,
                                       enabled: overrideWithValue,
                                       variant: nil)
        }
        
        let newFeatureFlag = FeatureFlag(name: flagToUpdate.name,
                                         enabled: overrideWithValue,
                                         variant: flagToUpdate.variant)

        overrideLocalDataSource.value.addFlag(newFeatureFlag, userId: userId)
    }

    func resetFlagOverride(_ flag: any FeatureFlagTypeProtocol, userId: String? = nil) {

        let userId: String = userId ?? self.userId

        let flagToRemove: FeatureFlag
        if let existingOverriddenFlag = overrideLocalDataSource.value.getFeatureFlags(
            userId: userId
        )?.getFlag(for: flag) {
            flagToRemove = existingOverriddenFlag
        } else {
            PMLog.debug("flag: \(flag) not found in localDataSource 🤷🏻")
            return
        }

        overrideLocalDataSource.value.removeFlag(flagToRemove, userId: userId)
    }

    func resetOverrides() {
        overrideLocalDataSource.value.cleanAllFlags()
    }
}

// MARK: - Reset

public extension FeatureFlagsRepository {
    /**
     Resets all feature flags.
     */
    func resetFlags() {
        localDataSource.value.cleanAllFlags()
    }

    /**
     Resets feature flags for a specific user.
     
     - Parameters:
     - userId: The ID of the user whose feature flags need to be reset.
     */
    func resetFlags(for userId: String) {
        localDataSource.value.cleanFlags(for: userId)
    }

    /**
     Resets userId.
     */
    func clearUserId() {
        localDataSource.value.clearUserId()
        _userId = ""
    }
}
