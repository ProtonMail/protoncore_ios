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
import ProtonCoreUIFoundations

public struct SubscriptionsViewHeader: View {

    private struct Spacing {
        static let standard: CGFloat = 8
    }

    private let icons = ["proton_mail", "proton_cal", "proton_drive", "proton_vpn", "proton_pass", "proton_wallet"]

    public var body: some View {
        VStack(spacing: Spacing.standard) {
            Text(PaymentsUIV2Localizer.Available_subscriptions_view_title.l10n)
                .font(.title2)
                .fontWeight(.bold)
            Text(PaymentsUIV2Localizer.Available_subscriptions_view_subtitle.l10n)
                .font(.caption)
            HStack(spacing: Spacing.standard) {
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
