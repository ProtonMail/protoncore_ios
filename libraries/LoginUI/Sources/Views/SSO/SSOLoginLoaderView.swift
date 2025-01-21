//
//  SignInRequestView.swift
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

import ProtonCoreUIFoundations
import SwiftUI

public struct SSOLoginLoaderView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let loaderSize: CGFloat = 33
        static let cornerRadius: CGFloat = 16
        static let avatarSize: CGFloat = 28
        static let avatarPadding: CGFloat = 14
        static let avatarCornerRadius: CGFloat = 8
        static let standardPadding: CGFloat = 12
        static let itemsPadding: CGFloat = 24
        static let titlePadding: CGFloat = 8
        static let imageSize: CGFloat = 45
        static let imagePadding: CGFloat = 10
        static let imageCornerRadius: CGFloat = 12
    }

    public var body: some View {
        VStack(spacing: Constants.itemsPadding) {
            if viewModel.bannerState == .none {
                ProtonLoaderView(size: Constants.loaderSize)
                    .frame(width: Constants.loaderSize, height: Constants.loaderSize)
            } else {
                defaultOrganizationImage
            }

            VStack(spacing: Constants.titlePadding) {
                Text(LUITranslation.signing_you_in.l10n)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(ColorProvider.TextNorm)
                Text(LUITranslation.to_your_organization.l10n)
                    .font(.title3)
                    .foregroundColor(ColorProvider.TextHint)
            }
            
            emailContainer

            Spacer()
        }
        .padding()
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
        .bannerDisplayable(
            bannerState: $viewModel.bannerState,
            configuration: .init(
                position: .bottom,
                dismissDuration: nil
            )
        )
    }

    @ViewBuilder
    var emailContainer: some View {
        HStack(spacing: Constants.avatarPadding) {
            avatarIcon
            Text(verbatim: viewModel.memberEmail)
                .font(.subheadline)
                .foregroundColor(ColorProvider.TextNorm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.standardPadding)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(ColorProvider.SeparatorNorm, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var avatarIcon: some View {
        ZStack {
            Color(uiColor: ColorProvider.IconAccent)
                .frame(width: Constants.avatarSize, height: Constants.avatarSize)
                .cornerRadius(Constants.avatarCornerRadius)
            Text(viewModel.avatarInitials)
                .foregroundColor(ColorProvider.White)
        }
    }

    @ViewBuilder
    private var defaultOrganizationImage: some View {
        IconProvider.users
            .resizable()
            .foregroundColor(ColorProvider.White)
            .padding(Constants.imagePadding)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .background(ColorProvider.BrandNorm)
            .cornerRadius(Constants.imageCornerRadius)
    }
}

#if DEBUG
import ProtonCoreDataModel
import ProtonCoreLogin

#Preview("Loading") {
    SSOLoginLoaderView(viewModel: .init(dependencies: .init(user: .mock, errorRetryAction: nil)))
}

#Preview("Error") {
    SSOLoginLoaderView(viewModel: .init(dependencies: .init(
        user: .mock,
        errorRetryAction: .init(error: LoginError.initialError(message: "Your error"), retryAction: {})
    )))
}
#endif

#endif
