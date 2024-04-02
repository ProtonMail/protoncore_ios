//
//  PCTextField.swift
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

public struct PCTextField: View {
    @Binding public var style: PCTextFieldStyle
    @Binding public var content: PCTextFieldContent

    public init(style: Binding<PCTextFieldStyle>, content: Binding<PCTextFieldContent>) {
        self._style = style
        self._content = content
    }

    public var body: some View {
        VStack(spacing: 6) {
            Text(content.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(titleFontColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                if content.isSecureEntry && !content.isSecureEntryDisplayed {
                    SecureField(content.placeholder, text: $content.text)
                        .padding(.vertical)
                } else {
                    TextField(content.placeholder, text: $content.text)
                        .padding(.vertical)
                }
                if content.isSecureEntry {
                    secureEntryDisplayButton
                }
            }
            .padding(.horizontal)
            .background(ColorProvider.BackgroundSecondary)
            .cornerRadius(8.0)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(textFieldBorderColor, lineWidth: 1)
            )

            if !content.footnote.isEmpty {
                Text(content.footnote)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(footnoteFontColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @MainActor
    private var titleFontColor: Color {
        switch style.mode {
        case .idle: return ColorProvider.TextNorm
        case .error: return ColorProvider.NotificationError
        }
    }

    @MainActor
    private var textFieldBorderColor: Color {
        switch style.mode {
        case .idle: return ColorProvider.BackgroundSecondary
        case .error: return ColorProvider.NotificationError
        }
    }

    @MainActor
    private var footnoteFontColor: Color {
        switch style.mode {
        case .idle: return ColorProvider.TextWeak
        case .error: return ColorProvider.NotificationError
        }
    }

    @MainActor
    private var secureEntryDisplayButton: some View {
        Button(action: { content.isSecureEntryDisplayed.toggle() }, label: {
            Image(uiImage: content.isSecureEntryDisplayed ? IconProvider.eyeSlash : IconProvider.eye)
                .foregroundColor(ColorProvider.IconHint)
        })
    }
}
#endif
