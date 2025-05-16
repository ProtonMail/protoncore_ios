//
//  SetBackupPasswordView.swift
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
import ProtonCoreObservability
import ProtonCoreUIFoundations

public struct SetBackupPasswordView: View {

    @StateObject var viewModel: ViewModel

    @State var saveButtonIsEnabled = false

    private enum Constants {
        static let itemSpacing: CGFloat = 20
        static let imageCornerRadius: CGFloat = 12
        static let imageSize: CGFloat = 56
        static let standardPadding: CGFloat = 12
    }

    var textFieldContents: [String] {[
        viewModel.backupPasswordContent.text,
        viewModel.repeatBackupPasswordContent.text
    ]}

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {

                screenTitle

                Text(LUITranslation.backup_password_description.l10n)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PCTextField(
                    style: $viewModel.backupPasswordStyle,
                    content: $viewModel.backupPasswordContent
                )

                PasswordPolicyView(viewModel: viewModel.passwordPolicyViewModel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, -16)

                PCTextField(
                    style: $viewModel.repeatBackupPasswordStyle,
                    content: $viewModel.repeatBackupPasswordContent
                )

                PCButton(
                    style: .constant(.init(mode: .solid())),
                    content: .constant(.init(
                        title: LUITranslation.continue_core_button.l10n,
                        isEnabled: saveButtonIsEnabled,
                        isAnimating: viewModel.viewState == .loading,
                        action: viewModel.continueTapped
                    ))
                )
                .padding(.top, Constants.itemSpacing)
            }
            .padding(Constants.itemSpacing)
            .foregroundColor(ColorProvider.TextNorm)
            .background(ColorProvider.BackgroundNorm)
            .frame(maxWidth: .infinity)
            .disabled(viewModel.viewState == .loading)
        }
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
        .bannerDisplayable(bannerState: $viewModel.bannerState,
                           configuration: .default())
        .onChange(of: textFieldContents) { _ in
            saveButtonIsEnabled = textFieldContents.first(where: { $0.isEmpty }) == nil
        }
        .onChange(of: viewModel.backupPasswordContent.text) { _ in
            let password = viewModel.backupPasswordContent.text
            viewModel.passwordPolicyViewModel
                .checkPassword(password)
        }
        .onAppear {
            viewModel.backupPasswordContent.focus()
            switch viewModel.mode {
            case .setNewBackupPassword:
                ObservabilityEnv.report(.ssoScreenState(stateId: .passwordSetup))
            case .changeTemporaryPassword:
                ObservabilityEnv.report(.ssoScreenState(stateId: .passwordChange))
            }
        }
        .onLoad {
            viewModel.loadOrganizationLogo()
            viewModel.passwordPolicyViewModel.loadPasswordPolicies()
        }
    }

    @ViewBuilder
    private var screenTitle: some View {
        switch viewModel.mode {
        case .setNewBackupPassword:
            joinOrganizationHeader
        case .changeTemporaryPassword:
            Text(viewModel.screenTitle)
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var joinOrganizationHeader: some View {
        organizationImage
        VStack(spacing: Constants.standardPadding) {
            Text(viewModel.screenTitle)
                .font(.title2)
                .fontWeight(.bold)
            joinOrganizationSubtitle
        }
        Divider()
            .background(ColorProvider.SeparatorNorm)
    }

    private var joinOrganizationSubtitle: some View {
        var attributedString = AttributedString(viewModel.joinOrganizationSubtitle)

        attributedString.font = Font.subheadline.weight(.semibold)
        attributedString = attributedString.withBoldText(text: viewModel.organizationAdminEmail)

        return Text(attributedString)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var organizationImage: some View {
        if let organizationLogoURL = viewModel.organizationLogoURL {
            AsyncImage(url: organizationLogoURL) { image in
                image
                    .resizable()
                    .frame(width: Constants.imageSize, height: Constants.imageSize)
                    .cornerRadius(Constants.imageCornerRadius)
            } placeholder: {
                defaultOrganizationImage
            }

        } else {
            defaultOrganizationImage
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
import ProtonCoreCrypto
import ProtonCoreDataModel
import ProtonCoreLogin
import ProtonCoreServices

let emptyApiService = PMAPIService.createAPIServiceWithoutSession(environment: .custom(""),
                                                                  challengeParametersProvider: .empty)

#Preview("Set new backup password") {
    NavigationView {
        SetBackupPasswordView(viewModel: .init(dependencies: .init(
            mode: .setNewBackupPassword(organizationInfo: .init(
                organizationName: "Proton AG",
                organizationAdminEmail: "admin@privacybydefault.com",
                organizationLogoID: nil,
                organizationPublicKey: .init(value: "")
            )),
            apiService: emptyApiService,
            userData: .init(
                credential: .none,
                user: .mock,
                salts: [],
                passphrases: [:],
                addresses: [],
                scopes: []
            ),
            loginService: nil,
            ssoNavigationDelegate: nil
        )))
    }
}

#Preview("Change temporary password") {
    NavigationView {
        SetBackupPasswordView(viewModel: .init(dependencies: .init(
            mode: .changeTemporaryPassword,
            apiService: emptyApiService,
            userData: .init(
                credential: .none,
                user: .mock,
                salts: [],
                passphrases: [:],
                addresses: [],
                scopes: []
            ),
            loginService: nil,
            ssoNavigationDelegate: nil
        )))
    }
}
#endif

#endif


