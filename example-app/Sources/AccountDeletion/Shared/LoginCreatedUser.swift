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
import ProtonCore_QuarkCommands
import ProtonCore_Services

public let accountsAvailableForCreation: [(String?, String?) -> AccountAvailableForCreation] = [
    AccountAvailableForCreation.freeNoAddressNoKeys,
    AccountAvailableForCreation.freeWithAddressAndMailboxPassword,
    AccountAvailableForCreation.freeWithAddressButWithoutKeys,
    AccountAvailableForCreation.freeWithAddressAndKeys,
    AccountAvailableForCreation.deletedWithAddressAndKeys,
    AccountAvailableForCreation.disabledWithAddressAndKeys,
    AccountAvailableForCreation.vpnAdminWithAddressAndKeys,
    AccountAvailableForCreation.adminWithAddressAndKeys,
    AccountAvailableForCreation.superWithAddressAndKeys,
    AccountAvailableForCreation.deletedSubuserPrivate,
    AccountAvailableForCreation.disabledSubuserPrivate,
    AccountAvailableForCreation.baseAdminSubuserPrivate,
    AccountAvailableForCreation.adminSubuserPrivate,
    AccountAvailableForCreation.superSubuserPrivate,
    AccountAvailableForCreation.abuserSubuserPrivate,
    AccountAvailableForCreation.restrictedSubuserPrivate,
    AccountAvailableForCreation.bulkSenderSubuserPrivate,
    AccountAvailableForCreation.ransomwareSubuserPrivate,
    AccountAvailableForCreation.compromisedSubuserPrivate,
    AccountAvailableForCreation.bulkSignupSubuserPrivate,
    AccountAvailableForCreation.bulkDisabledSubuserPrivate,
    AccountAvailableForCreation.criminalSubuserPrivate,
    AccountAvailableForCreation.chargeBackSubuserPrivate,
    AccountAvailableForCreation.inactiveSubuserPrivate,
    AccountAvailableForCreation.forcePasswordChangeSubuserPrivate,
    AccountAvailableForCreation.selfDeletedSubuserPrivate,
    AccountAvailableForCreation.csaSubuserPrivate,
    AccountAvailableForCreation.spammerSubuserPrivate,
    AccountAvailableForCreation.subuserPublic,
    AccountAvailableForCreation.subuserPrivate
]

final class LoginCreatedUser {
    
    static let defaultErrorCode = 42
    
    static let sessionId = "accound deletion login created user test app session"
    let api: PMAPIService
    let authManager: AuthManager
    let login: LoginService

    init(api: PMAPIService, authManager: AuthManager) {
        self.api = api
        self.authManager = authManager
        login = LoginService(api: api, authManager: authManager, clientApp: .other(named: "Deletion-example"), sessionId: api.sessionUID, minimumAccountType: .username)
    }
    
    func login(account: CreatedAccountDetails, completion: @escaping (Result<Credential, LoginError>) -> Void) {
        let login = login
        func createCompletionBlock() -> (Result<LoginStatus, LoginError>) -> Void {
            { [weak self] (result: Result<LoginStatus, LoginError>) in
                switch result {
                case .success(.finished):
                    guard let credental = self?.authManager.getToken(bySessionUID: LoginCreatedUser.sessionId) else {
                        completion(.failure(.generic(message: "authentication setup error", code: LoginCreatedUser.defaultErrorCode, originalError: LoginError.invalidState)))
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
                    completion(.failure(.generic(message: "Should never ask to chooseInternalUsernameAndCreateInternalAddress but it did", code: LoginCreatedUser.defaultErrorCode, originalError: LoginError.invalidState)))
                case .failure(let loginError):
                    completion(.failure(loginError))
                }
            }
        }

        switch account.account.type {
        case .free, .plan:
            login.login(username: account.account.username,
                        password: account.account.password,
                        challenge: nil,
                        completion: createCompletionBlock())
        case .subuser:
            login.login(username: "\(account.account.username)@proton.green",
                        password: account.account.password,
                        challenge: nil,
                        completion: createCompletionBlock())
        }
    }
}
