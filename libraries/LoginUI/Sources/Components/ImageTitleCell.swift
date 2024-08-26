//
//  ImageTitleCell.swift
//  ProtonCore-Login - Created on 23/08/2024.
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

struct ImageTitleCell: View {
    let image: Image
    let title: String

    private enum Constants {
        static let imageSize: CGFloat = 32
        static let cornerRadius: CGFloat = 8
    }

    var body: some View {
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Constants.imageSize, height: Constants.imageSize)
            Text(verbatim: title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(ColorProvider.TextNorm)
        }
        .padding()
        .background(ColorProvider.BackgroundSecondary)
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(ColorProvider.SeparatorNorm, lineWidth: 1)
        )
    }
}

#if DEBUG
#Preview {
    ImageTitleCell(
        image: Image("LaunchScreenVPNLogo", bundle: PMUIFoundations.bundle),
        title: "admin@privacybydefault.com"
    )
}

#endif

#endif
