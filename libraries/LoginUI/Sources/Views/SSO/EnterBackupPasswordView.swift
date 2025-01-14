//
//  EnterBackupPasswordView.swift
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

public struct EnterBackupPasswordView: View {

    @StateObject var viewModel: ViewModel

    private enum Constants {
        static let itemSpacing: CGFloat = 20
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Constants.itemSpacing) {
                Text(LUITranslation.enter_backup_password_title.l10n)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(LUITranslation.enter_backup_password_description.l10n)
                    .font(.subheadline)
                    .foregroundColor(ColorProvider.TextWeak)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PCTextField(
                    style: $viewModel.backupPasswordStyle,
                    content: $viewModel.backupPasswordContent
                )

                VStack {
                    PCButton(
                        style: .constant(.init(mode: .solid)),
                        content: .constant(.init(
                            title: LUITranslation.continue_core_button.l10n,
                            isAnimating: viewModel.viewState == .loading,
                            action: viewModel.primaryActionButtonTapped
                        ))
                    )
                    
                    PCButton(
                        style: .constant(.init(mode: .text)),
                        content: .constant(.init(
                            title: LUITranslation.ask_administrator_for_help.l10n,
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
        .onAppear {
            viewModel.backupPasswordContent.focus()
        }
        .background(
            ColorProvider.BackgroundNorm
                .edgesIgnoringSafeArea(.all)
        )
        .bannerDisplayable(bannerState: $viewModel.bannerState,
                           configuration: .init(position: .bottom))
    }
}

#if DEBUG
import ProtonCoreLogin

#Preview {
    NavigationView {
        EnterBackupPasswordView(viewModel: .init(dependencies: .init(
            userData: .init(
                credential: .none,
                user: .mock,
                salts: [],
                passphrases: [:],
                addresses: [],
                scopes: []
            ),
            apiService: nil,
            unprivatizationInfo: .init(state: .ready, adminEmail: "", orgKeyFingerprintSignature: .init(value: ""), orgPublicKey: .init(value: "")),
            ssoNavigationDelegate: nil
        )))
    }
}
#endif

#endif
