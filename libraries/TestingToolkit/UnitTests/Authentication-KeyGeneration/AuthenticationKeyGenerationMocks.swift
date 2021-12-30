//
//  AuthenticatorMock.swift
//  ProtonCore-TestingToolkit - Created on 31/03/2021.
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

// swiftlint:disable function_parameter_count

import Foundation

import ProtonCore_APIClient
import ProtonCore_Authentication
import ProtonCore_Authentication_KeyGeneration
import ProtonCore_DataModel
import ProtonCore_Networking
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

public struct AuthenticatorWithKeyGenerationMock: AuthenticatorInterface & AuthenticatorKeyGenerationInterface {

    public init() {}

    @FuncStub(Self.authenticate) public var authenticateStub
    public func authenticate(username: String, password: String, srpAuth: SrpAuth?, completion: @escaping Authenticator.Completion) {
        authenticateStub(username, password, srpAuth, completion)
    }

    @FuncStub(Self.confirm2FA) public var confirm2FAStub
    public func confirm2FA(_ twoFactorCode: String, context: TwoFactorContext, completion: @escaping Authenticator.Completion) {
        confirm2FAStub(twoFactorCode, context, completion)
    }

    @FuncStub(Self.refreshCredential) public var refreshCredentialStub
    public func refreshCredential(_ oldCredential: Credential, completion: @escaping Authenticator.Completion) {
        refreshCredentialStub(oldCredential, completion)
    }

    @FuncStub(Self.checkAvailable) public var checkAvailableStub
    public func checkAvailable(_ username: String, completion: @escaping (Result<(), AuthErrors>) -> Void) {
        checkAvailableStub(username, completion)
    }

    @FuncStub(Self.checkAvailableExternal) public var checkAvailableExternalStub
    public func checkAvailableExternal(_ email: String, completion: @escaping (Result<(), AuthErrors>) -> Void) {
        checkAvailableExternalStub(email, completion)
    }
    
    @FuncStub(Self.setUsername) public var setUsernameStub
    public func setUsername(_ credential: Credential?, username: String, completion: @escaping (Result<(), AuthErrors>) -> Void) {
        setUsernameStub(credential, username, completion)
    }

    @FuncStub(Self.createAddress) public var createAddressStub
    public func createAddress(_ credential: Credential?, domain: String, displayName: String?, siganture: String?, completion: @escaping (Result<Address, AuthErrors>) -> Void) {
        createAddressStub(credential, domain, displayName, siganture, completion)
    }

    @FuncStub(Self.getUserInfo) public var getUserInfoStub
    public func getUserInfo(_ credential: Credential?, completion: @escaping (Result<User, AuthErrors>) -> Void) {
        getUserInfoStub(credential, completion)
    }

    @FuncStub(Self.getAddresses) public var getAddressesStub
    public func getAddresses(_ credential: Credential?, completion: @escaping (Result<[Address], AuthErrors>) -> Void) {
        getAddressesStub(credential, completion)
    }

    @FuncStub(Self.getKeySalts) public var getKeySaltsStub
    public func getKeySalts(_ credential: Credential?, completion: @escaping (Result<[KeySalt], AuthErrors>) -> Void) {
        getKeySaltsStub(credential, completion)
    }
    
    @FuncStub(Self.forkSession) public var forkSessionStub
    public func forkSession(_ credential: Credential,
                            completion: @escaping (Result<AuthService.ForkSessionResponse, AuthErrors>) -> Void) {
        forkSessionStub(credential, completion)
    }

    @FuncStub(Self.closeSession) public var closeSessionStub
    public func closeSession(_ credential: Credential,
                             completion: @escaping (Result<AuthService.EndSessionResponse, AuthErrors>) -> Void) {
        closeSessionStub(credential, completion)
    }

    @FuncStub(Self.getRandomSRPModulus) public var getRandomSRPModulusStub
    public func getRandomSRPModulus(completion: @escaping (Result<AuthService.ModulusEndpointResponse, AuthErrors>) -> Void) {
        getRandomSRPModulusStub(completion)
    }

    @FuncStub(Self.createAddressKey) public var createAddressKeyStub
    public func createAddressKey(_ credential: Credential?, address: Address,
                                 password: String, salt: Data, primary: Bool,
                                 completion: @escaping (Result<Key, AuthErrors>) -> Void) {
        createAddressKeyStub(credential, address, password, salt, primary, completion)
    }

    @FuncStub(Self.setupAccountKeys) public var setupAccountKeysStub
    public func setupAccountKeys(_ credential: Credential?, addresses: [Address],
                                 password: String, completion: @escaping (Result<(), AuthErrors>) -> Void) {
        setupAccountKeysStub(credential, addresses, password, completion)
    }
}
