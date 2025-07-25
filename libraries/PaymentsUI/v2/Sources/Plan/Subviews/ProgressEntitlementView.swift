//
//  ProgressEntitlementView.swift
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

struct ProgressEntitlementView: View {

    let currentValue: Int
    let maxValue: Int
    let text: String
    let title: String

    @State private var isShown: Bool = false

    private var currentProgress: Double {
        Double(currentValue) / Double(maxValue)
    }

    private struct Constants {
        static let progressLineHeight: CGFloat = 4
        static let progressAnimationDuration: TimeInterval = 1.0

        static func progressColor(maxValue: Int, currentValue: Int) -> Color {
            let progress = Double(currentValue) / Double(maxValue)
            if progress < 0.5 {
                return Theme.color.iconAccent
            } else if progress >= 0.5 && progress < 0.9 {
                return Theme.color.notificationWarning
            } else {
                return Theme.color.notificationError
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(text)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.color.interactionWeak)
                        .frame(height: Constants.progressLineHeight)
                    Capsule()
                        .fill(Constants.progressColor(maxValue: maxValue, currentValue: currentValue))
                        .frame(width: isShown ? proxy.size.width * currentProgress : 0, height: Constants.progressLineHeight)
                        .animation(.easeInOut(duration: Constants.progressAnimationDuration), value: isShown)
                }
            }
            .frame(height: 0)
        }
        .onAppear {
            Task {
                await animate(duration: Constants.progressAnimationDuration) {
                    isShown = true
                }
            }
        }
    }
}
