//
//  Created on 12.03.2025.
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

public struct GetUserCodeAndSelector {
    private let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public struct Response {
        public let userCode: String
        public let selector: String
    }

    public func invoke() async throws -> Response {
        let request = ForkSessionRequest(useCase: .getUserCode)
        let response: (URLSessionDataTask?, ForkSessionUserCodeResponse) = try await apiService.perform(request: request)

        return Response(userCode: response.1.userCode, selector: response.1.selector)
    }
}
