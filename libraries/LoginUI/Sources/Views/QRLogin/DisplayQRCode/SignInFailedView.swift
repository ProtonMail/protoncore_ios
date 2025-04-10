//
//  Created on 01.04.2025.
//
//  Copyright (c) 2025 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import SwiftUI
import ProtonCoreUIFoundations
import ProtonCoreObservability

@MainActor
struct SignInFailedView: View {

    enum Constants {
        static let noSpacing: CGFloat = .zero
        static let topEdgePadding: CGFloat = 32
        static let buttonsVerticalSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 48
        static let buttonTopPadding: CGFloat = 24
        static let buttonBottomPadding: CGFloat = 20
        static let leadingTrailingPadding: CGFloat = 16
        static let iconHeight: CGFloat = 80
        static let sectionPadding: CGFloat = 24
    }

    var handleTryAgainPress: () -> Void
    var handleBackPress: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            icon
            title
            description
            Spacer()
            buttons
        }
        .onAppear {
            ObservabilityEnv.report(.qrLoginShowQRCodeScreenState(stateId: .loginFailedGeneric))
        }
    }

    var icon: some View {
        Image(uiImage: IconProvider.accountWarning)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.iconHeight, height: Constants.iconHeight)
            .padding(.top, Constants.topEdgePadding)
    }

    var title: some View {
        Text(LUITranslation.something_went_wrong_title.l10n)
            .font(.title2)
            .foregroundStyle(ColorProvider.TextNorm)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.leadingTrailingPadding)
            .padding(.top, Constants.sectionPadding)
    }

    var description: some View {
        Text(LUITranslation.sign_in_error_description.l10n)
            .font(.body)
            .foregroundStyle(ColorProvider.TextWeak)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.leadingTrailingPadding)
            .padding(.top, Constants.sectionPadding)
    }

    var buttons: some View {
        VStack(alignment: .center, spacing: Constants.buttonsVerticalSpacing) {
            qrCodebutton
            backButton
        }
    }

    var qrCodebutton: some View {
        PCButton(style: .constant(.init(mode: .solid)), content: .constant(.init(title: LUITranslation.new_qr_code_title.l10n, action: {
            handleTryAgainPress()
        })))
        .frame(height: Constants.buttonHeight)
        .padding(.horizontal, Constants.leadingTrailingPadding)
        .padding(.top, Constants.buttonTopPadding)
    }

    var backButton: some View {
        Button {
            handleBackPress()
        } label: {
            Text(LUITranslation.back_to_signin_button.l10n)
                .foregroundStyle(ColorProvider.TextAccent)
        }
        .frame(height: Constants.buttonHeight)
        .padding(.horizontal, Constants.leadingTrailingPadding)
        .padding(.bottom, Constants.buttonBottomPadding)
    }
}

#endif
