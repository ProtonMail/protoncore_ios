//
//  VerifyUnprivatization.swift
//  ProtonCore-Login - Created on 26.11.24.
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

import Foundation
import ProtonCoreAuthentication
import ProtonCoreCrypto
import ProtonCoreDataModel
import ProtonCoreObservability
import ProtonCoreServices

/// Called as a first step in the unprivatization flow for first time login SSO users.
///
/// The user needs to be unprivatized so that org Admin has access.
struct VerifyUnprivatization {

    typealias AuthenticationManager = AuthenticatorInterface

    let apiService: APIService
    let authManager: AuthenticationManager

    let getUnprivatizationInfo: GetUnprivatizationInfo

    private enum Constants {
        static let orgVerificationContext = "account.organization-fingerprint"
    }

    init(apiService: APIService) {
        self.apiService = apiService
        self.authManager = Authenticator(api: apiService)
        self.getUnprivatizationInfo = GetUnprivatizationInfo(apiService: apiService)
    }

    func invoke() async throws -> UnprivatizeUserSuccess {
        do {
            let unprivatizationInfo = try await getUnprivatizationInfo.invoke()

            guard unprivatizationInfo.state == .pending else { throw UnprivatizationError.invalidState }

            // Fetch the keys from GET /keys/all for the AdminEmail.
            let adminEmail = unprivatizationInfo.adminEmail
            guard let keysInfo = try await authManager.getKeys(email: adminEmail, internalOnly: false),
                  let publicAddressKey = keysInfo.address.keys.first else {
                // If unable, or the key is not in the Address part (i.e. in KT) error out.
                throw UnprivatizationError.publicAddressKeyNotFound
            }


            // Verify the SHA265 fingerprint of the OrgPublicKey using the OrgKeyFingerprintSignature and the fetched admin address key.
            let fingerprint = unprivatizationInfo.orgPublicKey.sha256Fingerprint

            let verified = try Sign.verifyDetached(
                signature: unprivatizationInfo.orgKeyFingerprintSignature,
                plainText: fingerprint,
                verifierKey: ArmoredKey(value: publicAddressKey.publicKey),
                trimTrailingSpaces: false,
                verificationContext: VerificationContext(
                    value: Constants.orgVerificationContext,
                    required: .always
                )
            )

            guard verified else { throw UnprivatizationError.verificationError }

            ObservabilityEnv.report(.ssoAuthVerifyUnprivatization(status: .success))
            return UnprivatizeUserSuccess(
                adminEmail: adminEmail,
                organizationPublicKey: unprivatizationInfo.orgPublicKey
            )
        } catch {
            if let unprivatizationError = error as? UnprivatizationError {
                ObservabilityEnv.report(.ssoAuthVerifyUnprivatization(status: unprivatizationError.observabilityStatus))
            } else {
                ObservabilityEnv.report(.ssoAuthVerifyUnprivatization(status: .failure))
            }
            throw error
        }
    }
}

public struct UnprivatizeUserSuccess {
    public let adminEmail: String
    public let organizationPublicKey: ArmoredKey

    public init(adminEmail: String, organizationPublicKey: ArmoredKey) {
        self.adminEmail = adminEmail
        self.organizationPublicKey = organizationPublicKey
    }
}

enum UnprivatizationError: Error {
    case invalidState
    case publicAddressKeyNotFound
    case verificationError

    var observabilityStatus: SSOAuthVerifyUnprivatizationCodeStatus {
        switch self {
        case .invalidState: return .failureUnprivatizeStateError
        case .publicAddressKeyNotFound: return .failurePublicAddressKeysError
        case .verificationError: return .failureVerificationError
        }
    }
}
