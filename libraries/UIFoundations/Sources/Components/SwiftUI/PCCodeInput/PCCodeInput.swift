//
//  PCCodeInput.swift
//  ProtonCore-UIFoundations - Created on 23.01.2025.
//
//  Copyright (c) 2025 Proton Technologies AG
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

import Combine
import SwiftUI

@MainActor
public struct PCCodeInput: View {
    @Binding public var style: PCCodeInputStyle
    @Binding public var content: PCCodeInputContent
    @FocusState var isFocused: Bool

    @State var codeArray: [String]

    private enum Constants {
        static let largeSpacing: CGFloat = 16
        static let extraLargeSpacing: CGFloat = 24
        static let cornerRadius: CGFloat = 8
        static let fieldLimit: Int = 1
        static let minCharacterWidth: CGFloat = 52
        static let minCharacterHeight: CGFloat = 65
    }

    public init(style: Binding<PCCodeInputStyle>, content: Binding<PCCodeInputContent>) {
        self._style = style
        self._content = content

        self._codeArray = State(initialValue: [String](repeating: "", count: content.wrappedValue.codeLength))
    }

    public var body: some View {
        VStack(spacing: Constants.largeSpacing) {
            Text(content.title)
                .foregroundStyle(ColorProvider.TextNorm)
                .font(Font.subheadline)
                .fontWeight(.semibold)
            ZStack {
                HStack {
                    ForEach(codeArray.indices, id: \.self) { idx in
                        characterField(idx: idx)
                    }
                }
                TextField("", text: $content.code)
                    .focused($isFocused)
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(content.autocapitalization)
                    .autocorrectionDisabled()
                    .onReceive(Just(content.code)) { _ in limitText(text: $content.code, limit: content.codeLength) }
                    .opacity(.zero)
            }
        }
        .onChange(of: content.code, perform: { newValue in
            for idx in 0..<codeArray.count {
                if idx < content.code.count {
                    codeArray[idx] = String(content.code[idx])
                }
            }
        })
        .onChange(of: content.isFocused, perform: { newValue in
            isFocused = content.isFocused
        })
        .onChange(of: isFocused, perform: { newValue in
            content.isFocused = isFocused
        })
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, Constants.extraLargeSpacing)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(isFocused ? ColorProvider.BrandNorm : ColorProvider.SeparatorNorm, lineWidth: 1)
        )
    }

    @ViewBuilder
    func characterField(idx: Int) -> some View {
        VStack {
            Text(verbatim: getCharacter(at: idx))
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(minWidth: Constants.minCharacterWidth, minHeight: Constants.minCharacterHeight)
        .background(ColorProvider.BackgroundSecondary)
        .cornerRadius(Constants.cornerRadius)
        .if(displayFocusBorder(idx: idx)) { view in
            view.overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(ColorProvider.BrandNorm, lineWidth: 1)
            )
        }
        .onTapGesture {
            isFocused = true
        }
    }

    private func getCharacter(at idx: Int) -> String {
        guard idx < content.code.count else { return "" }
        return String(content.code[idx])
    }

    private func displayFocusBorder(idx: Int) -> Bool {
        let nextField = idx == max(0, content.code.count)
        let lastCharacterFilled = content.code.count == content.codeLength && idx == content.code.count - 1
        return isFocused
        && ( nextField || lastCharacterFilled )
    }

    func limitText(text: Binding<String>, limit: Int) {
        if text.wrappedValue.count > limit {
            text.wrappedValue = String(text.wrappedValue.prefix(limit))
        }
    }
}

#endif
