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
import ProtonCoreUI

struct PlanDetailView: View {

    private struct Constants {
        static var iconSize: CGFloat = 15
        static var buttonTopPadding: CGFloat = 10
        static var entitlementTextVerticalOffset: CGFloat = -3
        static var entitlementTextSize: CGFloat = 14
        static var entitlementFontWeight: Font.Weight = .regular
    }

    @StateObject var viewModel: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.standard) {
            ForEach(viewModel.descriptionEntitlements, id: \.self) { entitlement in
                HStack(alignment: .top) {
                    PCAsyncImage(url: viewModel.iconURLforEntitlement(entitlement),
                                 placeholderImage: Theme.icon.checkmark) { image in
                        image
                            .resizable()
                            .renderingMode(.template)
                    } placeholder: {
                        ProgressView()
                    }
                    .foregroundColor(Theme.color.iconAccent)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    Text(entitlement.text)
                        .font(.system(size: Constants.entitlementTextSize))
                        .fontWeight(Constants.entitlementFontWeight)
                        .padding(.top, Constants.entitlementTextVerticalOffset)
                }
            }
            if !viewModel.isCurrentPlan {


                PCButton(style: .constant(.init(mode: .solid)),
                         content: .constant(.init(title: String(format: String(localized: "Purchase_button_title", bundle: .module), viewModel.title), action: {
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
