//
//  PCButtonStyle.swift
//  ProtonCore-UIFoundations - Created on 27.03.2024.
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

#if os(iOS)

import SwiftUI

@MainActor
public struct PCButtonStyle {
    public var brand: Brand
    public var mode: ButtonMode
    public enum ButtonMode {
        case solid(SolidStyleConfiguration = .default)
        case text
    }

    public init(
        brand: Brand = .currentBrand,
        mode: ButtonMode
    ) {
        self.brand = brand
        self.mode = mode
    }
}

extension PCButtonStyle {
    public struct SolidStyleConfiguration {
        let backgroundColorDisabled: Color
        let backgroundColorNorm: Color
        let backgroundColorPressed: Color

        public init(
            backgroundColorDisabled: Color,
            backgroundColorNorm: Color,
            backgroundColorPressed: Color
        ) {
            self.backgroundColorDisabled = backgroundColorDisabled
            self.backgroundColorNorm = backgroundColorNorm
            self.backgroundColorPressed = backgroundColorPressed
        }

        public static let `default`: SolidStyleConfiguration = {
            let brands = [Brand.proton, Brand.vpn, Brand.wallet]
            return .init(
                backgroundColorDisabled: ColorProvider.InteractionNormDisabled,
                backgroundColorNorm: brands.contains(Brand.currentBrand) ? ColorProvider.InteractionNorm : ColorProvider.InteractionNormMajor1PassTheme,
                backgroundColorPressed: ColorProvider.InteractionNormPressed
            )
        }()
    }
}

#endif
