//
//  ProgressSpinner.swift
//  ProtonCoreUI - Created on 7/11/2024.
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

struct ProgressSpinner: View {

    private struct Constants {
        static var degree: Int = 270 + 360
        static var spinnerLength = 0.6
        static var lineWidth: CGFloat = 2

        static var strokeAnimationDuration: Double = 1.5
        static var rotationAnimationDuration: Double = 1

        static var spinnerSize: CGSize = CGSize(width: 20, height: 20)
    }

    @State public var animationValue: Bool

    var body: some View {
        Circle()
            .trim(from: 0.0, to: Constants.spinnerLength)
            .stroke(LinearGradient(colors: [.clear, Theme.color.iconAccent],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: Constants.lineWidth,
                                       lineCap: .round,
                                       lineJoin: .round))
            .animation(.easeIn(duration: Constants.strokeAnimationDuration).repeatForever(autoreverses: true), value: animationValue)
            .frame(width: Constants.spinnerSize.width, height: Constants.spinnerSize.height)
            .rotationEffect(Angle(degrees: Double(Constants.degree)))
            .animation(.linear(duration: Constants.rotationAnimationDuration).repeatForever(autoreverses: false), value: animationValue)
            .onAppear{
                Constants.spinnerLength = 0 // initial value for the stroke animation

            }
    }
}

#Preview {
    ProgressSpinner(animationValue: true)
}
