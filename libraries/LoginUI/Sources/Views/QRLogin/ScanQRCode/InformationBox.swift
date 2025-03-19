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

import SwiftUI
import ProtonCoreUIFoundations

struct InformationBox: View {
    var text: AttributedString

    private enum Constants {
        static let imageHeight: CGFloat = 16
        static let lineSpacing: CGFloat = 0.25
        static let horizontalSpacing: CGFloat = 8
        static let padding: CGFloat = 12
        static let cornerRadius: CGFloat = 8
    }

    var body: some View {
        HStack(alignment: .top, spacing: Constants.horizontalSpacing) {
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
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorProvider.BackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}


