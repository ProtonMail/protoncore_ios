//
//  AvailablePlansBodyView.swift
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

import ProtonCoreUIFoundations
import SwiftUI

struct AvailablePlansBodyView: View {

    private struct Spacing {
        static let standard: CGFloat = 8
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    @ObservedObject var viewModel: AvailablePlansViewModel

    var body: some View {

        VStack {
            // MARK: Header
            if viewModel.hideCurrentPlan {
                SubscriptionsViewHeader()
                    .padding(.bottom, viewModel.hideCurrentPlan ? Spacing.extraLarge : 0)
            }

            // MARK: Available plans section title
            if !viewModel.hideCurrentPlan {
                HStack {
                    Text(PaymentsUIV2Localizer.Available_plans_section_title.l10n)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, Spacing.extraLarge)
                .opacity(viewModel.hasAvailablePlans ? 1 : 0)
            }

            // MARK: Plan filter picker
            HStack {
                Picker("", selection: $viewModel.billingCycle) {
                    ForEach(viewModel.billing, id: \.self) {
                        Text($0.displayName)
                    }
                }
                .pickerStyle(.menu)
                .tint(ColorProvider.IconAccent)
                .onChange(of: viewModel.billingCycle) { _ in
                    viewModel.billingFilter(filter: viewModel.billingCycle)
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.large)
            .opacity(viewModel.hasAvailablePlans ? 1 : 0)

            // MARK: Available plans

            ScrollView(showsIndicators: false) {
                if viewModel.hasAvailablePlans {
                    if viewModel.isFilterEmpty {
                        NoAvailblePlansView(type: .filterEmtpy)
                    } else {
                        ForEach(viewModel.filteredPlans, id: \.id) { viewModel in
                            PlanView(viewModel: viewModel)
                                .padding(.top, Spacing.standard)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.bottom, viewModel.bottomPadding)
        }
    }
}
