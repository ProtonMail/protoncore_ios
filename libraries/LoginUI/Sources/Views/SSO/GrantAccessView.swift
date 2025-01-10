//
//  GrantAccessView.swift
//  ProtonCore-LoginUI - Created on 07/01/2025.
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
import ProtonCoreLogin
import ProtonCoreUIFoundations

public struct GrantAccessView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 20
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                Text(LUITranslation.sign_in_request_title.l10n)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                bodyText()

                confirmationCodeInput

                VStack {
                    PCButton(
                        style: .constant(.init(mode: .solid)),
                        content: .constant(.init(
                            title: LUITranslation.yes_it_was_me.l10n,
                            action: viewModel.primaryActionButtonTapped
                        ))
                    )

                    PCButton(
                        style: .constant(.init(mode: .text)),
                        content: .constant(.init(
                            title: LUITranslation.no_it_wasnt_me.l10n,
                            action: viewModel.secondaryActionButtonTapped
                        ))
                    )
                }
                .padding(.top, Constants.itemSpacing)

                Spacer()
            }
            .padding(Constants.itemSpacing)
            .foregroundColor(ColorProvider.TextNorm)
            .frame(maxWidth: .infinity)
        }
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
        .bannerDisplayable(bannerState: $viewModel.bannerState,
                           configuration: .init(position: .bottom))
    }

    private func bodyText() -> some View {
        var attributedString = AttributedString(viewModel.bodyDescription)

        attributedString.font = Font.subheadline
        attributedString.foregroundColor = ColorProvider.TextWeak
        attributedString = attributedString.withBoldText(text: viewModel.memberEmail)

        return Text(attributedString)
            .frame(maxWidth: .infinity, alignment: .leading)
    }


    @ViewBuilder
    private var confirmationCodeInput: some View {
        PCTextField(
            style: $viewModel.confirmationCodeStyle,
            content: $viewModel.confirmationCodeContent
        )

        Text(LUITranslation.sign_in_request_disclaimer.l10n)
            .font(.subheadline)
            .foregroundColor(ColorProvider.TextWeak)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

#Preview("ApprovingAccess") {
    NavigationView {
        GrantAccessView(viewModel: .init(dependencies: .init(
            apiService: nil,
            authDevices: [.mock],
            userData: .init(
                credential: .none,
                user: .mock,
                salts: [],
                passphrases: [:],
                addresses: [],
                scopes: []
            ),
            navigationDelegate: nil
        )))
    }
}
#endif

#endif
