//
//  ThemeProvider.swift
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

/// `Theme` is a class that manages the theming configuration for your application.
/// It holds the current theme configuration and provides methods to update it.
///
/// Example uses:
/// - `Theme.configure(.init(...))` to configure your app's `Theme`
/// - `Theme.Color.BackgroundNorm` to access Colors
/// - `Theme.Spacing.medium` to access Spacing
// swiftlint:disable:next identifier_name
public let Theme = ThemeProvider()
public struct ThemeProvider: Sendable {

    /// The current theme configuration.
    /// This property is internally mutable and is updated via the `configure(configuration:)` method.
    private var configuration: ThemeConfiguration

    /// Updates the current theme configuration with a new configuration.
    ///
    /// - Parameter configuration: The new `ThemeConfiguration` to apply.
    public mutating func configure(configuration: ThemeConfiguration) {
        self.configuration = configuration
        self.color = ColorProvider(palette: configuration.palette)
        self.welcomeScreen = configuration.welcomeScreenConfiguration
    }

    /// The color provider used in the current theme configuration.
    /// Provides access to the color palette defined in the current theme.
    public private(set) var color: ColorProvider

    /// The icon provider used in the current theme configuration.
    /// Provides access to the icons.
    public private(set) var icon: IconProvider

    /// The welcome screen configuration extracted from the current theme.
    /// Provides access to the welcome screen specific configuration.
    public private(set) var welcomeScreen: ThemeConfiguration.WelcomeScreenConfiguration

    /// Shorthand for Spacing values shared between all of the apps
    public let spacing: Spacing = .init()

    /// Shorthand for Radius values shared between all of the apps
    public let radius: Radius = .init()

    init(configuration: ThemeConfiguration = .default) {
        self.configuration = configuration
        self.color = ColorProvider(palette: configuration.palette)
        self.icon = IconProvider()
        self.welcomeScreen = configuration.welcomeScreenConfiguration
    }
}
