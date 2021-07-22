//
//  UIGestureRecognizer+helper.swift
//  ProtonMail - Created on 20.11.20.
//
//  Copyright (c) 2020 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

extension UIColor {
     public static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
         if #available(iOS 13.0, *) {
             return UIColor(dynamicProvider: {
                 switch $0.userInterfaceStyle {
                 case .dark:
                     return dark
                 case .light, .unspecified:
                     return light
                 @unknown default:
                     assertionFailure("Unknown userInterfaceStyle: \($0.userInterfaceStyle)")
                     return light
                 }
             })
         }
         // iOS 12 and earlier
         return light
     }
}
