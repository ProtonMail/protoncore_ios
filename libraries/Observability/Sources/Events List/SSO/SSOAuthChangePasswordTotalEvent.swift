//
//  SSOAuthChangePasswordTotalEvent.swift
//  ProtonCore-Observability - Created on 28.01.2025.
//
//  Copyright (c) 2025 Proton Technologies AG
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

import ProtonCoreNetworking

public enum SSOAuthChangePasswordHTTPResponseCodeStatus: String, Encodable, CaseIterable {
    case deviceSecretNotFound
    case success
    case http1xx
    case http2xx
    case http3xx
    case http4xx
    case http5xx
    case connectionError
    case notConnected
    case parseError
    case sslError
    case cancellation
    case unknown

    public static func fromResponseError(_ error: Error) -> Self {
        guard let httpCode = error.httpCode,
              let responseError = error as? ResponseError else {
            return .unknown
        }
        switch httpCode {
        case 100...199: return .http1xx
        case 200...299: return .http2xx
        case 300...399: return .http3xx
        case 495: return .sslError
        case 400...499: return .http4xx
        case 500...599: return .http5xx
        default: return .unknown
        }
    }
}

public struct SSOAuthChangePasswordTotalLabels: Encodable, Equatable {
    let status: SSOAuthChangePasswordHTTPResponseCodeStatus

    enum CodingKeys: String, CodingKey {
        case status
    }
}

extension ObservabilityEvent where Payload == PayloadWithLabels<SSOAuthChangePasswordTotalLabels> {
    public static func ssoAuthChangePassword(status: SSOAuthChangePasswordHTTPResponseCodeStatus) -> Self {
        .init(name: "ios_core_auth_sso_changePassword_total",
              labels: .init(status: status),
              version: .v1)
    }
}
