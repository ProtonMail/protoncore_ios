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
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_CoreTranslation

public typealias AccountDeletionSuccess = Void

public enum AccountDeletionError: Error {
    case sessionForkingError(message: String)
    case closedByUser
    
    public var userFacingMessageInAccountDeletion: String {
        switch self {
        case .sessionForkingError(let message): return message
        case .closedByUser: return ""
        }
    }
}

public protocol AccountDeletion {
    func initiateAccountDeletionProcess(
        credential: Credential,
        over viewController: AccountDeletionViewController,
        performBeforeShowingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    )
}

public extension AccountDeletion {
    static var defaultButtonName: String {
        CoreString._ad_delete_account_button
    }
    
    static var defaultExplanationMessage: String {
        CoreString._ad_delete_account_message
    }
}

public final class AccountDeletionService: AccountDeletion {
    
    private let doh: DoH & ServerConfig
    private let authenticator: Authenticator
    
    public init(api: APIService) {
        self.doh = api.doh
        self.authenticator = Authenticator(api: api)
    }
    
    public func initiateAccountDeletionProcess(
        credential: Credential,
        over viewController: AccountDeletionViewController,
        performBeforeShowingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void = { $0() },
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void = { $0() },
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        authenticator.forkSession(credential) { result in
            switch result {
            case .failure(let authError):
                completion(.failure(.sessionForkingError(message: authError.userFacingMessageInNetworking)))
                
            case .success(let response):
                performBeforeShowingAccountDeletionScreen {
                    self.handleSuccessfullyForkedSession(
                        selector: response.selector,
                        over: viewController,
                        performBeforeClosingAccountDeletionScreen: performBeforeClosingAccountDeletionScreen,
                        completion: completion
                    )
                }
            }
        }
    }
    
    private func handleSuccessfullyForkedSession(
        selector: String,
        over: AccountDeletionViewController,
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        let viewModel = AccountDeletionViewModel(forkSelector: selector,
                                                 doh: doh,
                                                 performBeforeClosingAccountDeletionScreen: performBeforeClosingAccountDeletionScreen,
                                                 completion: completion)
        let viewController = AccountDeletionWebView(viewModel: viewModel)
        viewController.stronglyKeptDelegate = self
        present(vc: viewController, over: over)
    }
}
