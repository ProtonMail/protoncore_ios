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

public struct QRLoginInitiateForkTotalLabels: Encodable, Equatable {
    let status: QRLoginHTTPResponseCodeStatus

    enum CodingKeys: String, CodingKey {
        case status
    }
}

extension ObservabilityEvent where Payload == PayloadWithLabels<QRLoginInitiateForkTotalLabels> {
    public static func qrLoginInitiateFork(status: QRLoginHTTPResponseCodeStatus) -> Self {
        .init(name: "ios_core_qr_login_initiate_fork_total",
              labels: .init(status: status),
              version: .v1)
    }
}
