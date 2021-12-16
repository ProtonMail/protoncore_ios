//
//  AccountDeletionViewModel.swift
//  ProtonCore-AccountDeletion - Created on 10.12.21.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import ProtonCore_Authentication
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services

final class AccountDeletionViewModel {
    
    var getURL: URL {
        let accountUrl = doh.getAccountHost()
        return URL(string: "\(accountUrl)/lite?action=delete-account#selector=\(forkSelector)")!
    }
    
    private let forkSelector: String
    private let doh: DoH & ServerConfig
    private let completion: (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    
    init(forkSelector: String, doh: DoH & ServerConfig,
         completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void) {
        self.forkSelector = forkSelector
        self.doh = doh
        self.completion = completion
    }
    
    func deleteAccountWasClosed() {
        completion(.failure(.closedByUser))
    }
}