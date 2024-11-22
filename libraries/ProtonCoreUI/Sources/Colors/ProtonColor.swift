//
//  ProtonColor.swift
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

public struct ProtonColor: Sendable {
    let name: String
    let darkName: String?
    let bundle: Bundle

    public init(
        name: String,
        darkName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.name = name
        self.darkName = darkName
        self.bundle = bundle ?? .module
    }
}

#if canImport(UIKit)
import UIKit

extension ProtonColor {
    var uiColor: UIColor {
        if let darkName {
            return UIColor { (traits) -> UIColor in
                traits.userInterfaceStyle == .dark ?
                color(name: darkName) : color(name: name)
            }
        }
        return color(name: name)
    }

    private func color(name: String) -> UIColor {
        UIColor(named: name, in: bundle, compatibleWith: nil)!
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI

extension ProtonColor {

    var color: Color {
        #if canImport(UIKit)
        Color(uiColor: uiColor)
        #else
        Color(name, bundle: bundle)
        #endif
    }

}
#endif
