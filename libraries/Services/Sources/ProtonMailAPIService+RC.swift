//
//  ProtonMailAPIService+RC.swift
//  ProtonCore-Services - Created on 01/27/20.
//
//  Copyright (c) 2022 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Networking
import ProtonCore_Utilities

// MARK: - Handling Refresh Credential

extension APIService {
    
    // Refresh expired access token using refresh token
    public func refreshCredential(_ oldCredential: Credential, completion: @escaping (Result<Credential, ResponseError>) -> Void) {
        let route = RefreshEndpoint(authCredential: AuthCredential( oldCredential))
        self.perform(request: route) { (_, result: Result<RefreshResponse, ResponseError>) in
            switch result {
            case .failure(let responseError):
                completion(.failure(responseError))
            case .success(let response):
                let credential = Credential(res: response, UID: oldCredential.UID, userName: oldCredential.userName, userID: oldCredential.userID)
                completion(.success(credential))
            }
        }
    }
}
