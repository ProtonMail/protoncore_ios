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

                    HStack {
                        Picker("", selection: $viewModel.billingCycle) {
                            ForEach(viewModel.billing, id: \.self) {
                                Text($0.displayName)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.color.iconAccent)
                        .onChange(of: viewModel.billingCycle) { _ in
                            viewModel.billingFilter(filter: viewModel.billingCycle)
                        }

                        Spacer()
                    }
                    .padding(Theme.spacing.large)

                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.filteredPlans, id: \.id) { viewModel in
                            PlanView(viewModel: viewModel)
                                .padding(.top, Theme.spacing.standard)
                        }
                        FooterView(image: Theme.icon.infoCircle,
                                   text: String(localized: "Plans_footer_disclaimer", bundle: .module))

                        .padding(.top, Theme.spacing.extraLarge)
                    }
                    .refreshable {
                        await viewModel.fetchAvailablePlans()
                    }
                    .padding(.horizontal, Theme.spacing.large)

                case .fetching:
                    LoadingView(loadingMessage: String(localized: "Loading_plans_message", bundle: .module))
                case .noPlans:
                    NoAvailblePlansView()
                case .errorData, .idle, .purchasing:
                    GeometryReader { proxy in
                        ErrorView(buttonAction: {
                            Task {
                                await viewModel.fetchAvailablePlans()
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
                        await viewModel.fetchAvailablePlans()
                    }
                }
            }
        }
    }

    public init(viewModel: AvailablePlansViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {

    let product = ProductMock(displayName: "name", description: "description", displayPrice: "$12", price: Decimal(12), id: "iosvpn_bundle2022_12_usd_auto_recurring")
    let product2 = ProductMock(displayName: "name", description: "description", displayPrice: "$149", price: Decimal(149), id: "iosvpn_bundle2022_12_usd_auto_recurring")

    let composedPlan = ComposedPlan(plan: ProtonCorePaymentsV2.Examples.availablePlanExample(title: "VPN Plus", entitlements: PreviewsData.descriptionEntitlements()), instance: ProtonCorePaymentsV2.Examples.planInstance(cycle: 1), product: product)

    let planViewModel = PlanViewModel(envURL: .paymentsBlack,
                                               remoteManager: PreviewsData.remoteManager,
                                               composedPlan: composedPlan)

    let composedPlan2 = ComposedPlan(plan: ProtonCorePaymentsV2.Examples.availablePlanExample(title: "VPN Unlimited", cycle: 12, entitlements: PreviewsData.descriptionEntitlements()),
                                     instance: ProtonCorePaymentsV2.Examples.planInstance(cycle: 12),
                                     product: product2)

    let planViewModel2 = PlanViewModel(envURL: .paymentsBlack,
                                                remoteManager: PreviewsData.remoteManager,
                                                composedPlan: composedPlan2)

    let planViewModel3 = PlanViewModel(envURL: .paymentsBlack,
                                                remoteManager: PreviewsData.remoteManager,
                                                currentPlan: PreviewsData.currentSub)

    let planViewModel4 = PlanViewModel(envURL: .paymentsBlack,
                                                remoteManager: PreviewsData.remoteManager,
                                                currentPlan: PreviewsData.freePlan)

    let viewModel = AvailablePlansViewModel(sessionId: "123", token: "1231da", envURL: .paymentsBlack, appVersion: "VPN@5.5.0")
    viewModel.addPlanViewModels([planViewModel3, planViewModel4, planViewModel, planViewModel2])
    viewModel.setBillingCycle(.all)

    return AvailablePlansView(viewModel: viewModel)
}
