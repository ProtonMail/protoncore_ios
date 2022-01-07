//
//  CreateUserAPI.swift
//  ExampleApp - Created on 11/12/2021.
//  
//  Copyright (c) 2021 Proton Technologies AG
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

import ProtonCore_Networking
import ProtonCore_Services

public struct ExpireTokenDetails {
    
}

public enum ExpireTokenError: Error {
    
    public var userFacingMessageInQuarkCommands: String {
        switch self {
        }
    }
}

public struct ExpireTokenResponse: Codable {
    public var code: Int
}

public class ExpireToken: Request {
    let uid: String
    public init(uid: String) {
        self.uid = uid
    }
    public var path: String {
        return "/internal/quark/user:expire:access:token?UID=\(self.uid)"
    }
    public var method: HTTPMethod = .get
    public var parameters: [String: Any]?

    public var isAuth: Bool {
        return false
    }
}
