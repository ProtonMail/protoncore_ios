//
//  PlanDetailView.swift
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

struct PlanDetailView: View {

    private struct Constants {
        static let standardSpacing: CGFloat = 8
        static let iconSize: CGFloat = 15
        static let buttonTopPadding: CGFloat = 10
        static let entitlementTextVerticalOffset: CGFloat = -3
        static let entitlementTextSize: CGFloat = 14
        static let entitlementFontWeight: Font.Weight = .regular
    }

    @StateObject var viewModel: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.standardSpacing) {
            ForEach(viewModel.descriptionEntitlements, id: \.self) { entitlement in
                HStack(alignment: .top) {
                    PCAsyncImage(placeholderImage: IconProvider.checkmark, content: { image in
                        image
                            .resizable()
                            .renderingMode(.template)
                    }, placeholder: {
                        ProgressView()
                    }, dowloader: viewModel.downloaderForEntitlement(entitlement)
                    )
                    .foregroundColor(ColorProvider.IconAccent)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)

                    Text(entitlement.text)
                        .font(.system(size: Constants.entitlementTextSize))
                        .fontWeight(Constants.entitlementFontWeight)
                        .padding(.top, Constants.entitlementTextVerticalOffset)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if !viewModel.isCurrentPlan {

                PCButton(style: .constant(.init(mode: .solid())),
                         content: .constant(.init(title: String(format: PaymentsUIV2Localizer.Purchase_button_title.l10n, viewModel.title), action: {
                    Task {
                        await viewModel.purchasePlan()
                    }
                })))
                .padding(.top, Constants.buttonTopPadding)
            }
        }
    }
}

// #Preview {
//    PlanDetailView()
// }
