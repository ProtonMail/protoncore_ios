//
//  AccountDeletion.swift
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
import ProtonCore_Networking
import ProtonCore_Services


public enum AccountDeletionError: Error {
    case sessionForkingError(message: String)
    
    var messageForTheUser: String {
        switch self {
        case .sessionForkingError(let message): return message
        }
    }
}

public typealias AccountDeletionSuccess = Void

#if canImport(AppKit)
public typealias AccountDeletionViewController = NSViewController
#elseif canImport(UIKit)
public typealias AccountDeletionViewController = UIViewController
#endif

public protocol AccountDeletion {
    func initiateAccountDeletionProcess(credential: Credential,
                                        over viewController: AccountDeletionViewController,
                                        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void)
}

public struct AccountDeletionService: AccountDeletion {
    
    private let authenticator: Authenticator
    
    public init(api: APIService) {
        self.authenticator = Authenticator(api: api)
    }
    
    public func initiateAccountDeletionProcess(
        credential: Credential,
        over viewController: AccountDeletionViewController,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        authenticator.forkSession(credential) { result in
            switch result {
            case .failure(let authError): completion(.failure(.sessionForkingError(message: authError.messageForTheUser)))
            case .success(let response):
                print("Not implemented yet, but it will open the account lite app with selector \(response.selector)")
                completion(.success(()))
            }
        }
    }
}
