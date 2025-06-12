//
//  Created on 19.03.2025.
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

struct InformationBox: View {
    var title: AttributedString
    var tips: [AttributedString]

    private enum Constants {
        static let imageHeight: CGFloat = 16
        static let lineSpacing: CGFloat = 0.25
        static let horizontalSpacing: CGFloat = 8
        static let padding: CGFloat = 12
        static let cornerRadius: CGFloat = 8
        static let noSpacing: CGFloat = .zero
        static let verticalSpacing: CGFloat = 8
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.noSpacing) {
            header(text: title)
                .padding(.bottom, Constants.verticalSpacing / 2)
            ForEach(tips, id: \.self) { text in
                tip(text: text)
                    .padding(.top, Constants.verticalSpacing)
            }
        }
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorProvider.BackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }

    func header(text: AttributedString) -> some View {
        HStack(alignment: .center, spacing: Constants.horizontalSpacing) {
            Image(uiImage: IconProvider.lightbulb)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: Constants.imageHeight, height: Constants.imageHeight)
                .foregroundStyle(ColorProvider.IconWeak)
            Text(text)
                .font(.footnote)
                .lineSpacing(Constants.lineSpacing)
                .foregroundStyle(ColorProvider.TextWeak)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    func tip(text: AttributedString) -> some View {
        Text(text)
            .font(.footnote)
            .lineSpacing(Constants.lineSpacing)
            .foregroundStyle(ColorProvider.TextWeak)
    }
}

#endif
