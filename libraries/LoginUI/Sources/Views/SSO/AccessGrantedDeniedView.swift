//
//  AccessGrantedDeniedView.swift
//  ProtonCore-LoginUI - Created on 23/08/2024.
//
//  Copyright (c) 2024 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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

#if os(iOS)

import SwiftUI
import ProtonCoreUIFoundations

public struct AccessGrantedDeniedView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 24
        static let cornerRadius: CGFloat = 8
        static let imageSize: CGFloat = 80
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                headerView

                PCButton(
                    style: .constant(.init(mode: .solid)),
                    content: .constant(.init(
                        title: viewModel.primaryButtonTitle,
                        action: viewModel.primaryActionButtonTapped
                    ))
                )
                .padding(.top, Constants.itemSpacing)

                Spacer()
            }
            .padding(Constants.itemSpacing)
            .foregroundColor(ColorProvider.TextNorm)
            .frame(maxWidth: .infinity)
            .bannerDisplayable(bannerState: $viewModel.bannerState,
                               configuration: .default())
        }
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
    }

    @ViewBuilder
    private var headerView: some View {
        headerImageIcon
            .foregroundColor(ColorProvider.White)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
        VStack(spacing: Constants.itemSpacing) {
            Text(viewModel.screenTitle)
                .font(.title2)
                .fontWeight(.bold)
            Text(viewModel.bodyDescription)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var headerImageIcon: some View {
        switch viewModel.mode {
        case .accessGranted:
            IconProvider.userCheck.resizable()
        case .accessDenied:
            IconProvider.userExclamation.resizable()
        }
    }
}

#if DEBUG
#Preview("AccessGranted") {
    NavigationView {
        let mode = AccessGrantedDeniedView.ViewMode.accessGranted
        AccessGrantedDeniedView(viewModel: .init(dependencies: .init(mode: mode)))
    }
}
#Preview("AccessDenied") {
    NavigationView {
        let mode = AccessGrantedDeniedView.ViewMode.accessDenied
        AccessGrantedDeniedView(viewModel: .init(dependencies: .init(mode: mode)))
    }
}

#endif

#endif
