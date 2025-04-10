//
//  NoAvailblePlansView.swift
//  ProtonCore-PaymentsUIV2 - Created on 7/11/2024.
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

import SwiftUI
import ProtonCoreUI

public enum NoAvailblePlansViewType {
    case noPlans
    case filterEmtpy


    public var title: String {
        switch self {
        case .noPlans:
            return PaymentsUIV2Localizer.No_available_plan_title.l10n
        case .filterEmtpy:
            return PaymentsUIV2Localizer.No_filtered_plan_title.l10n
        }
    }

    public var message: String {
        switch self {
        case .noPlans:
            return PaymentsUIV2Localizer.No_available_plan_message.l10n
        case .filterEmtpy:
            return PaymentsUIV2Localizer.No_filtered_plan_message.l10n
        }
    }
}

struct NoAvailblePlansView: View {

    let type: NoAvailblePlansViewType

    var body: some View {
        ZStack {
            Color(Theme.color.backgroundNorm)
                .ignoresSafeArea()
            VStack {
                Image("empty_result_image", bundle: Bundle.module)
                Text(type.title)
                    .font(.headline)
                    .padding(.top, Theme.spacing.extraLarge)
                Text(type.message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.top, Theme.spacing.large)
            }
            .padding(Theme.spacing.large)
        }
    }
}

#Preview {
    NoAvailblePlansView(type: .noPlans)
}
