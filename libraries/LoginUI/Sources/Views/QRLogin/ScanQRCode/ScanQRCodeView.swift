//
//  Created on 20.03.2025.
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

private enum Constants {
    static let noSpacing: CGFloat = 0
    static let closeButtonHeight: CGFloat = 24
    static let arrowOutHeight: CGFloat = 24
    static let closeButtonPadding: CGFloat = 10
    static let horizontalPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 16
    static let crosshairTopPadding: CGFloat = 144
    static let crosshairHeight: CGFloat = 280
    static let cutoutHeight: CGFloat = 264
    static let overlayOpacity: CGFloat = 0.52
    static let descriptionTextTopPadding: CGFloat = 45
    static let buttonVerticalPadding: CGFloat = 24
    static let buttonVerticalHeight: CGFloat = 48
    static let loadingIndicatorHeight: CGFloat = 56
    static let successImageHeight: CGFloat = 230
    static let failureImageHeight: CGFloat = 168
    static let topTextTopPadding: CGFloat = 72
    static let cameraIllustrationSize: CGSize = .init(width: 188, height: 148)
    static let cameraIllustrationTopPadding: CGFloat = 80
    static let cameraIllustrationBottomPadding: CGFloat = 24
    static let textPadding: CGFloat = 16
}

@MainActor
struct ScanQRCodeView: View {

    @StateObject var viewModel: ViewModel

    var closeButtonColor: Color {
        switch viewModel.state {
        case .scanning: return Color.white
        default: return ColorProvider.IconNorm
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            switch viewModel.state {
            case .scanning:
                ScanningView(
                    handleQRCodeString: { qrCode in
                        viewModel.handleQRCodeDetected(qrCode)
                    },
                    handleCameraUsePermissionRequestRejection: {
                        viewModel.handleCameraUsePermissionRequestRejection()
                    }, handleCameraUseNotAllowed: {
                        viewModel.handleCameraUseNotAllowed()
                    })
            case .verifying:
                VerifyingView()
            case .success:
                SuccessView(email: viewModel.email) {
                    viewModel.handleGotItButtonPressed()
                }
            case .failure:
                FailureView {
                    withAnimation {
                        viewModel.handleScanQRCodePressed()
                    }
                }
            case .cameraNotAllowed:
                CameraNotAllowedView(clientName: viewModel.clientName) {
                    viewModel.handleGoToSettingsPressed()
                }
            }
            closeButton
        }
        .background(
            NavigationControllerAccessor(callback: { nav in
                viewModel.navigationController = nav
            })
        )
        .navigationBarHidden(true)
    }

    var closeButton: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            closeButtonTopLeft
            Spacer()
        }
    }

    var closeButtonTopLeft: some View {
        HStack(alignment: .center, spacing: Constants.noSpacing) {
            Button(action: {
                viewModel.handleCloseButtonPressed()
            }) {
                Image(uiImage: IconProvider.cross)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.closeButtonHeight, height: Constants.closeButtonHeight)
                    .foregroundStyle(closeButtonColor)
                    .padding(Constants.closeButtonPadding)
            }
            .contentShape(Rectangle())
            Spacer()
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.top, Constants.closeButtonHeight / 2)
    }
}

@MainActor
private struct ScanningView: View {

    var handleQRCodeString: (String) -> Void
    var handleCameraUsePermissionRequestRejection: () -> Void
    var handleCameraUseNotAllowed: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            camera
            maskWithCutout
            crossHairs
            scanQRCodeText
        }
        .onAppear {
            ObservabilityEnv.report(.qrLoginScanQRCodeScreenState(stateId: .camera))
        }
    }

    var camera: some View {
        QRCodeCameraView(handleQRCodeString: handleQRCodeString,
                         handleCameraUsePermissionRequestRejection: handleCameraUsePermissionRequestRejection,
                         handleCameraUseNotAllowed: handleCameraUseNotAllowed)
        .edgesIgnoringSafeArea(.all)
    }

    var maskWithCutout: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.black.opacity(Constants.overlayOpacity))
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .frame(width: Constants.cutoutHeight, height: Constants.cutoutHeight)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .blendMode(.destinationOut)
                .padding(.top, Constants.crosshairTopPadding + ((Constants.crosshairHeight - Constants.cutoutHeight) / 2))
        }
        .compositingGroup()
    }

    var crossHairs: some View {
        Image(uiImage: IconProvider.crossHair)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.crosshairHeight, height: Constants.crosshairHeight)
            .padding(.top, Constants.crosshairTopPadding)
    }

    var scanQRCodeText: some View {
        Text(LUITranslation.scan_qr_code_placing_instructions.l10n)
            .font(.title3)
            .foregroundStyle(Color.white)
            .multilineTextAlignment(.center)
            .padding(.top, Constants.crosshairTopPadding + Constants.crosshairHeight + Constants.descriptionTextTopPadding)
    }
}

@MainActor
private struct VerifyingView: View {
    var body: some View {
        ZStack(alignment: .top) {
            SharedBackgroundView(text: LUITranslation.verifying.l10n)
            loadingIndicator
        }
        .onAppear {
            ObservabilityEnv.report(.qrLoginScanQRCodeScreenState(stateId: .verifying))
        }
    }

    var loadingIndicator: some View {
        ProtonLoaderView(size: Constants.loadingIndicatorHeight)
            .frame(width: Constants.loadingIndicatorHeight, height: Constants.loadingIndicatorHeight)
            .padding(.top, Constants.crosshairTopPadding + (Constants.crosshairHeight / 2) - (Constants.loadingIndicatorHeight / 2))
    }
}

@MainActor
private struct SuccessView: View {
    var email: String
    var buttonPressAction: () -> Void

    var body: some View {
        SharedImageTextAndButtonView(
            topText: LUITranslation.access_shared.l10n,
            subtitle: email,
            image: IconProvider.accessShared,
            imageHeight: Constants.successImageHeight,
            showCrossHair: false,
            buttonTitle: LUITranslation.back_to_settings.l10n,
            buttonPressAction: buttonPressAction)
        .onAppear {
            ObservabilityEnv.report(.qrLoginScanQRCodeScreenState(stateId: .success))
        }
    }
}

@MainActor
private struct FailureView: View {
    var buttonPressAction: () -> Void

    var body: some View {
        SharedImageTextAndButtonView(
            topText: LUITranslation.code_not_recognized.l10n,
            image: IconProvider.scanQRCodeWarning,
            imageHeight: Constants.failureImageHeight,
            infoText: AttributedString.markdown(LUITranslation.scan_qr_code_tip.l10n),
            buttonTitle: LUITranslation.scan_qr_code_title.l10n,
            buttonPressAction: buttonPressAction)
        .onAppear {
            ObservabilityEnv.report(.qrLoginScanQRCodeScreenState(stateId: .failure))
        }
    }
}

@MainActor
private struct CameraNotAllowedView: View {

    var clientName: String?
    var buttonPressAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            icon
            title
            description
            Spacer()
            disclaimer
            button
        }
        .onAppear {
            ObservabilityEnv.report(.qrLoginScanQRCodeScreenState(stateId: .cameraAccessNotAllowed))
        }
    }

    var icon: some View {
        Image(uiImage: IconProvider.cameraIllustration)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.cameraIllustrationSize.width, height: Constants.cameraIllustrationSize.height)
            .padding(.top, Constants.cameraIllustrationTopPadding)
            .padding(.bottom, Constants.cameraIllustrationBottomPadding)
    }

    var title: some View {
        Text(LUITranslation.allow_access_camera_title.l10n)
            .font(.title2)
            .foregroundStyle(ColorProvider.TextNorm)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.textPadding)
    }

    var description: some View {
        Text(descriptionString)
            .font(.body)
            .foregroundStyle(ColorProvider.TextNorm)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.textPadding)
    }

    var disclaimer: some View {
        Text(LUITranslation.allow_access_camera_disclaimer.l10n)
            .font(.footnote)
            .foregroundStyle(ColorProvider.TextWeak)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.horizontalPadding)
    }

    var button: some View {
        ZStack(alignment: .center) {
            PCButton(style: .constant(.init(mode: .solid())), content: .constant(.init(title: LUITranslation.settings_title.l10n, action: {
                buttonPressAction()
            })))

            HStack(alignment: .center, spacing: Constants.noSpacing) {
                Spacer()
                Image(uiImage: IconProvider.arrowOutSquare)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.arrowOutHeight, height: Constants.arrowOutHeight, alignment: .trailing)
                    .padding(.horizontal, Constants.horizontalPadding)
            }
        }
        .frame(height: Constants.buttonVerticalHeight)
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.buttonVerticalPadding)
    }

    private var descriptionString: String {
        return String.localizedStringWithFormat(
            LUITranslation.allow_access_camera_description.l10n,
            clientName?.capitalized ?? ""
        )
    }
}

@MainActor struct SharedImageTextAndButtonView: View {
    var topText: String
    var subtitle: String?
    var image: UIImage
    var imageHeight: CGFloat
    var showCrossHair: Bool = true
    var infoText: AttributedString?
    var buttonTitle: String
    var buttonPressAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            SharedBackgroundView(text: topText, subtitle: subtitle, showCrossHair: showCrossHair)
            checkMarkImage
            if let info = infoText {
                description(text: info)
            }
            button
        }
    }

    var checkMarkImage: some View {
        Image(uiImage: image)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: imageHeight, height: imageHeight)
            .padding(.top, Constants.crosshairTopPadding + (Constants.crosshairHeight / 2) - (imageHeight / 2))
    }

    func description(text: AttributedString) -> some View {
        Text(text)
            .modifier(TextModifier())
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.crosshairTopPadding + Constants.crosshairHeight + Constants.descriptionTextTopPadding)
    }

    var button: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            Spacer()
            PCButton(style: .constant(.init(mode: .solid())),
                     content: .constant(.init(title: buttonTitle, action: buttonPressAction)))
            .frame(height: Constants.buttonVerticalHeight)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.buttonVerticalPadding)
        }
    }

    struct TextModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(ColorProvider.TextWeak)
        }
    }
}

@MainActor
private struct SharedBackgroundView: View {

    var text: String
    var subtitle: String?
    var showCrossHair = true

    var body: some View {
        ZStack(alignment: .top) {
            if showCrossHair {
                crossHairOutline
            }
            topText
        }
    }

    var crossHairOutline: some View {
        Image(uiImage: IconProvider.crossHairOutline)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(ColorProvider.IconNorm)
            .frame(width: Constants.crosshairHeight, height: Constants.crosshairHeight)
            .padding(.top, Constants.crosshairTopPadding)
    }

    var topText: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            Text(text)
                .font(.title2)
                .foregroundStyle(ColorProvider.TextNorm)
                .padding(.top, Constants.topTextTopPadding)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(ColorProvider.TextWeak)
                    .padding(.top, Constants.textPadding / 2)
            }
        }
    }
}

#endif
