//
//  PasswordChangeService.swift
//  ProtonCore-PasswordChange - Created on 20.03.2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

#if os(iOS)

import Foundation

import ProtonCoreAPIClient
import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreCrypto
import ProtonCoreDataModel
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCorePasswordRequest

public class PasswordChangeService: BasePasswordChangeService {

    public func unlockPasswordWithFidoSignature(_ signature: Fido2Signature, userInfo: UserInfo,
                                                authInfo: AuthInfoResponse, loginPassword: String) async throws {
        guard let username = userInfo.userAddresses.defaultAddress()?.email else {
            PMLog.error("Attempted to change password of user without username.")
            throw UpdatePasswordError.invalidUserName
        }

        guard let auth = try SrpAuth(version: authInfo.version,
                                     username: username,
                                     password: loginPassword,
                                     salt: authInfo.salt,
                                     signedModulus: authInfo.modulus,
                                     serverEphemeral: authInfo.serverEphemeral) else {
            throw UpdatePasswordError.cantHashPassword
        }
        let srpClient = try auth.generateProofs(2048)

        guard let clientEphemeral = srpClient.clientEphemeral,
              let clientProof = srpClient.clientProof else {
            throw UpdatePasswordError.cantGenerateSRPClient
        }

        let authEndpointData = AuthEndpointData(username: username,
                                                ephemeral: clientEphemeral,
                                                proof: clientProof,
                                                srpSession: authInfo.srpSession)

        let request = UnlockPasswordEndpoint(authData: authEndpointData, signature: signature)
        _ = try await apiService.perform(request: request)
    }
}

#endif
