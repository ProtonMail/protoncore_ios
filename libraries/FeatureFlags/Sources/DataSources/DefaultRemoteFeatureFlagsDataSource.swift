//
//  DefaultRemoteFeatureFlagsDataSource.swift
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

import ProtonCoreNetworking
import Foundation
@preconcurrency import ProtonCoreServices
@preconcurrency import ProtonCoreUtilities

struct FeatureFlagRequest: Request {
    var path: String {
        "/feature/v2/frontend"
    }

    var isAuth: Bool {
        true
    }
}

struct FeatureFlagResponse: Decodable {
    public let code: Int
    public let toggles: [FeatureFlag]

    public init(code: Int, toggles: [FeatureFlag]) {
        self.code = code
        self.toggles = toggles
    }
}

public struct DefaultRemoteFeatureFlagsDataSource: RemoteFeatureFlagsDataSourceProtocol {
    public let apiService: any APIService
    public let completionExecutor: CompletionBlockExecutor
    
    init(apiService: any APIService, completionExecutor: CompletionBlockExecutor = .asyncMainExecutor) {
        self.apiService = apiService
        self.completionExecutor = completionExecutor
    }

    public func getFlags() async throws -> (featureFlags: [FeatureFlag], userID: String) {
        let endpoint = FeatureFlagRequest()
        let response: FeatureFlagResponse = try await apiService.exec(
            endpoint: endpoint,
            networkCompletionExecutor: completionExecutor
        )
        let userID = apiService.authDelegate?.credential(sessionUID: apiService.sessionUID)?.userID
        return (response.toggles, userID ?? "")
    }
}

private extension APIService {
    /// Async variant that can take an `Endpoint`
    func exec<T: Decodable>(
        endpoint: any Request,
        networkCompletionExecutor: CompletionBlockExecutor
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            perform(request: endpoint,
                    callCompletionBlockUsing: networkCompletionExecutor,
                    onDataTaskCreated: { _ in }) { _, result in
                continuation.resume(with: result)
            }
        }
    }
}
