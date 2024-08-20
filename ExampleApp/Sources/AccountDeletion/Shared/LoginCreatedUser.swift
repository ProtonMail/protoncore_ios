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
import ProtonCoreAuthentication
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreNetworking
import ProtonCoreQuarkCommands
import ProtonCoreServices

public let accountsAvailableForCreation: [(String?, String?, String, String, String) -> AccountAvailableForCreation] = [
    { username, password, _, _, _ in .freeNoAddressNoKeys(username: username, password: password) },
    { username, password, _, _, _ in .freeWithAddressAndMailboxPassword(username: username, password: password) },
    { username, password, _, _, _ in .freeWithAddressButWithoutKeys(username: username, password: password) },
    { username, password, _, _, _ in .freeWithAddressAndKeys(username: username, password: password) },
    { username, password, _, _, _ in .external(email: username, password: password) },
    { username, password, _, _, _ in .deletedWithAddressAndKeys(username: username, password: password) },
    { username, password, _, _, _ in .disabledWithAddressAndKeys(username: username, password: password) },
    { username, password, _, _, _ in .vpnAdminWithAddressAndKeys(username: username, password: password) },
    { username, password, _, _, _ in .adminWithAddressAndKeys(username: username, password: password) },
    { username, password, _, _, _ in .superWithAddressAndKeys(username: username, password: password) },
    { username, password, _, _, plan in .paid(plan: plan, username: username, password: password) },
    { username, password, ownerId, ownerPassword, _ in .deletedSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .disabledSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .baseAdminSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .adminSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .superSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .abuserSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .restrictedSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .bulkSenderSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .ransomwareSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .compromisedSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .bulkSignupSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .bulkDisabledSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .criminalSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .chargeBackSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .inactiveSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .forcePasswordChangeSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .selfDeletedSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .csaSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .spammerSubuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .subuserPublic(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) },
    { username, password, ownerId, ownerPassword, _ in .subuserPrivate(username: username, password: password, ownerUserId: ownerId, ownerUserPassword: ownerPassword) }
]

final class LoginCreatedUser {

    static let defaultErrorCode = 42

    let api: PMAPIService
    let authManager: AuthHelper
    let login: LoginService

    init(api: PMAPIService, authManager: AuthHelper) {
        self.api = api
        self.authManager = authManager
        login = LoginService(api: api, clientApp: clientApp, minimumAccountType: .username)
    }

    func login(account: CreatedAccountDetails, completion: @escaping (Result<Credential, LoginError>) -> Void) {
        let login = login
        func createCompletionBlock() -> (Result<LoginStatus, LoginError>) -> Void {
            { [weak self] (result: Result<LoginStatus, LoginError>) in
                switch result {
                case .success(.finished):
                    guard let credential = self?.authManager.credential(sessionUID: self?.api.sessionUID ?? "") else {
                        completion(.failure(.generic(message: "authentication setup error", code: LoginCreatedUser.defaultErrorCode, originalError: LoginError.invalidState)))
                        return
                    }
                    PMLog.info("""
                          Successfully logged in newly created user with
                          username: \(account.account.username)
                          password: \(account.account.password)
                          mailboxPassword: \(account.account.mailboxPassword ?? "—")
                          """)
                    completion(.success(credential))
                case .success(.askTOTP), .success(.askFIDO2), .success(.askAny2FA):
                    completion(.failure(.invalid2FACode(message: "Should never ask for 2FA but it did")))
                case .success(.ssoChallenge):
                    completion(.failure(.generic(message: "Should not receive SSO challenge but it did", code: LoginCreatedUser.defaultErrorCode, originalError: LoginError.invalidState)))
                case .success(.askSecondPassword):
                    guard let mailboxPassword = account.account.mailboxPassword else {
                        completion(.failure(.invalidSecondPassword))
                        return
                    }
                    // we know that password mode is .two because we got .askSecondPassword from login
                    login.finishLoginFlow(mailboxPassword: mailboxPassword, passwordMode: .two, completion: createCompletionBlock())
                case .success(.chooseInternalUsernameAndCreateInternalAddress):
                    completion(.failure(.generic(message: "Should never ask to chooseInternalUsernameAndCreateInternalAddress but it did", code: LoginCreatedUser.defaultErrorCode, originalError: LoginError.invalidState)))
                case .failure(let loginError):
                    completion(.failure(loginError))
                }
            }
        }

        switch account.account.type {
        case .free, .plan, .external:
            login.login(username: account.account.username,
                        password: account.account.password,
                        intent: nil,
                        challenge: nil,
                        completion: createCompletionBlock())
        case .subuser:
            login.login(username: "\(account.account.username)@proton.green",
                        password: account.account.password,
                        intent: nil,
                        challenge: nil,
                        completion: createCompletionBlock())
        }
    }
}
