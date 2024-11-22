//
//  Spacing.swift
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

import Foundation

public extension ThemeProvider {

    struct Spacing: Sendable {
        public let tiny: CGFloat = 2
        public let small: CGFloat = 4
        public let compact: CGFloat = 6
        public let standard: CGFloat = 8
        public let medium: CGFloat = 12
        public let moderatelyLarge: CGFloat = 14
        public let large: CGFloat = 16
        public let extraLarge: CGFloat = 24
        public let huge: CGFloat = 32
        public let jumbo: CGFloat = 40
    }
}
