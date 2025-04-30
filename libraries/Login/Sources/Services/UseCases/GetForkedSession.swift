//
//  Created on 17.03.2025.
//
//  Copyright (c) 2025 Proton AG
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
import ProtonCoreServices
import ProtonCoreObservability

public struct GetForkedSession {
    private let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public struct Response {
        public let payload: String?
        public let UID: String
        public let refreshToken: String
        public let accessToken: String
        public let scopes: [String]
        public let userID: String
    }

    public func invoke(selector: String) async throws -> Response {
        let request = ForkSessionRequest(useCase: .pullFork(selector: selector))
        do {
            let response: (URLSessionDataTask?, ForkSessionPullResponse) = try await apiService.perform(request: request)
            ObservabilityEnv.report(.qrLoginPullFork(status: .http2xx))
            return Response(payload: response.1.payload,
                            UID: response.1.UID,
                            refreshToken: response.1.refreshToken,
                            accessToken: response.1.accessToken,
                            scopes: response.1.scopes,
                            userID: response.1.userID)
        } catch {
            ObservabilityEnv.report(.qrLoginPullFork(status: .fromResponseError(error)))
            throw error
        }
    }
}
