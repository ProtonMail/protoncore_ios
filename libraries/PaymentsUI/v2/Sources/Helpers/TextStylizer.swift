//
//  TextStylizer.swift
//  ProtonCore-PaymentsUIV2 - Created on 6/1/2025.
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
// swiftlint:disable:next large_tuple
public typealias TextStyle = (text: String,
                              font: AttributeScopes.SwiftUIAttributes.FontAttribute.Value,
                              color: Color)

public struct TextStylizer {

    public static func composeText(texts: [TextStyle]) -> AttributedString {

        var composedText = AttributedString("")

        for (index, text) in texts.enumerated() {
            var styledText = AttributedString(text.text)
            styledText.font = text.font
            styledText.foregroundColor = text.color
            composedText += index > 0 ? " " + styledText : styledText
        }

        return composedText
    }
}
