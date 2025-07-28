//
//  ErrorView.swift
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

struct ErrorView: View {

    private enum Spacing {
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    let buttonAction: @Sendable () -> Void

    var body: some View {
            VStack {
                Image("error_image", bundle: Bundle.module)
                Text(PaymentsUIV2Localizer.Error_view_title.l10n)
                    .font(.headline)
                    .padding(.top, Spacing.extraLarge)
                Text(PaymentsUIV2Localizer.Error_view_message.l10n)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.large)

                IconButton(action: {
                        buttonAction()
                }, title: PaymentsUIV2Localizer.Error_view_button_title.l10n, icon: Image(systemName: "arrow.clockwise"))
                .padding(.top, Spacing.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ColorProvider.BackgroundNorm)
    }
}

#Preview {
    ErrorView(buttonAction: {})
}
