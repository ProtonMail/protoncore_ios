//
//  AccountDeletion.swift
//  ProtonCore-AccountDeletion - Created on 10.12.21.
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

#if canImport(ProtonCore_Authentication)
import ProtonCore_Authentication
#else
import PMAuthentication
#endif
#if canImport(ProtonCore_CoreTranslation)
import ProtonCore_CoreTranslation
#else
import PMCoreTranslation
#endif
#if canImport(ProtonCore_Networking)
import ProtonCore_Networking
#else
import PMCommon
#endif
#if canImport(ProtonCore_Doh)
import ProtonCore_Doh
#endif
#if canImport(ProtonCore_Services)
import ProtonCore_Services
#endif

public typealias AccountDeletionSuccess = Void

#if canImport(ProtonCore_Networking)
public typealias CannotDeleteYourselfReasonError = ResponseError
#else
public typealias CannotDeleteYourselfReasonError = Error
extension Error {
    var networkResponseMessageForTheUser: String {
        localizedDescription
    }
}
#endif

public enum AccountDeletionError: Error {
    case sessionForkingError(message: String)
    case closedByUser
    case cannotDeleteYourself(becauseOf: CannotDeleteYourselfReasonError)
    
    public var userFacingMessageInAccountDeletion: String {
        switch self {
        case .sessionForkingError(let message): return message
        case .closedByUser: return ""
        case .cannotDeleteYourself(let error): return error.networkResponseMessageForTheUser
        }
    }
}

public protocol AccountDeletion {
    func initiateAccountDeletionProcess(
        credential: Credential,
        over viewController: AccountDeletionViewController,
        performAfterShowingAccountDeletionScreen: @escaping () -> Void,
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    )
}

#if canImport(ProtonCore_Services)
public extension AccountDeletion {
    static var defaultButtonName: String {
        CoreString._ad_delete_account_button
    }
    
    static var defaultExplanationMessage: String {
        CoreString._ad_delete_account_message
    }
}
#endif

final class CanDeleteRequest: Request {
    let path: String = "/core/v4/users/delete"
    let method: HTTPMethod = .get
    let isAuth: Bool = true
}

typealias DoHServerConfig = DoHInterface & ServerConfig

final class CanDeleteResponse: Response {}

public final class AccountDeletionService: AccountDeletion {
    
    private let api: APIService
    private let doh: DoHServerConfig
    private let authenticator: Authenticator

    #if canImport(ProtonCore_Services)
    public convenience init(api: APIService) {
        self.init(api: api, doh: api.doh)
    }
    #endif
    
    init(api: APIService, doh: DoHServerConfig) {
        self.api = api
        self.doh = doh
        self.authenticator = Authenticator(api: api)
    }

    public func initiateAccountDeletionProcess(
        credential: Credential,
        over viewController: AccountDeletionViewController,
        performAfterShowingAccountDeletionScreen: @escaping () -> Void = { },
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void = { $0() },
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        api.exec(route: CanDeleteRequest(), responseObject: CanDeleteResponse()) { [self] (response: CanDeleteResponse) in
            if let error = response.error {
                completion(.failure(.cannotDeleteYourself(becauseOf: error)))
                return
            }
            self.forkSession(credential: credential,
                              viewController: viewController,
                              performAfterShowingAccountDeletionScreen: performAfterShowingAccountDeletionScreen,
                              performBeforeClosingAccountDeletionScreen: performBeforeClosingAccountDeletionScreen,
                              completion: completion)
        }
    }
    
    private func forkSession(credential: Credential,
                             viewController: AccountDeletionViewController,
                             performAfterShowingAccountDeletionScreen: @escaping () -> Void,
                             performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
                             completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void) {
        authenticator.forkSession(credential) { [self] result in
            switch result {
            case .failure(let authError):
                completion(.failure(.sessionForkingError(message: authError.userFacingMessageInNetworking)))
                
            case .success(let response):
                handleSuccessfullyForkedSession(
                    selector: response.selector,
                    over: viewController,
                    performAfterShowingAccountDeletionScreen: performAfterShowingAccountDeletionScreen,
                    performBeforeClosingAccountDeletionScreen: performBeforeClosingAccountDeletionScreen,
                    completion: completion
                )
            }
        }
    }
    
    private func handleSuccessfullyForkedSession(
        selector: String,
        over: AccountDeletionViewController,
        performAfterShowingAccountDeletionScreen: @escaping () -> Void,
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        let viewModel = AccountDeletionViewModel(forkSelector: selector,
                                                 apiService: api,
                                                 doh: doh,
                                                 performBeforeClosingAccountDeletionScreen: performBeforeClosingAccountDeletionScreen,
                                                 completion: completion)
        let viewController = AccountDeletionWebView(viewModel: viewModel)
        viewController.stronglyKeptDelegate = self
        present(vc: viewController, over: over, completion: performAfterShowingAccountDeletionScreen)
    }
}
