//
//  PCTextField.swift
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
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>..

#if os(iOS)

import SwiftUI

@MainActor
public struct PCTextFieldStyle {
    public var mode: TextFieldMode
    public enum TextFieldMode {
        case idle
        case error
    }

    public init(mode: TextFieldMode) {
        self.mode = mode
    }
}

extension PCTextFieldStyle {
    func titleFontColor() -> Color {
        switch mode {
        case .idle: return Theme.color.textNorm
        case .error: return Theme.color.notificationError
        }
    }

    func textFieldBorderColor(isFocused: Bool) -> Color {
        switch mode {
        case .idle where isFocused: return Theme.color.brandNorm
        case .error: return Theme.color.notificationError
        default: return Theme.color.backgroundSecondary
        }
    }

    func footnoteFontColor() -> Color {
        switch mode {
        case .idle: return Theme.color.textWeak
        case .error: return Theme.color.notificationError
        }
    }
}
#endif
