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
    private var remoteDatasource: Atomic<RemoteFeatureFlagsProtocol>

    /// The configuration for feature flags.
    private(set) var configuration: Atomic<FeatureFlagsConfiguration>

    public internal(set) static var shared: FeatureFlagsRepository = .init(
        configuration: Atomic<FeatureFlagsConfiguration>(.init(userId: "", currentBUFlags: CoreFeatureFlagType.self)),
        localDatasource: Atomic<LocalFeatureFlagsProtocol>(DefaultLocalFeatureFlagsDatasource()),
        remoteDatasource: Atomic<RemoteFeatureFlagsProtocol>(DummyRemoteFeatureFlag())
    )

    /**
     Private initialization of the shared FeatureFlagsRepository instance.

     - Parameters:
       - configuration: The configuration for feature flags.
       - localDatasource: The local data source for feature flags.
       - remoteDatasource: The remote data source for feature flags.
     */
    private init(configuration: Atomic<FeatureFlagsConfiguration>,
                 localDatasource: Atomic<LocalFeatureFlagsProtocol>,
                 remoteDatasource: Atomic<RemoteFeatureFlagsProtocol>) {
        self.localDatasource = localDatasource
        self.remoteDatasource = remoteDatasource
        self.configuration = configuration
    }

    // MARK: - internal func for testing
    func updateLocalDataSource(with localDatasource: Atomic<LocalFeatureFlagsProtocol>) {
        self.localDatasource = localDatasource
    }

    func updateRemoteDataSource(with remoteDatasource: Atomic<RemoteFeatureFlagsProtocol>) {
        self.remoteDatasource = remoteDatasource
    }

    func updateConfiguration(with configuration: Atomic<FeatureFlagsConfiguration>) {
        self.configuration = configuration
    }
}

public extension FeatureFlagsRepository {
    /**
     Sets the FeatureFlagsRepository configuration with the given user id.

     - Parameters:
       - userId: The user id used to initialize the configuration for feature flags.
     */
    func setUserId(with userId: String) {
        self.configuration = Atomic<FeatureFlagsConfiguration>(.init(userId: userId, currentBUFlags: configuration.value.currentBUFlags))
    }

    /**
     Sets the FeatureFlagsRepository remote data source with the given api service.

     - Parameters:
       - apiService: The api service used to initialize the remote data source for feature flags.
     */
    func setApiService(with apiService: APIService) {
        self.remoteDatasource = Atomic<RemoteFeatureFlagsProtocol>(DefaultRemoteDatasource(apiService: apiService))
    }

    /**
     A Boolean function indicating if a feature flag is enabled or not.
     The flag is fetched from the local data source. In case the local data source
     is empty, we asynchronously fetch the remote flags.

     - Parameters:
       - flag: The flag we want to know the state of.
     */
    func isEnabled(_ flag: any FeatureFlagTypeProtocol) -> Bool {
        let flags = localDatasource.value.getFeatureFlags(userId: configuration.value.userId)
        return flags?.getFlag(for: flag)?.enabled ?? false
    }
 
    /**
     Asynchronously fetches the feature flags from the remote data source and updates the local data source.

    - Throws: An error if the operation fails.
     */
    func fetchFlags() async throws {
        let allflags = try await remoteDatasource.value.getFlags()
        let flags = filterFlags(from: allflags, currentBUFlags: configuration.value.currentBUFlags)
        localDatasource.value.upsertFlags(flags, userId: configuration.value.userId)
    }

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

private extension FeatureFlagsRepository {
    /// The new unleash feature flag endpoint doesn't filter flags on project base meaning we receive all proton flags
    /// we want to filter only the ones that are linked to the current BU
    /// The flag only appears if it is activated otherwise it it absent from the response
    func filterFlags(from flags: [FeatureFlag],
                     currentBUFlags: any FeatureFlagTypeProtocol.Type) -> FeatureFlags {
        let currentFlags = flags.filter { element in
            currentBUFlags.isPresent(rawValue: element.name)
        }
        return FeatureFlags(flags: currentFlags)
    }
}

private class DummyRemoteFeatureFlag: RemoteFeatureFlagsProtocol {
    func getFlags() async throws -> [FeatureFlag] { [] }
}
