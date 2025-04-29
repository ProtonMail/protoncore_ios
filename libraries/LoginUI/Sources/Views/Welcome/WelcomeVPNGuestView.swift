//  Copyright (c) 2025 Proton AG
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

public struct WelcomeVPNGuestView: View {

    @StateObject var viewModel: ViewModel
    var externalLinks = ExternalLinks(clientApp: .vpn)

    private enum Constants {
        static let standardSpacing: CGFloat = 8
        static let mediumSpacing: CGFloat = 12
        static let largeSpacing: CGFloat = 16
        static let noLogsImageSize: CGFloat = 20
        static let extraLargeSpacing: CGFloat = 24
        static let elementsWidthLimit: CGFloat = 480
    }

    public var body: some View {
        ZStack {
            VStack {
                ZStack {
                    IconProvider.vpnWelcomeImageV2Bg
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(.all)
                    IconProvider.vpnWelcomeImageV2
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: Constants.elementsWidthLimit)
                }
                Spacer()
            }
            VStack(spacing: Constants.extraLargeSpacing) {
                Spacer() // Two Spacers on purpose to center the content on the 2/3 of the screen
                Spacer()
                Link(destination: externalLinks.certifiedNoLogsVPN) {
                    HStack {
                        Image("certified-no-logs", bundle: .module)
                            .resizable()
                            .frame(width: Constants.noLogsImageSize, height: Constants.noLogsImageSize)
                        Text(LUITranslation.login_vpn_guest_certified_no_logs.l10n)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        IconProvider.arrowOutSquare
                            .resizable()
                            .frame(width: Constants.largeSpacing, height: Constants.largeSpacing)
                    }
                    .padding(Constants.standardSpacing)
                    .background(ColorProvider.BackgroundSecondary)
                    .cornerRadius(Constants.mediumSpacing)
                }
                .buttonStyle(.plain)

                VStack(spacing: Constants.standardSpacing) {
                    Text(LUITranslation.login_vpn_guest_screen_title.l10n)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorProvider.TextNorm)
                    Text(LUITranslation.login_vpn_guest_screen_description.l10n)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(ColorProvider.TextWeak)
                }

                actionButtons
                    .frame(maxWidth: Constants.elementsWidthLimit)

                Link(destination: externalLinks.termsAndConditions, label: {
                    (Text(LUITranslation.login_vpn_guest_tc_description.l10n + " ") +
                     Text(LUITranslation.login_vpn_guest_tc_link.l10n)
                        .foregroundColor(ColorProvider.TextAccent)
                    )
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(ColorProvider.TextWeak)
                    .frame(maxWidth: .infinity, alignment: .center)
                })
                Spacer()
            }
            .padding()
        }
        .background(ColorProvider.BackgroundNorm)
        .bannerDisplayable(
            bannerState: $viewModel.bannerState,
            configuration: .init(position: .bottom)
        )
    }

    @ViewBuilder
    var actionButtons: some View {
        VStack {
            switch viewModel.viewMode {
            case .guest:
                PCButton(
                    style: .constant(.init(mode: .solid())),
                    content: .constant(.init(
                        title: LUITranslation.continue_as_guest.l10n,
                        isAnimating: viewModel.viewState == .loading,
                        action: viewModel.continueAsGuestTapped
                    ))
                )
            case .signUp:
                PCButton(
                    style: .constant(.init(mode: .solid())),
                    content: .constant(.init(
                        title: LUITranslation.create_account_button.l10n,
                        action: viewModel.signUpTapped
                    ))
                )
            }

            PCButton(
                style: .constant(.init(mode: .solid(.signInButtonStyle))),
                content: .constant(.init(
                    title: LUITranslation.signin_button.l10n,
                    isEnabled: viewModel.viewState == .idle,
                    action: viewModel.signInTapped
                ))
            )
        }
        .padding(.top, Constants.mediumSpacing)
    }
}

#if DEBUG
#Preview {
    WelcomeVPNGuestView(viewModel: .mock())
}
#endif

extension PCButtonStyle.SolidStyleConfiguration {
    static let signInButtonStyle: PCButtonStyle.SolidStyleConfiguration = {
        .init(
            backgroundColorDisabled: ColorProvider.InteractionWeakDisabled,
            backgroundColorNorm: ColorProvider.InteractionWeak,
            backgroundColorPressed: ColorProvider.InteractionWeakPressed
        )
    }()
}

#endif
