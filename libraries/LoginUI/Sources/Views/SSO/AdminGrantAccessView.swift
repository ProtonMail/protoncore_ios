//
//  AdminGrantAccessView.swift
//  ProtonCore-LoginUI - Created on 27/09/2024.
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

public struct AdminGrantAccessView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 24
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                Text(viewModel.screenTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                bodyText()

                PCTextField(
                    style: $viewModel.confirmationCodeStyle,
                    content: $viewModel.confirmationCodeContent
                )

                VStack {
                    PCButton(
                        style: .constant(.init(mode: .solid)),
                        content: .constant(.init(
                            title: viewModel.grantAccessButtonTitle,
                            action: viewModel.grantAccessButtonTapped
                        ))
                    )

                    PCButton(
                        style: .constant(.init(mode: .text)),
                        content: .constant(.init(
                            title: viewModel.denyAccessButtonTitle,
                            action: viewModel.denyAccessButtonTapped
                        ))
                    )
                }
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

    private func bodyText() -> some View {
        if #available(iOS 15, *) {
            var attributedString = AttributedString(viewModel.bodyDescription)

            attributedString.font = Font.subheadline
            attributedString.foregroundColor = ColorProvider.TextWeak

            // make the email substring heavier weight
            if let range = attributedString.range(of: viewModel.adminEmail) {
                attributedString[range].font = Font.subheadline.weight(.bold)
            }

            return Text(attributedString)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            return Text(viewModel.bodyDescription)
                .font(.subheadline)
                .foregroundColor(ColorProvider.TextWeak)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        AdminGrantAccessView(viewModel: .init(dependencies: .init()))
    }
}
#endif

#endif
