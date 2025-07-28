//
//  IconButton.swift
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
import ProtonCoreUIFoundations

struct IconButton: View {

    private struct Constants {
        static let buttonLabelPadding: CGFloat = 10
        static let buttonBorderWidth: CGFloat = 2
        static let mediumSpacing: CGFloat = 12
    }

    let action: () -> Void
    let title: String
    let icon: Image

    var body: some View {
        Button(action: {
            action()
        }, label: {

            Label {
                Text(title)
            } icon: {
                icon
            }
            .padding(.all, Constants.buttonLabelPadding)
            .foregroundColor(ColorProvider.IconAccent)
            .background(
                RoundedRectangle(
                    cornerRadius: Constants.mediumSpacing,
                    style: .continuous
                )
                .stroke(ColorProvider.IconAccent, lineWidth: Constants.buttonBorderWidth))
        })
    }
}
