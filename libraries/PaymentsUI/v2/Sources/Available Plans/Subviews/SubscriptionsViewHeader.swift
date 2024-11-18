//
//  SubscriptionsViewHeader.swift
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

public struct SubscriptionsViewHeader: View {

    private let icons = ["proton_mail", "proton_cal", "proton_drive", "proton_vpn", "proton_pass", "proton_wallet"]

    public var body: some View {
        VStack(spacing: Theme.spacing.standard) {
            Text(String(localized: "Available_subscriptions_view_title", bundle: .module))
                .font(.title2)
                .fontWeight(.bold)
            Text(String(localized: "Available_subscriptions_view_subtitle", bundle: .module))
                .font(.caption)
            HStack(spacing: Theme.spacing.standard) {
                ForEach(icons, id: \.self) { iconName in
                    Image(iconName, bundle: Bundle.module)
                }
            }
        }
    }
}

#Preview {
    SubscriptionsViewHeader()
}
