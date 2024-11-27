//
//  ProtonLoaderView.swift
//  ProtonCore-LoginUI - Created on 10/16/2024.
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
import ProtonCoreUIFoundations
import SwiftUI

public struct ProtonLoaderView: View {
    @State private var degree: Int = 270
    @State private var spinnerLength = 0.6
    let size: CGFloat

    public init(size: CGFloat = 40) {
        self.size = size
    }

    enum Constants {
        static let lineWidth = 2.0
        static let lengthAnimationDuration = 1.5
        static let rotationAnimationDuration = 1.0
    }

    public var body: some View {
        Circle()
            .trim(from: 0.0, to: spinnerLength)
            .stroke(ColorProvider.BrandNorm, style: StrokeStyle(lineWidth: Constants.lineWidth, lineCap: .square, lineJoin: .round))
            .animation(.easeIn(duration: Constants.lengthAnimationDuration).repeatForever(autoreverses: true), value: spinnerLength)
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: Double(degree)))
            .animation(.linear(duration: Constants.rotationAnimationDuration).repeatForever(autoreverses: false), value: degree)
            .onAppear {
                degree = 270 + 360
                spinnerLength = 0
            }
    }
}

#if DEBUG
#Preview {
    ProtonLoaderView()
}
#endif

#endif
