//
//  ThemeConfiguration.swift
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

/// `ThemeConfiguration` is a struct that defines the configuration used in `Theme`.
public struct ThemeConfiguration: Sendable {

    /// The color palette used in the theme configuration.
    let palette: any ColorPalette

    /// The welcome screen configuration used in the theme configuration.
    let welcomeScreenConfiguration: WelcomeScreenConfiguration

    /// This configuration includes the header background image, the wordmark logo, and a description.
    public struct WelcomeScreenConfiguration: Sendable {

        /// The background image for the header on the welcome screen.
        public let headerBackground: Image

        /// The wordmark logo for the welcome screen.
        public let wordmarkLogo: Image

        /// The description text for the welcome screen.
        public let description: String
    }

    /// Returns the default `ThemeConfiguration`.
    ///
    /// - Returns: A default `ThemeConfiguration` instance with predefined values.
    static var `default`: ThemeConfiguration {
        let iconProvider = IconProvider()
        return .init(
            palette: .proton,
            welcomeScreenConfiguration: .init(
                headerBackground: iconProvider.mailTopImage,
                wordmarkLogo: iconProvider.mailWordmarkNoBackground,
                description: "Privacy. Security. Convenience. Encrypted email that gives you full control of your personal data."
            )
        )
    }
}
