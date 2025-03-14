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
import ProtonCoreNetworking

public final class ForkSessionResponse: Response, Codable {
    public let code: Int
    public let selector: String

    public init(code: Int, selector: String) {
        self.code = code
        self.selector = selector
    }

    public required init() {
        self.code = 0
        self.selector = ""
    }
}

public final class ForkSessionUserCodeResponse: Response, Codable {
    public let selector: String
    public let userCode: String

    public init(selector: String, userCode: String) {
        self.selector = selector
        self.userCode = userCode
    }
    
    public required init() {
        self.selector = ""
        self.userCode = ""
    }
}

public final class ForkSessionRequest: Request {
    let useCase: UseCase
    let timeout: TimeInterval?

    public enum UseCase {
        // To test this I need to login first.
        case getSelector(payload: String, clientId: String, independent: Bool, userCode: String)
        case getUserCode
    }

    public init(useCase: UseCase, timeout: TimeInterval? = nil) {
        self.useCase = useCase
        self.timeout = timeout
    }

    public var nonDefaultTimeout: TimeInterval? {
        return timeout
    }

    public var path: String {
        return "/auth/v4/sessions/forks"
    }

    public var method: HTTPMethod {
        switch useCase {
        case .getSelector:
            return .post
        case .getUserCode:
            return .get
        }
    }

    public var parameters: [String: Any]? {
        switch useCase {
        case .getSelector(let payload, let clientId, let independent, let userCode):
            return [
                "Payload": payload,
                "ChildClientID": clientId,
                "Independent": independent ? 1 : 0,
                "UserCode": userCode
            ]
        case .getUserCode:
            return nil
        }
    }

    #if canImport(Alamofire)
    public var retryPolicy: ProtonRetryPolicy.RetryMode {
        .background
    }
    #endif
}
