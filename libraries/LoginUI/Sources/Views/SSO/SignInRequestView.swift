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
import ProtonCoreLogin
import ProtonCoreObservability
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

                bodyText()

                confirmationCodeContainer

                VStack {
                    PCButton(
                        style: .constant(.init(mode: .solid())),
                        content: .constant(.init(
                            title: viewModel.primaryButtonTitle,
                            action: viewModel.primaryActionButtonTapped
                        ))
                    )

                    PCButton(
                        style: .constant(.init(mode: .text)),
                        content: .constant(.init(
                            title: viewModel.secondaryButtonTitle,
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
            .disabled(viewModel.viewState == .loading)
        }
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
        .bannerDisplayable(bannerState: $viewModel.bannerState,
                           configuration: .default())
        .onAppear {
            viewModel.startAuthDeviceLoop()
            switch viewModel.mode {
            case .requestForAdminApproval:
                ObservabilityEnv.report(.ssoScreenState(stateId: .waitingAdmin))
            case .requestApproveFromAnotherDevice:
                ObservabilityEnv.report(.ssoScreenState(stateId: .waitingMember))
            }
        }
        .onDisappear {
            viewModel.stopAuthDeviceLoop()
        }
    }

    @ViewBuilder
    var confirmationCodeContainer: some View {
        switch viewModel.mode {
        case .requestForAdminApproval(let code, _):
            displayConfirmationCode(code: code)
        case .requestApproveFromAnotherDevice(let code, _):
            displayConfirmationCode(code: code)
            devicesContainer
                .padding(.top, Constants.itemSpacing)
        }
    }

    private func bodyText() -> some View {
        var attributedString = AttributedString(viewModel.bodyDescription)

        attributedString.font = Font.subheadline
        attributedString.foregroundColor = ColorProvider.TextWeak
        if case let .requestForAdminApproval(_, adminEmail) = viewModel.mode {
            attributedString = attributedString.withBoldText(text: adminEmail)
        }
        attributedString = attributedString.withBoldText(text: viewModel.memberEmail)

        return Text(attributedString)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    var devicesContainer: some View {
        VStack(alignment: .leading, spacing: Constants.itemSpacing) {
            Text(LUITranslation.devices_available.l10n)
                .font(.subheadline)
                .foregroundColor(ColorProvider.TextWeak)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(viewModel.devices, id: \.self.ID) { device in
                deviceItem(device: device)
            }
        }
    }

    @ViewBuilder
    func deviceItem(device: AuthDevice) -> some View {
        HStack(alignment: .top, spacing: Constants.itemSpacing) {
            device.icon
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
        let devices: [AuthDevice] = [.mock, .mock]
        let mode = SignInRequestView.ViewMode.requestApproveFromAnotherDevice(code: "64S3", devices: devices)
        SignInRequestView(viewModel: .init(dependencies: .init(
            mode: mode,
            apiService: nil,
            userData: .init(
                credential: .none,
                user: .mock,
                salts: [],
                passphrases: [:],
                addresses: [],
                scopes: []
            ),
            ssoNavigationDelegate: nil,
            onDeviceActivatedAction: {},
            onDeviceRejectedAction: {}
        )))
    }
}
#Preview("RequestForAdminApproval") {
    NavigationView {
        let mode = SignInRequestView.ViewMode.requestForAdminApproval(code: "64S3", adminEmail: "admin@privacybydefault.com")
        SignInRequestView(viewModel: .init(dependencies: .init(
            mode: mode,
            apiService: nil,
            userData: .init(
                credential: .none,
                user: .mock,
                salts: [],
                passphrases: [:],
                addresses: [],
                scopes: []
            ),
            ssoNavigationDelegate: nil,
            onDeviceActivatedAction: {},
            onDeviceRejectedAction: {}
        )))
    }
}
#endif

#endif
