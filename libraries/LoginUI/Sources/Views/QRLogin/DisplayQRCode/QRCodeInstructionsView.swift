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
        static let tinySpacing: CGFloat = 4
        static let lineSpacing: CGFloat = 0.25
        static let textWidth: CGFloat = 16
    }

    var qrCodeText: String?

    var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            qrCode
            instructions
            Spacer()
        }
        .navigationTitle(LUITranslation.signin_qr_code_button.l10n)
    }

    var qrCode: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .background(Color.white)
                .frame(width: Constants.qrBgSize, height: Constants.qrBgSize)
                .cornerRadius(Constants.cornerRadius)
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
                .modifier(TextViewModifier(lineSpacing: Constants.lineSpacing))
            numberedList
        }
        .padding(.top, Constants.sectionPadding)
        .padding(.horizontal, Constants.leadingTrailingPadding)
    }

    var numberedList: some View {
        VStack(alignment: .leading, spacing: Constants.tinySpacing) {
            numberedTextItem(number: 1, text: AttributedString.markdown(LUITranslation.open_proton_app_on_phone.l10n))
            numberedTextItem(number: 2, text: AttributedString.markdown(LUITranslation.tap_into_settings_instructions.l10n))
            numberedTextItem(number: 3, text: AttributedString.markdown(LUITranslation.tap_scan_qr_code.l10n))
        }
        .padding(.top, Constants.verticalTextPadding)
    }

    func numberedTextItem(number: Int, text: AttributedString) -> some View {
        HStack(alignment: .top, spacing: Constants.tinySpacing) {
            Text("\(number).")
                // frame(width: textSize) makes sure the text is aligned
                // without it there is like a 2-3 pixel difference in alignment between the first item and the second.
                .frame(width: Constants.textWidth)
                .modifier(TextViewModifier(lineSpacing: Constants.lineSpacing))
            Text(text)
                .modifier(TextViewModifier(lineSpacing: Constants.lineSpacing))
        }
    }

    struct TextViewModifier: ViewModifier {

        var lineSpacing: CGFloat

        func body(content: Content) -> some View {
            content
                .font(.body)
                .lineSpacing(lineSpacing)
                .foregroundStyle(ColorProvider.TextWeak)
        }
    }
}

#endif
