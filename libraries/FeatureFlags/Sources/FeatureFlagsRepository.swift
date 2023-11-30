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
    private(set) var localDatasource: Atomic<LocalFeatureFlagsProtocol>

    /// The remote data source for feature flags.
    private(set) var remoteDataSource: Atomic<RemoteFeatureFlagsProtocol?>

    /// The configuration for feature flags.
    private(set) var userId: Atomic<String>

    public internal(set) static var shared: FeatureFlagsRepository = .init(
        userId: Atomic<String>(""),
        localDatasource: Atomic<LocalFeatureFlagsProtocol>(DefaultLocalFeatureFlagsDatasource()),
        remoteDatasource: Atomic<RemoteFeatureFlagsProtocol?>(nil)
    )

    /**
     Private initialization of the shared FeatureFlagsRepository instance.

     - Parameters:
       - configuration: The configuration for feature flags.
       - localDatasource: The local data source for feature flags.
       - remoteDatasource: The remote data source for feature flags.
     */
    init(userId: Atomic<String>,
         localDatasource: Atomic<LocalFeatureFlagsProtocol>,
         remoteDatasource: Atomic<RemoteFeatureFlagsProtocol?>) {
        self.userId = userId
        self.localDatasource = localDatasource
        self.remoteDataSource = remoteDatasource
    }

    // Internal func for testing
    func updateRemoteDataSource(with remoteDatasource: Atomic<RemoteFeatureFlagsProtocol?>) {
        self.remoteDataSource = remoteDatasource
    }
}

// MARK: - For single-user clients

public extension FeatureFlagsRepository {

    /**
     Updates the local data source conforming to the `LocalFeatureFlagsProtocol` protocol
     */
    func updateLocalDataSource(_ localDatasource: Atomic<LocalFeatureFlagsProtocol>) {
        self.localDatasource = localDatasource
    }

    /**
     Sets the FeatureFlagsRepository configuration with the given user id.

     - Parameters:
       - userId: The user id used to initialize the configuration for feature flags.
     */
    func setUserId(_ userId: String) {
        self.userId = Atomic<String>(userId)
    }

    /**
     Sets the FeatureFlagsRepository remote data source with the given api service.

     - Parameters:
       - apiService: The api service used to initialize the remote data source for feature flags.
     */
    func setApiService(_ apiService: APIService) {
        self.remoteDataSource = Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasource(apiService: apiService))
    }

    /**
     Asynchronously fetches the feature flags from the remote data source and updates the local data source.

     - Parameters:
        - sessionType: The type of session we want the flags for.
        - apiService: A specific apiService tied to a userId, for multiple users app.

     - Throws: An error if the operation fails.
     */
    func fetchFlags(for sessionType: SessionType, using apiService: APIService? = nil) async throws {
        let remoteDataSource: RemoteFeatureFlagsProtocol?

        if let apiService {
            remoteDataSource = DefaultRemoteDatasource(apiService: apiService)
        } else {
            remoteDataSource = self.remoteDataSource.value
        }

        guard let remoteDataSource = remoteDataSource else {
            assertionFailure("No apiService was set. You need to set the apiService of the remoteDataSource by calling `setApiService`, or pass an apiService as an argument in order to fetch the feature flags.")
            return
        }
        let flags = try await remoteDataSource.getFlags()

        let userId: String

         switch sessionType {
         case .unauth:
             userId = ""
         case .auth(let authUserId):
             userId = authUserId
         }
        
        localDatasource.value.upsertFlags(.init(flags: flags), userId: userId)
    }

    /**
     A Boolean function indicating if a feature flag is enabled or not.
     The flag is fetched from the local data source and will always return
     the value that is returned initally on the first call.

     - Parameters:
       - flag: The flag we want to know the state of.
       - userId: The user id for which we want to check the flag value. If the userId is `nil`, the last set userId will be used.
       - reloadingValue: set `true` if you want the latest stored value for the flag. set `false` if  you want the "static" value, which is always the same as the first returned.
     */
    func isEnabled(_ flag: any FeatureFlagTypeProtocol, for userId: String? = nil, reloadingValue: Bool) -> Bool {
        let flags: FeatureFlags?

        if let userId {
            flags = localDatasource.value.getFeatureFlags(userId: userId, reloadFromUserDefaults: reloadingValue)
        } else {
            flags = localDatasource.value.getFeatureFlags(userId: self.userId.value, reloadFromUserDefaults: reloadingValue)
        }

        return flags?.getFlag(for: flag)?.enabled ?? false
    }
}

// MARK: - Reset

public extension FeatureFlagsRepository {
    /**
     Resets all feature flags.
     */
    func resetFlags() {
        localDatasource.value.cleanAllFlags()
    }

    /**
     Resets feature flags for a specific user.

     - Parameters:
        - userId: The ID of the user whose feature flags need to be reset.
     */
    func resetFlags(for userId: String) {
        localDatasource.value.cleanFlags(for: userId)
    }
}
