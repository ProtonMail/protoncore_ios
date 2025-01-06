//
//  HeaderTitleView.swift
//  ProtonCore-PaymentsUIV2 - Created on 7/11/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
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

import SwiftUI
import ProtonCoreUI

public struct HeaderTitleView: View {

    private struct Constants {
        static var decorationSize: CGFloat = 16

        static var titleTextSize: CGFloat = 17
        static var titleFontWeight: Font.Weight = .semibold

        static var descriptionTextSize: CGFloat = 13
        static var descriptionFontWeight: Font.Weight = .regular
    }

    let title: String
    let description: String
    let decorations: [URL]?
    let showChevron: Bool

    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.standard) {
            HStack {
                Text(title)
                    .font(.system(size: Constants.titleTextSize))
                    .fontWeight(Constants.titleFontWeight)
                if let decorationsUrl = decorations {
                    ForEach(decorationsUrl, id: \.self) { decoration in
                        PCAsyncImage(url: decoration, placeholderImage: nil) { image in
                            image
                                .resizable()
                                .renderingMode(.template)
                                .opacity(showChevron ? 1 : 0)
                        } placeholder: {
                            ProgressView()
                        }
                        .foregroundColor(Theme.color.iconAccent)
                        .frame(width: Constants.decorationSize, height: Constants.decorationSize)
                    }
                }
            }
            Text(description)
                .font(.system(size: Constants.descriptionTextSize))
                .fontWeight(Constants.descriptionFontWeight)
                .foregroundColor(Theme.color.textWeak)
        }
    }
}

// #Preview {
//    HeaderTitleView()
// }
