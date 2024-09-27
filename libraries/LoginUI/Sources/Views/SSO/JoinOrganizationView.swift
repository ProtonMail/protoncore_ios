//
//  JoinOrganizationView.swift
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

public struct JoinOrganizationView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 20
        static let imageCornerRadius: CGFloat = 12
        static let imageSize: CGFloat = 56
        static let standardPadding: CGFloat = 12
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                headerView
                
                Text(LUITranslation.backup_password_description.l10n)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PCTextField(
                    style: $viewModel.backupPasswordStyle,
                    content: $viewModel.backupPasswordContent
                )

                PCTextField(
                    style: $viewModel.repeatBackupPasswordStyle,
                    content: $viewModel.repeatBackupPasswordContent
                )

                PCButton(
                    style: .constant(.init(mode: .solid)),
                    content: .constant(.init(
                        title: LUITranslation.continue_core_button.l10n,
                        action: viewModel.continueTapped
                    ))
                )
                .padding(.top, Constants.itemSpacing)
            }
            .padding(Constants.itemSpacing)
            .foregroundColor(ColorProvider.TextNorm)
            .background(ColorProvider.BackgroundNorm)
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
        defaultOrganizationImage
        VStack(spacing: Constants.standardPadding) {
            Text(viewModel.joinOrganizationTitle)
                .font(.title2)
                .fontWeight(.bold)
            bodyText()
        }
        Divider()
            .background(ColorProvider.SeparatorNorm)
    }

    private func bodyText() -> some View {
        if #available(iOS 15, *) {
            var attributedString = AttributedString(viewModel.joinOrganizationDescription)

            attributedString.font = Font.subheadline.weight(.semibold)

            // make the email substrings heavier weight
            if let range = attributedString.range(of: viewModel.organizationEmail) {
                attributedString[range].font = Font.subheadline.weight(.bold)
            }

            return Text(attributedString)
                .multilineTextAlignment(.center)
        } else {
            return Text(viewModel.joinOrganizationDescription)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var defaultOrganizationImage: some View {
        IconProvider.users
            .resizable()
            .foregroundColor(ColorProvider.White)
            .padding(Constants.standardPadding)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .background(ColorProvider.BrandNorm)
            .cornerRadius(Constants.imageCornerRadius)
    }
}

#if DEBUG
#Preview {
    NavigationView {
        JoinOrganizationView(viewModel: .init(dependencies: .init()))
    }
}
#endif

#endif


