//
//  UpdatePasswordError.swift
//  ProtonCore-Login - Created on 20.03.2024.
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
import ProtonCoreObservability

public enum UpdatePasswordError: Int, Error {
    case invalidUserName
    case invalidModulusID
    case invalidModulus
    case cantHashPassword
    case cantGenerateVerifier
    case cantGenerateSRPClient
    case keyUpdateFailed
    case missingUserInfo
    case missingAuthInfo

    case `default`
}

extension UpdatePasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUserName:
            return LSTranslation.errorInvalidUsername.l10n
        case .invalidModulusID:
            return LSTranslation.errorInvalidModulusID.l10n
        case .invalidModulus:
            return LSTranslation.errorInvalidModulus.l10n
        case .cantHashPassword:
            return LSTranslation.errorCantHashPassword.l10n
        case .cantGenerateVerifier:
            return LSTranslation.errorCantGenerateVerifier.l10n
        case .cantGenerateSRPClient:
            return LSTranslation.errorCantGenerateSRPClient.l10n
        case .keyUpdateFailed:
            return LSTranslation.errorKeyUpdateFailed.l10n
        case .missingUserInfo:
            return LSTranslation.errorMissingUserInfo.l10n
        case .missingAuthInfo:
            return LSTranslation.errorMissingAuthInfo.l10n
        case .default:
            return LSTranslation.errorUpdatePasswordDefault.l10n

        }
    }
}

public extension UpdatePasswordError {
    var passwordChangeObservabilityStatus: PasswordChangeHTTPResponseCodeStatus {
        switch self {
        case .invalidUserName: return .invalidUserName
        case .invalidModulusID: return .invalidModulusID
        case .invalidModulus: return .invalidModulus
        case .cantHashPassword: return .cantHashPassword
        case .cantGenerateVerifier: return .cantGenerateVerifier
        case .cantGenerateSRPClient: return .cantGenerateSRPClient
        case .keyUpdateFailed: return .keyUpdateFailed
        case .missingAuthInfo: return .missingAuthInfo
        case .missingUserInfo: return .missingUserInfo
        case .default: return .unknown
        @unknown default: return .unknown
        }
    }
}
