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
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import SwiftUI

@MainActor
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
                .foregroundColor(style.titleFontColor())
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                if content.isSecureEntry && !content.isSecureEntryDisplayed {
                    SecureField(content.placeholder, text: $content.text)
                        .padding(.vertical)
                        .accentColor(Theme.color.brandNorm)
                        .keyboardType(content.keyboardType)
                        .autocapitalization(autocapitalization)
                        .textContentType(content.textContentType)
                } else {
                    TextField(content.placeholder, text: $content.text)
                        .padding(.vertical)
                        .accentColor(Theme.color.brandNorm)
                        .keyboardType(content.keyboardType)
                        .autocapitalization(autocapitalization)
                        .textContentType(content.textContentType)
                }
                if content.isSecureEntry {
                    secureEntryDisplayButton
                } else if content.showClearButton
                            && !content.text.isEmpty {
                    clearFieldButton
                }
            }
            .focused(currentFocus: $content.currentFocus, focusID: content.focusID)
            .padding(.horizontal)
            .background(Theme.color.backgroundSecondary)
            .cornerRadius(Theme.radius.medium)
            .onTapGesture { content.focus() }
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius.medium)
                    .stroke(style.textFieldBorderColor(isFocused: content.isFocused), lineWidth: 1)
            )

            if !content.footnote.isEmpty {
                Text(content.footnote)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(style.footnoteFontColor())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var secureEntryDisplayButton: some View {
        Button(action: {
            let inputWasFocused = content.isFocused
            content.isSecureEntryDisplayed.toggle()
            if inputWasFocused {
                withAnimation { content.focus() }
            }
        }, label: {
            Image(uiImage: content.isSecureEntryDisplayed ? Theme.icon.eyeSlash : Theme.icon.eye)
                .foregroundColor(Theme.color.iconHint)
        })
    }

    private var clearFieldButton: some View {
        Button(action: { content.text = "" }, label: {
            Image(uiImage: Theme.icon.crossCircleFilled)
                .foregroundColor(Theme.color.iconHint)
        })
    }

    private var autocapitalization: UITextAutocapitalizationType {
        content.isSecureEntry ? .none : content.autocapitalization
    }
}

private struct TextFieldFocused: ViewModifier {

    @FocusState private var focusState: String?

    @Binding private var currentFocus: String?
    private var focusID: String

    init(currentFocus: Binding<String?>, focusID: String) {
        self._currentFocus = currentFocus
        self.focusID = focusID
    }

    func body(content: Content) -> some View {
        content
            .focused($focusState, equals: focusID)
            .onChange(of: focusState, perform: { _ in
                currentFocus = focusState
            })
            .onChange(of: currentFocus, perform: { _ in
                focusState = currentFocus
            })
    }
}

extension View {
    @ViewBuilder
    func focused(currentFocus: Binding<String?>, focusID: String) -> some View {
        self.modifier(TextFieldFocused(currentFocus: currentFocus, focusID: focusID))
    }
}
#endif
