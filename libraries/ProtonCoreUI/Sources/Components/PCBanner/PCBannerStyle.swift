//
//  PCBannerStyle.swift
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

@MainActor
public struct PCBannerStyle {
    public var style: Style

    public enum Style {
        case success
        case warning
        case error
        case info
    }

    public init(style: Style) {
        self.style = style
    }

    var backgroundColor: Color {
        switch style {
        case .success:
            return Theme.color.notificationSuccess
        case .warning:
            return Theme.color.notificationWarning
        case .error:
            return Theme.color.notificationError
        case .info:
            return Theme.color.notificationNorm
        }
    }

    var iconColor: Color {
        switch style {
        case .success, .warning, .error:
            return Theme.color.white
        case .info:
            return Theme.color.iconInverted
        }
    }

    var buttonBackgroundColor: Color {
        Theme.color.white.opacity(0.2)
    }
}
