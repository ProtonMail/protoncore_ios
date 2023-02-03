//
//  AuthDelegateMock.swift
//  ProtonCore-TestingToolkit - Created on 25.04.2022.
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

import ProtonCore_Networking
import ProtonCore_Services

public final class AuthDelegateMock: AuthDelegate {

    public init() {}

    @FuncStub(AuthDelegateMock.authCredential(sessionUID:), initialReturn: nil) public var getTokenAuthCredentialStub
    public func authCredential(sessionUID: String) -> AuthCredential? { getTokenAuthCredentialStub(sessionUID) }
    
    @FuncStub(AuthDelegateMock.credential(sessionUID:), initialReturn: nil) public var getTokenCredentialStub
    public func credential(sessionUID: String) -> Credential? { getTokenCredentialStub(sessionUID) }
    
    @FuncStub(AuthDelegateMock.onAuthenticatedSessionInvalidated) public var onAuthenticatedSessionInvalidatedStub
    public func onAuthenticatedSessionInvalidated(sessionUID uid: String) { onAuthenticatedSessionInvalidatedStub(uid) }
    
    @FuncStub(AuthDelegateMock.onUpdate) public var onUpdateStub
    public func onUpdate(credential: Credential, sessionUID: String) { onUpdateStub(credential, sessionUID) }
    
    @FuncStub(AuthDelegateMock.onUnauthenticatedSessionInvalidated) public var onUnauthenticatedSessionInvalidatedStub
    public func onUnauthenticatedSessionInvalidated(sessionUID: String) {
        onUnauthenticatedSessionInvalidatedStub(sessionUID)
    }

    @FuncStub(AuthDelegateMock.onSessionObtaining) public var onSessionObtainingStub
    public func onSessionObtaining(credential: Credential) {
        onSessionObtainingStub(credential)
    }

    @FuncStub(AuthDelegateMock.onAdditionalCredentialsInfoObtained) public var updateAuthStub
    public func onAdditionalCredentialsInfoObtained(sessionUID: String, password: String?, salt: String?, privateKey: String?) {
        updateAuthStub(sessionUID, password, salt, privateKey)
    }

    @PropertyStub(\AuthDelegateMock.authSessionInvalidatedDelegateForLoginAndSignup, initialGet: nil) public var authSessionInvalidatedDelegateForLoginAndSignupStub
    public var authSessionInvalidatedDelegateForLoginAndSignup: ProtonCore_Services.AuthSessionInvalidatedDelegate? {
        get { authSessionInvalidatedDelegateForLoginAndSignupStub() }
        set { authSessionInvalidatedDelegateForLoginAndSignupStub(newValue) }
    }
}
