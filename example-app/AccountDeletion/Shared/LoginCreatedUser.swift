//
//  LoginCreatedUser.swift
//  ExampleApp - Created on 10/12/2021.
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

import Foundation
import ProtonCore_Doh
import ProtonCore_Login
import ProtonCore_Networking
import ProtonCore_Services

final class LoginCreatedUser {
    
    static let sessionId = "accound deletion login created user test app session"
    let authManager: AuthManager
    let api: PMAPIService
    let login: LoginService
    let serviceDelegate: APIServiceDelegate
    
    init(doh: DoH & ServerConfig) {
        let service = PMAPIService(doh: doh, sessionUID: LoginCreatedUser.sessionId)
        let manager = AuthManager()
        let serviceManager = AnonymousServiceManager()
        service.authDelegate = manager
        service.serviceDelegate = serviceManager
        authManager = manager
        api = service
        login = LoginService(api: service, authManager: manager, sessionId: LoginCreatedUser.sessionId, minimumAccountType: .username)
        serviceDelegate = serviceManager
    }
    
    func login(account: CreatedAccountDetails, completion: @escaping (Result<Credential, LoginError>) -> Void) {
        let login = login
        func createCompletionBlock() -> (Result<LoginStatus, LoginError>) -> Void {
            { [weak self] (result: Result<LoginStatus, LoginError>) in
                switch result {
                case .success(.finished):
                    guard let credental = self?.authManager.getToken(bySessionUID: LoginCreatedUser.sessionId) else {
                        completion(.failure(.generic(message: "authentication setup error")))
                        return
                    }
                    print("""
                          Successfully logged in newly created user with
                          username: \(account.account.username)
                          password: \(account.account.password)
                          mailboxPassword: \(account.account.mailboxPassword ?? "—")
                          """)
                    completion(.success(Credential(credental)))
                case .success(.ask2FA):
                    completion(.failure(.invalid2FACode(message: "Should never ask for 2FA but it did")))
                case .success(.askSecondPassword):
                    guard let mailboxPassword = account.account.mailboxPassword else {
                        completion(.failure(.invalidSecondPassword))
                        return
                    }
                    login.finishLoginFlow(mailboxPassword: mailboxPassword, completion: createCompletionBlock())
                case .success(.chooseInternalUsernameAndCreateInternalAddress):
                    completion(.failure(.generic(message: "Should never ask to chooseInternalUsernameAndCreateInternalAddress but it did")))
                case .failure(let loginError):
                    completion(.failure(loginError))
                }
            }
        }
        login.login(username: account.account.username, password: account.account.password, completion: createCompletionBlock())
    }
}
