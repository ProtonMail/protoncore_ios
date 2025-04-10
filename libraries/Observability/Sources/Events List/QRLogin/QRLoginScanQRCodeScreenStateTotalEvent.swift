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

public enum QRLoginScanQRCodeScreenStateStatus: String, Encodable, CaseIterable {
    case instructions
    case camera
    case verifying
    case success
    case failure
    case cameraAccessNotAllowed
}

public struct QRLoginScanQRCodeScreenStateTotalLabels: Encodable, Equatable {
    let stateId: QRLoginScanQRCodeScreenStateStatus

    enum CodingKeys: String, CodingKey {
        case stateId = "state_id"
    }
}

extension ObservabilityEvent where Payload == PayloadWithLabels<QRLoginScanQRCodeScreenStateTotalLabels> {
    public static func qrLoginScanQRCodeScreenState(stateId: QRLoginScanQRCodeScreenStateStatus) -> Self {
        .init(name: "ios_core_qr_login_scan_qr_code_screen_total",
              labels: .init(stateId: stateId),
              version: .v1)
    }
}
