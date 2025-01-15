//
//  FooterView.swift
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

struct FooterView: View {

    let image: Image
    let text: String

    private struct Constants {
        static let horizontalSpacing: CGFloat = Theme.spacing.standard
        static let iconSize: CGSize = CGSize(width: 16, height: 16)
    }

    var body: some View {
        HStack(spacing: Constants.horizontalSpacing) {
            image
                .resizable()
                .frame(width: Constants.iconSize.width, height: Constants.iconSize.height)
                .foregroundColor(Theme.color.shade80)
            Text(text)
                .font(.caption)
                .foregroundColor(Theme.color.shade80)
            Spacer()
        }
    }
}

#Preview {
    FooterView(image: Theme.icon.infoCircle,
               text: String(localized: "Plans_footer_disclaimer", bundle: .module))
}
