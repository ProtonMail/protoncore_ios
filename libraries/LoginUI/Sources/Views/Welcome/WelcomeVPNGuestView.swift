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
        static let artworkHeightLimit: CGFloat = 600
        static let artworkOffset: CGFloat = 72
    }

    public var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                        .overlay {
                            IconProvider.vpnWelcomeImageV2Bg
                                .resizable()
                        }
                        .clipped()
                        .ignoresSafeArea()

                    VStack {
                        Spacer(minLength: 0)
                        IconProvider.vpnWelcomeImageV2
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: Constants.elementsWidthLimit)
                            .offset(y: Constants.artworkOffset)
                    }
                }
                .frame(maxHeight: Constants.artworkHeightLimit) // prevents iPad from oversizing this view

                titleAndButtons
                    .frame(maxWidth: Constants.elementsWidthLimit)
                Spacer(minLength: 0)
            }
            .background {
                ColorProvider.BackgroundNorm
                    .ignoresSafeArea()
            }
        .bannerDisplayable(
            bannerState: $viewModel.bannerState,
            configuration: .init(position: .bottom)
        )
        .bannerDisplayable(
            bannerState: $viewModel.killSwitchBannerState,
            configuration: viewModel.loginScreenBanner?.blockingAlert != nil
                ? .init(position: .top, dismissDuration: nil, isDismissableByUser: false)
                : .init(position: .top)
        )
        .alert(
            viewModel.blockingAlert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.blockingAlert != nil },
                set: { isPresented in if !isPresented { viewModel.blockingAlert = nil } }
            ),
            presenting: viewModel.blockingAlert
        ) { blockingAlert in
            Button(blockingAlert.confirmTitle) { viewModel.turnOffKillSwitchConfirmed() }
            Button(blockingAlert.cancelTitle, role: .cancel) { }
        } message: { blockingAlert in
            Text(blockingAlert.message)
        }
        .onAppear {
            viewModel.measureOnViewDisplayed()
        }
    }

    var titleAndButtons: some View {
        VStack(spacing: Constants.extraLargeSpacing) {
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
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ColorProvider.TextWeak)
            }

            actionButtons

            Text(
                try! AttributedString(
                    markdown: LUITranslation.lion_login_vpn_guest_tc_pp_description(
                        tcLink: externalLinks.termsAndConditions.absoluteString,
                        ppLink: externalLinks.privacyPolicy.absoluteString
                    )
                )
            )
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(ColorProvider.TextWeak)
            .tint(ColorProvider.TextAccent) // link color
            .multilineTextAlignment(.center)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
        }
        .padding()
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
