//
// FeatureFlagsRepository.swift
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
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.

/**
 The FeatureFlagsRepository class is responsible for managing feature flags and their state.
 It conforms to the FeatureFlagsRepositoryProtocol.
 */
public actor FeatureFlagsRepository: FeatureFlagsRepositoryProtocol {
    /// The local data source for feature flags.
    private let localDatasource: LocalFeatureFlagsProtocol
    
    /// The remote data source for feature flags.
    private let remoteDatasource: RemoteFeatureFlagsProtocol
    
    /// The configuration for feature flags.
    private var configuration: FeatureFlagsConfiguration

    /**
     Initializes a FeatureFlagsRepository instance.

     - Parameters:
       - configuration: The configuration for feature flags.
       - localDatasource: The local data source for feature flags.
       - remoteDatasource: The remote data source for feature flags.
     */
    public init(configuration: FeatureFlagsConfiguration,
                localDatasource: LocalFeatureFlagsProtocol,
                remoteDatasource: RemoteFeatureFlagsProtocol) {
        self.localDatasource = localDatasource
        self.remoteDatasource = remoteDatasource
        self.configuration = configuration
    }
}

public extension FeatureFlagsRepository {
    /**
     Asynchronously retrieves feature flags.

     - Returns: A FeatureFlags instance representing the feature flags.
     - Throws: An error if the operation fails.
     */
    func getFlags() async throws -> FeatureFlags {
        if let localFlags = try await localDatasource.getFeatureFlags(userId: configuration.userId) {
            return localFlags
        }
        return try await refreshFlags()
    }

    /**
     Asynchronously retrieves a specific feature flag for a given key.
     
     - Parameter key: The key representing the feature flag.
     - Returns: A FeatureFlag instance representing the feature flag associated with the given key.
     */
    func getFlag(for key: any FeatureFlagTypeProtocol) async -> FeatureFlag? {
        guard let flags = try? await getFlags().flags else {
            return nil
        }
        return flags.first { $0.name == key.rawValue }
    }

    /**
     Asynchronously refreshes the feature flags from the remote data source and updates the local data source.
     
     - Returns: A FeatureFlags instance representing the updated feature flags.
     - Throws: An error if the operation fails.
     */
    func refreshFlags() async throws -> FeatureFlags {
        let allflags = try await remoteDatasource.getFlags()
        let flags = filterFlags(from: allflags, currentBUFlags: configuration.currentBUFlags)
        try await localDatasource.upsertFlags(flags, userId: configuration.userId)
        return flags
    }

    /**
     Asynchronously checks if a feature flag is enabled for a given key.
     
     - Parameter key: The key representing the feature flag.
     - Returns: A boolean indicating whether the feature flag is enabled.
     */
    func isEnabled(for key: any FeatureFlagTypeProtocol) async -> Bool {
        do {
            let flags = try await getFlags().flags
            return flags.first { $0.name == key.rawValue }?.enabled ?? false
        } catch {
            return false
        }
    }

    /**
     Updates the configuration for feature flags.
     
     - Parameter configuration: The new configuration for feature flags.
     */
    func update(with configuration: FeatureFlagsConfiguration) {
        self.configuration = configuration
    }

    /**
     Asynchronously resets all feature flags.
     */
    func resetFlags() async {
        await localDatasource.cleanAllFlags()
    }
    
    /**
     Asynchronously resets feature flags for a specific user.

     - Parameter userId: The ID of the user whose feature flags need to be reset.
     */
    func resetFlags(for userId: String) async {
        await localDatasource.cleanFlags(for: userId)
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
