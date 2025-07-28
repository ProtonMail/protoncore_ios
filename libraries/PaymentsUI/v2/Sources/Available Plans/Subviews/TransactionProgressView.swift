//
//  TransactionProgressView.swift
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

struct TransactionProgressView: View {

    @Binding var confirmationCompleted: Bool
    @Binding var updateCompleted: Bool

    private struct Spacing {
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    var body: some View {
        VStack {
            Image("transaction_image", bundle: Bundle.module)
            Text(PaymentsUIV2Localizer.Transaction_state_view_title.l10n)
                .font(.headline)
                .padding(.top, Spacing.extraLarge)
            Text(PaymentsUIV2Localizer.Transaction_state_view_subtitle.l10n)
                .font(.subheadline)
                .multilineTextAlignment(.center)

            StateProgressView(progressCompleted: $confirmationCompleted,
                              stateProgressText: PaymentsUIV2Localizer.Transaction_state_payment_confirmation_progress.l10n,
                              stateCompleteText: PaymentsUIV2Localizer.Transaction_state_payment_confirmation_complete.l10n)
            .padding(.top, Spacing.extraLarge)
            if confirmationCompleted {
                StateProgressView(progressCompleted: $updateCompleted,
                                  stateProgressText: PaymentsUIV2Localizer.Transaction_state_payment_account_update_progress.l10n,
                                  stateCompleteText: PaymentsUIV2Localizer.Transaction_state_payment_account_update_complete.l10n)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorProvider.BackgroundNorm)
    }
}

#Preview {
    TransactionProgressView(confirmationCompleted: .constant(true), updateCompleted: .constant(false))
}
