//
//  SSOLoginErrorView.swift
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

public struct SSOLoginErrorView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let avatarSize: CGFloat = 28
        static let avatarPadding: CGFloat = 14
        static let avatarCornerRadius: CGFloat = 8
        static let emailContainerPadding: CGFloat = 12
        static let itemsPadding: CGFloat = 24
        static let titlePadding: CGFloat = 8
    }

    public var body: some View {
        VStack(spacing: Constants.itemsPadding) {

            VStack(alignment: .leading, spacing: Constants.titlePadding) {
                Text(LUITranslation.sso_login_error_screen_title.l10n)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorProvider.TextNorm)
                Text(LUITranslation.sso_login_error_screen_description.l10n)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextHint)
            }

            emailContainer

            PCButton(
                style: .constant(.init(mode: .solid)),
                content: .constant(.init(
                    title: LUITranslation.continue_core_button.l10n,
                    action: viewModel.continueButtonTapped
                ))
            )
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
        .padding(Constants.emailContainerPadding)
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
}

#if DEBUG
import ProtonCoreDataModel
import ProtonCoreLogin

#Preview {
    SSOLoginErrorView(viewModel: .init(dependencies: .init(
        user: .mock,
        error: SSOLoginError.authDeviceNotFound,
        continueAction: {}
    )))
}
#endif

#endif
