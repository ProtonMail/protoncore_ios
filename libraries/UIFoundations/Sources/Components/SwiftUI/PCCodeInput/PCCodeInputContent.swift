//
//  PCCodeInputContent.swift
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

import SwiftUI

@MainActor
public struct PCCodeInputContent {
    public var title: String
    public var code: String = ""
    public var isFocused: Bool = false
    public var codeLength: Int
    public var autocapitalization: TextInputAutocapitalization

    public init(
        title: String,
        length: Int = 4,
        autocapitalization: TextInputAutocapitalization = .characters
    ) {
        self.title = title
        self.codeLength = length
        self.autocapitalization = autocapitalization
    }

    public mutating func focus() {
        self.isFocused = true
    }
}

#endif
