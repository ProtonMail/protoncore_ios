//
//  AvailablePlansView.swift
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
import ProtonCorePaymentsV2
import ProtonCoreUI

public struct AvailablePlansView: View {

    @ObservedObject var viewModel: AvailablePlansViewModel

    public var body: some View {
        ZStack {
            Color(Theme.color.backgroundNorm)
                .ignoresSafeArea()

            VStack {
                SubscriptionsViewHeader()
                switch viewModel.viewState {
                case .dataLoaded:
                    AvailablePlansBodyView(viewModel: viewModel)
                case .fetching:
                    LoadingView(loadingMessage: String(localized: "Loading_plans_message", bundle: .module))
                case .errorData, .idle, .purchasing:
                    GeometryReader { proxy in
                        ErrorView(buttonAction: {
                            Task {
                                await viewModel.fetchData()
                            }
                        })
                        .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                    }
                }
            }
            .overlay(content: {
                if viewModel.viewState == .purchasing {
                    TransactionProgressView(confirmationCompleted: $viewModel.confirmationCompleted,
                                            updateCompleted: $viewModel.updateCompleted)
                }
            })
            .onAppear {
                Task {
                    if viewModel.viewState != .dataLoaded {
                        await viewModel.fetchData()
                    }
                }
            }
            .bannerDisplayable(bannerState: $viewModel.showAlert, configuration: .default())
        }
    }

    public init(viewModel: AvailablePlansViewModel) {
        self.viewModel = viewModel
    }
}

// swiftlint:disable line_length
#Preview {

    let productVPNMonthly = ProductMock(displayName: "name", description: "description", displayPrice: "$12", price: Decimal(12), id: "iosvpn_bundle2022_12_usd_auto_recurring")
    let productVPNYearly = ProductMock(displayName: "name", description: "description", displayPrice: "$49", price: Decimal(49), id: "iosvpn_bundle2022_12_usd_auto_recurring")

    let product2 = ProductMock(displayName: "name", description: "description", displayPrice: "$149", price: Decimal(149), id: "iosvpn_bundle2022_12_usd_auto_recurring")

    let composedPlan = ComposedPlan(plan: ProtonCorePaymentsV2.Examples.availablePlanExample(title: "VPN Plus",
                                                                                             entitlements: PreviewsData.descriptionEntitlements()),
                                    instance: ProtonCorePaymentsV2.Examples.planInstance(cycle: 1),
                                    product: productVPNMonthly)

    let composedPlan2 = ComposedPlan(plan: ProtonCorePaymentsV2.Examples.availablePlanExample(title: "VPN Unlimited",
                                                                                              cycle: 12,
                                                                                              entitlements: PreviewsData.descriptionEntitlements()),
                                     instance: ProtonCorePaymentsV2.Examples.planInstance(cycle: 12),
                                     product: product2)

    let composedPlan5 = ComposedPlan(plan: ProtonCorePaymentsV2.Examples.availablePlanExample(title: "VPN Plus",
                                                                                              entitlements: PreviewsData.descriptionEntitlements()),
                                     instance: ProtonCorePaymentsV2.Examples.planInstance(cycle: 12),
                                     product: productVPNYearly)

    let planViewModel = PlanViewModel(envURL: .paymentsBlack,
                                               remoteManager: PreviewsData.remoteManager,
                                               composedPlan: composedPlan)

    let planViewModel2 = PlanViewModel(envURL: .paymentsBlack,
                                                remoteManager: PreviewsData.remoteManager,
                                                composedPlan: composedPlan2)

    let planViewModel3 = PlanViewModel(envURL: .paymentsBlack,
                                                remoteManager: PreviewsData.remoteManager,
                                                currentPlan: PreviewsData.currentSub)

    let planViewModel4 = PlanViewModel(envURL: .paymentsBlack,
                                                remoteManager: PreviewsData.remoteManager,
                                                currentPlan: PreviewsData.freePlan)

    let planViewModel5 = PlanViewModel(envURL: .paymentsBlack,
                                       remoteManager: PreviewsData.remoteManager,
                                       composedPlan: composedPlan5)

  //  let allPlans = [planViewModel3, planViewModel4, planViewModel, planViewModel2]
    let availablePlans = [planViewModel, planViewModel2, planViewModel5]

    // Current plan
    let currentPlan = PlanViewModel(envURL: .paymentsBlack,
                                    remoteManager: PreviewsData.remoteManager,
                                    currentPlan: PreviewsData.currentSub)

    let viewModel = AvailablePlansViewModel(sessionId: "123",
                                            token: "1231da",
                                            envURL: .paymentsBlack,
                                            appVersion: "VPN@5.5.0")
    viewModel.addPlanViewModels(availablePlans)
    viewModel.setBillingCycle(.all)
    // viewModel.showBanner()
    viewModel.setCurrentPlan(currentPlan)

    return AvailablePlansView(viewModel: viewModel)
}
