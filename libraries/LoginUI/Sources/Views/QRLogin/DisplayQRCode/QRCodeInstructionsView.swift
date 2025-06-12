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

struct QRCodeInstructionsView: View {

    private enum Constants {
        static let loaderSize: CGFloat = 33
        static let qrBgSize: CGFloat = 264
        static let qrCodeSize: CGFloat = 244
        static let cornerRadius: CGFloat = 16
        static let verticalTextPadding: CGFloat = 24
        static let sectionPadding: CGFloat = 32
        static let leadingTrailingPadding: CGFloat = 16
        static let noSpacing: CGFloat = .zero
        static let tinySpacing: CGFloat = 8
        static let lineSpacing: CGFloat = 0.25
        static let textWidth: CGFloat = 16
        static let borderSize: CGFloat = 1
    }

    var qrCodeText: String?

    var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            qrCode
            instructions
            Spacer()
        }
        .navigationTitle(LUITranslation.signin_qr_code_button.l10n)
        .onAppear {
            ObservabilityEnv.report(.qrLoginShowQRCodeScreenState(stateId: .qrCode))
        }
    }

    var qrCode: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(width: Constants.qrBgSize, height: Constants.qrBgSize)
                .foregroundStyle(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(ColorProvider.SeparatorNorm, lineWidth: Constants.borderSize)
                )

            if let qrCodeText = qrCodeText {
                QRCodeView(text: qrCodeText)
                    .foregroundStyle(Color.black)
                    .frame(width: Constants.qrCodeSize, height: Constants.qrCodeSize)
            } else {
                ProtonLoaderView(size: Constants.loaderSize)
                    .frame(width: Constants.loaderSize, height: Constants.loaderSize)
            }
        }.padding(.top, Constants.sectionPadding)
    }

    var instructions: some View {
        VStack(alignment: .leading, spacing: Constants.noSpacing) {
            Text(LUITranslation.scan_this_code_instructions.l10n)
                .modifier(TextViewModifier(lineSpacing: Constants.lineSpacing, font: .headline))
            numberedList
            learnMore
        }
        .padding(.top, Constants.sectionPadding)
        .padding(.horizontal, Constants.leadingTrailingPadding)
    }

    var numberedList: some View {
        VStack(alignment: .leading, spacing: Constants.tinySpacing) {
            numberedTextItem(number: 1, text: AttributedString.markdown(LUITranslation.open_proton_app_on_phone.l10n))
            numberedTextItem(number: 2, text: AttributedString.markdown(LUITranslation.tap_into_settings_instructions.l10n))
            numberedTextItem(number: 3, text: AttributedString.markdown(LUITranslation.tap_scan_qr_code.l10n))
            numberedTextItem(number: 4, text: AttributedString.markdown(LUITranslation.scan_settings_instructions.l10n))
        }
        .padding(.top, Constants.tinySpacing * 2)
    }

    func numberedTextItem(number: Int, text: AttributedString) -> some View {
        HStack(alignment: .top, spacing: Constants.tinySpacing) {
            Text("\(number).")
                // frame(width: textWidth) makes sure the text is aligned
                // without it there is a 2-3 pixel difference in alignment between the first item and the second.
                .frame(width: Constants.textWidth)
                .modifier(TextViewModifier(lineSpacing: Constants.lineSpacing))
            Text(text)
                .modifier(TextViewModifier(lineSpacing: Constants.lineSpacing))
        }
    }

    var learnMore: some View {
        Text(AttributedString.markdown("**\(LUITranslation.learn_more.l10n)**"))
            .font(.body)
            .lineSpacing(Constants.lineSpacing)
            .foregroundStyle(ColorProvider.TextAccent)
            .padding(.top, Constants.tinySpacing * 2)
            .onTapGesture {
                guard let url = URL(string: "https://proton.me/support/qr-code-sign-in") else {
                    return
                }
                UIApplication.shared.open(url)
            }
    }

    struct TextViewModifier: ViewModifier {

        var lineSpacing: CGFloat
        var font: Font = .body

        func body(content: Content) -> some View {
            content
                .font(font)
                .lineSpacing(lineSpacing)
                .foregroundStyle(ColorProvider.TextWeak)
        }
    }
}

#endif
