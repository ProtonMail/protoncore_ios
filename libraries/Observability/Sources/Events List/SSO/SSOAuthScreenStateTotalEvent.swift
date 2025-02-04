//
//  SSOAuthScreenStateTotalEvent.swift
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

public enum SSOAuthScreenState: String, Encodable, CaseIterable {
    case passwordSetup
    case passwordInput
    case passwordChange
    case requireAdmin
    case waitingAdmin
    case waitingMember
    case deviceRejected
    case deviceGranted
}

public struct SSOAuthScreenStateTotalLabels: Encodable, Equatable {
    let stateId: SSOAuthScreenState

    enum CodingKeys: String, CodingKey {
        case stateId = "state_id"
    }
}

extension ObservabilityEvent where Payload == PayloadWithLabels<SSOAuthScreenStateTotalLabels> {
    public static func ssoScreenState(stateId: SSOAuthScreenState) -> Self {
        .init(name: "ios_core_auth_sso_screenState_total",
              labels: .init(stateId: stateId),
              version: .v1)
    }
}
