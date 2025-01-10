//
//  AttributedString+Extensions.swift
//  ProtonCore-LoginUI - Created on 13/01/2025.
//
//  Copyright (c) 2025 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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

extension AttributedString {
    func withBoldText(text: String) -> AttributedString {
        var newAttributedString = self
        if let range = newAttributedString.range(of: text) {
            newAttributedString[range].font = Font.subheadline.weight(.bold)
        }
        return newAttributedString
    }
}
