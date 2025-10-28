//
//  PlanDetailHeaderView.swift
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

struct PlanDetailHeaderView: View {

    @Binding var isExpanded: Bool

    let title: String
    let description: String
    let formattedPrice: String
    let formattedPeriod: String
    let showChevron: Bool
    let decorationsURLs: [AssetDownloader]?
    let isCurrentPlan: Bool

    private struct Constants {

        static let buttonTopPadding: CGFloat = 10
        static let chevronSize: CGFloat = 20
        static let imageTouchArea: CGFloat = 5

        static let priceTextFont: Font = .headline
        static let periodTextFont: Font = .caption

        static func imageRotationAngle(isExpanded: Bool) -> Double {
            return isExpanded ? 180 : 0
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            HeaderTitleView(title: title,
                            description: description,
                            decorationsDownloaders: decorationsURLs,
                            showChevron: showChevron)
            Spacer()
            VStack(alignment: .trailing) {
                if !isCurrentPlan {
                    Text(formattedPrice)
                        .font(Constants.priceTextFont)
                    Text(formattedPeriod)
                        .font(Constants.periodTextFont)
                }
                if showChevron {
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                            .padding(Constants.imageTouchArea)
                            .rotationEffect(.degrees(Constants.imageRotationAngle(isExpanded: isExpanded)))
                    }
                    .foregroundColor(ColorProvider.IconAccent)
                    .padding(.top, Constants.buttonTopPadding)}
            }
        }
    }
}
