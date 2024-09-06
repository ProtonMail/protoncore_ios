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

public struct SignInRequestView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 20
        static let codePadding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
        static let deviceIconSize: CGFloat = 24
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                Text(viewModel.screenTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(viewModel.bodyDescription)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
                    .frame(maxWidth: .infinity, alignment: .leading)

                confirmationCodeContainer

                VStack {
                    PCButton(
                        style: .constant(.init(mode: .solid)),
                        content: .constant(.init(
                            title: viewModel.primaryButtonActionTitle,
                            action: viewModel.primaryActionButtonTapped
                        ))
                    )

                    PCButton(
                        style: .constant(.init(mode: .text)),
                        content: .constant(.init(
                            title: viewModel.secondaryButtonActionTitle,
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
            .bannerDisplayable(bannerState: $viewModel.bannerState,
                               configuration: .default())
        }
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
    }

    @ViewBuilder
    var confirmationCodeContainer: some View {
        switch viewModel.mode {
        case .requestForAdminApproval(let code):
            displayConfirmationCode(code: code)
        case .requestApproveFromAnotherDevice(let code):
            displayConfirmationCode(code: code)
            devicesContainer
                .padding(.top, Constants.itemSpacing)
        case .approvingAccess:
            confirmationCodeInput
        }
    }

    private func displayConfirmationCode(code: String) -> some View {
        VStack {
            Text(LUITranslation.confirmation_code.l10n)
            HStack {
                ForEach(Array(code.enumerated()), id: \.offset) { character in
                    Text(String(character.element))
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(Constants.codePadding)
                        .background(ColorProvider.BackgroundSecondary)
                        .cornerRadius(Constants.cornerRadius)

                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(ColorProvider.SeparatorNorm, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var confirmationCodeInput: some View {
        PCTextField(
            style: .constant(.init(mode: .idle)),
            content: $viewModel.confirmationCodeContent
        )

        Text(LUITranslation.sign_in_request_disclaimer.l10n)
            .font(.subheadline)
            .foregroundColor(ColorProvider.TextWeak)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var devicesContainer: some View {
        VStack(alignment: .leading, spacing: Constants.itemSpacing) {
            Text(LUITranslation.devices_available.l10n)
                .font(.subheadline)
                .foregroundColor(ColorProvider.TextWeak)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(viewModel.devices, id: \.self.name) { device in
                deviceItem(device: device)
            }
        }
    }

    @ViewBuilder
    func deviceItem(device: DeviceViewModel) -> some View {
        HStack(alignment: .top, spacing: Constants.itemSpacing) {
            IconProvider.tv
                .resizable()
                .frame(width: Constants.deviceIconSize, height: Constants.deviceIconSize)
            VStack(alignment: .leading) {
                Text(device.name)
                    .fontWeight(.semibold)
                Text(device.localizedClientName)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
                Text(device.lastActivityString)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
            }
        }
    }
}

#if DEBUG
#Preview("RequestApproveFromAnotherDevice") {
    NavigationView {
        let mode = SignInRequestView.ViewMode.requestApproveFromAnotherDevice(code: "64S3")
        SignInRequestView(viewModel: .init(dependencies: .init(mode: mode)))
    }
}
#Preview("RequestForAdminApproval") {
    NavigationView {
        let mode = SignInRequestView.ViewMode.requestForAdminApproval(code: "64S3")
        SignInRequestView(viewModel: .init(dependencies: .init(mode: mode)))
    }
}

#Preview("ApprovingAccess") {
    NavigationView {
        SignInRequestView(viewModel: .init(dependencies: .init(mode: .approvingAccess)))
    }
}
#endif

#endif
