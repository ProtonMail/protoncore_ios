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

import SwiftUI
import ProtonCoreUIFoundations

public struct RequestAdminAccessView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 24
        static let cornerRadius: CGFloat = 8
        static let imageSize: CGFloat = 32
        static let imagePadding: CGFloat = 8
        static let padding: CGFloat = 12
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                Text(viewModel.screenTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                adminEmailContainer

                Text(viewModel.bodyDescription)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PCButton(
                    style: .constant(.init(mode: .solid)),
                    content: .constant(.init(
                        title: viewModel.continueButtonActionTitle,
                        action: viewModel.continueActionButtonTapped
                    ))
                )
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
    }

    @ViewBuilder
    var adminEmailContainer: some View {
        HStack {
            organizationImage
            Text(viewModel.adminEmailAddress)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.padding)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(ColorProvider.SeparatorNorm, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var organizationImage: some View {
        IconProvider.users
            .resizable()
            .foregroundColor(ColorProvider.White)
            .padding(Constants.imagePadding)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .background(ColorProvider.BrandNorm)
            .cornerRadius(Constants.cornerRadius)
    }
}

#if DEBUG
#Preview {
    NavigationView {
        RequestAdminAccessView(viewModel: .init(dependencies: .init()))
    }
}
#endif

#endif
