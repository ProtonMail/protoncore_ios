//
//  CurrentPlanPageLoad.swift
//  ProtonCore-Observability - Created on 29.08.2023.
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

import ProtonCoreNetworking

public struct CurrentPlanPageLoadLabels: Encodable, Equatable {
    let status: SuccessOrFailureStatus

    enum CodingKeys: String, CodingKey {
        case status
    }
}

extension ObservabilityEvent where Payload == PayloadWithLabels<CurrentPlanPageLoadLabels> {
    private enum Constants {
        static let eventName = "ios_core_current_plan_page_load_total"
    }

    public static func currentPlanPageLoad(status: SuccessOrFailureStatus) -> Self {
        ObservabilityEvent(name: Constants.eventName, labels: CurrentPlanPageLoadLabels(status: status))
    }
}
