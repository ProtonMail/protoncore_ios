//
//  APIHeader.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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

public enum APIHeader: String, Sendable {
    case setCookie = "set-cookie"
    case authorization = "Authorization"
    case sessionId = "x-pm-uid"
    case appVersion = "x-pm-appversion"
    case features = "x-pm-features"
    case apiVersion = "x-pm-apiversion"
    case contentType = "Content-Type"
    case accept = "Accept"
    case userAgent = "User-Agent"
    case retryAfter = "retry-after"
    case atlasSecret = "x-atlas-secret"
}

public enum APIHeaderError: Error {

    case missingAuthorization
    case missingSessionId
    case missingAppVersion
    case missingAcceptResponseDataType
    case missingContentType
}

public enum APICodeError: Int, Error {

    // Request
    case badParameter = 1
    case badPath = 2
    case unableToParseResponse = 3
    case badResponse = 4

    // Auth
    case credentialExpired = 10
    case credentialInvalid = 20
    case invalidGrant = 30
    case unableToParseToken = 40
    case localCacheBad = 50
    case networkIssue = -1004
    case unableToParseAuthInfo = 70
    case authServerSRPInValid = 80
    case authUnableToGenerateSRP = 90
    case authUnableToGeneratePwd = 100
    case authInValidKeySalt = 110
    case authCacheLocked = 665

    // User
    case userNameExist = 12011
    case currentWrong = 12021
    case newNotMatch = 12022
    case pwdUpdateFailed = 12023
    case pwdEmpty = 12024

    // Client
    case badAppVersion = 5003
    case badApiVersion = 5005
    case appVersionTooOldForExternalAccounts = 5098
    case appVersionNotSupportedForExternalAccounts = 5099
    case switchToSSOError = 8100
    case switchToSRPError = 8101
    case humanVerificationRequired = 9001
    case deviceVerificationRequired = 9002
    case lockedScopeRequired = 9101
    case invalidVerificationCode = 12087
    case tooManyVerificationCodes = 12214
    case tooManyFailedVerificationAttempts = 85131
    case humanVerificationAddressAlreadyTaken = 2001
    case tls = 3500
    case invalidRequirements = 2000
}
