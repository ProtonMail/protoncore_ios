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
import ProtonCore_Login

public class LoginMock: Login {
    
    public init() {}
    
    @PropertyStub(\LoginMock.currentlyChosenSignUpDomain, initialGet: .empty) public var currentlyChosenSignUpDomainStub
    public var currentlyChosenSignUpDomain: String {
        get { currentlyChosenSignUpDomainStub() }
        set { currentlyChosenSignUpDomainStub(newValue) }
    }
    
    @PropertyStub(\LoginMock.allSignUpDomains, initialGet: .empty) public var allSignUpDomainsStub
    public var allSignUpDomains: [String] { allSignUpDomainsStub() }

    @FuncStub(Login.checkAvailability) public var checkAvailabilityStub
    public func checkAvailability(username: String, completion: @escaping (Result<(), AvailabilityError>) -> Void) {
        checkAvailabilityStub(username, completion)
    }
    
    @FuncStub(Login.checkAvailabilityExternal) public var checkAvailabilityExternalStub
    public func checkAvailabilityExternal(email: String, completion: @escaping (Result<(), AvailabilityError>) -> Void) {
        checkAvailabilityExternalStub(email, completion)
    }

    @FuncStub(Login.setUsername) public var setUsernameStub
    public func setUsername(username: String, completion: @escaping (Result<(), SetUsernameError>) -> Void) {
        setUsernameStub(username, completion)
    }

    @FuncStub(Login.createAddress) public var createAddressStub
    public func createAddress(completion: @escaping (Result<Address, CreateAddressError>) -> Void) {
        createAddressStub(completion)
    }

    @FuncStub(Login.logout) public var logoutStub
    public func logout(credential: AuthCredential, completion: @escaping (Result<Void, Error>) -> Void) {
        logoutStub(credential, completion)
    }

    @FuncStub(Login.login) public var loginStub
    public func login(username: String, password: String, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        loginStub(username, password, completion)
    }

    @FuncStub(Login.provide2FACode) public var provide2FACodeStub
    public func provide2FACode(_ code: String, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        provide2FACodeStub(code, completion)
    }

    @FuncStub(Login.finishLoginFlow) public var finishLoginFlowStub
    public func finishLoginFlow(mailboxPassword: String, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        finishLoginFlowStub(mailboxPassword, completion)
    }

    @FuncStub(Login.createAccountKeysIfNeeded) public var createAccountKeysIfNeededStub
    public func createAccountKeysIfNeeded(user: User, addresses: [Address]?, mailboxPassword: String?, completion: @escaping (Result<User, LoginError>) -> Void) {
        createAccountKeysIfNeededStub(user, addresses, mailboxPassword, completion)
    }

    @FuncStub(Login.createAddressKeys) public var createAddressKeysStub
    public func createAddressKeys(user: User, address: Address, mailboxPassword: String, completion: @escaping (Result<Key, CreateAddressKeysError>) -> Void) {
        createAddressKeysStub(user, address, mailboxPassword, completion)
    }
    
    public var minimumAccountType: AccountType {
        return .username
    }

    @FuncStub(Login.updateAccountType) public var updateAccountTypeStub
    public func updateAccountType(accountType: AccountType) {
        updateAccountTypeStub(accountType)
    }

    @FuncStub(Login.updateAllAvailableDomains) public var updateAvailableDomainStub
    public func updateAllAvailableDomains(type: AvailableDomainsType, result: @escaping ([String]?) -> Void) {
        updateAvailableDomainStub(type, result)
    }
    
    @FuncStub(Login.refreshCredentials) public var refreshCredentialsStub
    public func refreshCredentials(completion: @escaping (Result<Credential, LoginError>) -> Void) {
        refreshCredentialsStub(completion)
    }
    
    @FuncStub(Login.refreshUserInfo) public var refreshUserInfoStub
    public func refreshUserInfo(completion: @escaping (Result<User, LoginError>) -> Void) {
        refreshUserInfoStub(completion)
    }
    
    public var startGeneratingAddress: (() -> Void)?
    
    public var startGeneratingKeys: (() -> Void)?
}

public class AnonymousServiceManager: APIServiceDelegate {
    
    public init() {}
    
    public var locale: String { return "en_US" }
    public var appVersion: String = "iOSMail_2.7.0"
    public var additionalHeaders: [String: String]?
    public var userAgent: String?
    public func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }
    public func isReachable() -> Bool { return true }
    public func onDohTroubleshot() { }
}

public class AnonymousAuthManager: AuthDelegate {
    
    public init() {}
    
    public var authCredential: AuthCredential?

    public func getToken(bySessionUID uid: String) -> AuthCredential? {
        return self.authCredential
    }
    public func onLogout(sessionUID uid: String) { }
    public func onUpdate(auth: Credential) {
        self.authCredential = authCredential?.updatedKeepingKeyAndPasswordDataIntact(credential: auth) ?? AuthCredential(auth)
    }
    public func onRefresh(bySessionUID uid: String, complete: (Credential?, AuthErrors?) -> Void) { }
    public func onForceUpgrade() { }
}
