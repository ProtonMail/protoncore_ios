//
//  SignInMock.swift
//  ProtonCore-Login - Created on 05/11/2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services

#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

@testable import ProtonCore_Login

class LoginMock: Login {

    var minimumAccountType: AccountType = .internal

    let signUpDomain: String = "protonmail.com"

    func checkAvailability(username: String, completion: @escaping (Result<(), AvailabilityError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success)
        }
    }

    func setUsername(username: String, completion: @escaping (Result<(), SetUsernameError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.failure(.alreadySet(message: "Already set")))
        }
    }

    func createAddress(completion: @escaping (Result<Address, CreateAddressError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.failure(.generic(message: "")))
        }
    }

    func logout(credential: AuthCredential, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success)
        }
    }

    func login(username: String, password: String, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.failure(.generic(message: "")))
        }
    }

    func provide2FACode(_ code: String, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.failure(.generic(message: "")))
        }
    }

    func finishLoginFlow(mailboxPassword: String, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.failure(.generic(message: "")))
        }
    }

    func createAccountKeysIfNeeded(user: User, addresses: [Address]?, mailboxPassword: String?, completion: @escaping (Result<User, LoginError>) -> Void) {

    }

    func createAddressKeys(user: User, address: Address, mailboxPassword: String, completion: @escaping (Result<Key, CreateAddressKeysError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.failure(.generic(message: "")))
        }
    }

    func updateAccountType(accountType: AccountType) {

    }

    func updateAvailableDomain(type: AvailableDomainsType, result: @escaping (String?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            result("")
        }
    }
}

class AnonymousServiceManager: APIServiceDelegate {
    var locale: String { return "en_US" }
    var appVersion: String = appVersionHeader
    var userAgent: String?
    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }
    func isReachable() -> Bool { return true }
    func onDohTroubleshot() { }
    func onHumanVerify() { }
    func onChallenge(challenge: URLAuthenticationChallenge, credential: AutoreleasingUnsafeMutablePointer<URLCredential?>?) -> URLSession.AuthChallengeDisposition {
        let dispositionToReturn: URLSession.AuthChallengeDisposition = .performDefaultHandling
        return dispositionToReturn
    }
}

class AnonymousAuthManager: AuthDelegate {
    var authCredential: AuthCredential?

    func getToken(bySessionUID uid: String) -> AuthCredential? {
        return self.authCredential
    }
    func onLogout(sessionUID uid: String) { }
    func onUpdate(auth: Credential) {
        self.authCredential = AuthCredential( auth)
    }
    func onRefresh(bySessionUID uid: String, complete: (Credential?, AuthErrors?) -> Void) { }
    func onForceUpgrade() { }
}