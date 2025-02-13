//
//  PlanView.swift
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

import ProtonCorePaymentsV2
import SwiftUI
import ProtonCoreUI

public struct PlanView: View {
    
    @ObservedObject public var viewModel: PlanViewModel
    
    public init(viewModel: PlanViewModel) {
        self.viewModel = viewModel
    }
    
    private struct Constants {
        static let borderWidth: CGFloat = 1
        
        static func backgroundColor(isCurrentPlan: Bool, isExpanded: Bool) -> Color {
            if isCurrentPlan {
                return Theme.color.backgroundNorm
            }
            
            return isExpanded ? Theme.color.backgroundNorm : Theme.color.backgroundSecondary
        }
        
        static func borderColor(isExpanded: Bool) -> Color {
            isExpanded ? Theme.color.iconAccent : Theme.color.backgroundSecondary
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.large) {
            
            PlanDetailHeaderView(isExpanded: $viewModel.isExpanded,
                                 title: viewModel.title,
                                 description: viewModel.description,
                                 formattedPrice: viewModel.formattedPrice,
                                 formattedPeriod: viewModel.formattedPeriod,
                                 showChevron: !viewModel.isCurrentPlan,
                                 decorationsURLs: viewModel.decorationsURLs())
            
            if viewModel.showProgressEntitlements {
                ForEach(viewModel.progressEntitlements, id: \.self) { progress in
                    ProgressEntitlementView(currentValue: progress.current, maxValue: progress.max, text: progress.text)
                }
            }
            
            if viewModel.isExpanded || viewModel.isCurrentPlan {
                PlanDetailView(viewModel: viewModel)
                    .padding(.top, Theme.spacing.large)
            }
            
            if let renewFooter = viewModel.renewFooter, viewModel.isCurrentPlan {
                Divider()
                Text(renewFooter)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundColor(Theme.color.textNorm)
        .padding(Theme.spacing.large)
        .background(Constants.backgroundColor(isCurrentPlan: viewModel.isCurrentPlan, isExpanded: viewModel.isExpanded))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radius.large))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius.large)
                .stroke(Constants.borderColor(isExpanded: viewModel.isExpanded), lineWidth: Constants.borderWidth)
        )
    }
}

#if DEBUG
#Preview {
    
    let product = ProductMock(displayName: "name", description: "description", displayPrice: "$12", price: Decimal(12), id: "iosvpn_bundle2022_12_usd_auto_recurring")
    
    // ViewModel displaying available plan
    let composedPlan = ComposedPlan(plan: ProtonCorePaymentsV2.Examples.availablePlanExample(title: "VPN Plus",
                                                                                             entitlements: PreviewsData.descriptionEntitlements()),
                                    instance: ProtonCorePaymentsV2.Examples.planInstance(),
                                    product: product)
    let viewModel = PlanViewModel(doh: PaymentsDoH(),
                                  remoteManager: PreviewsData.remoteManager,
                                  composedPlan: composedPlan)
    
    // ViewModel displaying current sub
    let viewModel2 = PlanViewModel(doh: PaymentsDoH(),
                                   remoteManager: PreviewsData.remoteManager,
                                   currentPlan: PreviewsData.currentSub)
    // ViewModel displaying Free plan
    let viewModel3 = PlanViewModel(doh: PaymentsDoH(),
                                   remoteManager: PreviewsData.remoteManager,
                                   currentPlan: PreviewsData.freePlan)
    
    return PlanView(viewModel: viewModel2)
        .padding(12)
}
#endif