//
//  ProtonCore-Observability - Created on 10.04.2025.
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

public enum QRLoginHTTPPullForkResponseCodeStatus: String, Encodable, CaseIterable {
    case http1xx
    case http2xx
    case http3xx
    case http4xx
    case http5xx
    case sslError
    case forkNotReady
    case unknown

    public static func fromResponseError(_ error: Error) -> Self {
        guard let httpCode = error.httpCode else {
            return .unknown
        }
        switch httpCode {
        case 100...199: return .http1xx
        case 200...299: return .http2xx
        case 300...399: return .http3xx
        case 422: return .forkNotReady
        case 495: return .sslError
        case 400...499: return .http4xx
        case 500...599: return .http5xx
        default: return .unknown
        }
    }
}

public struct QRLoginPullForkTotalLabels: Encodable, Equatable {
    let status: QRLoginHTTPPullForkResponseCodeStatus

    enum CodingKeys: String, CodingKey {
        case status
    }
}

extension ObservabilityEvent where Payload == PayloadWithLabels<QRLoginPullForkTotalLabels> {
    public static func qrLoginPullFork(status: QRLoginHTTPPullForkResponseCodeStatus) -> Self {
        .init(name: "ios_core_qr_login_pull_fork_total",
              labels: .init(status: status),
              version: .v1)
    }
}
