//
//  Created on 10.04.2025.
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

public struct PushSessionFork {
    private let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public struct Response {
        public let selector: String
    }

    public func invoke(encryptedPayload: String, clientId: String, userCode: String) async throws -> Response {
        let request = ForkSessionRequest(useCase: .pushFork(payload: encryptedPayload,
                                                            clientId: clientId,
                                                            independent: true,
                                                            userCode: userCode))
        do {
            let response: (URLSessionDataTask?, ForkSessionPushResponse) = try await apiService.perform(request: request)
            ObservabilityEnv.report(.qrLoginPushFork(status: .http2xx))
            return Response(selector: response.1.selector)
        } catch {
            ObservabilityEnv.report(.qrLoginPushFork(status: .fromResponseError(error)))
            throw error
        }
    }
}
