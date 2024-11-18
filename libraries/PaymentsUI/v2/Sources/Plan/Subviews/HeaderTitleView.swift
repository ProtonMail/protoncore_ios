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
    }

    let title: String
    let description: String
    let decorations: [URL]?
    let showChevron: Bool

    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.standard) {
            HStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                .fontWeight(.semibold)
                if let decorationsUrl = decorations {
                    ForEach(decorationsUrl, id: \.self) { decoration in
                        AsyncImage(url: decoration) { image in
                            image.image?.resizable()
                                .renderingMode(.template)
                                .opacity(showChevron ? 1 : 0)
                        }
                        .foregroundColor(Theme.color.iconAccent)
                        .frame(width: Constants.decorationSize, height: Constants.decorationSize)
                    }
                }
            }
            Text(description)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundColor(Theme.color.textWeak)
        }
    }
}

// #Preview {
//    HeaderTitleView()
// }
