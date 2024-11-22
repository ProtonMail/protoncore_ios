//
//  IconProvider.swift
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

import Foundation

public struct ProtonIcon: Sendable {
    let name: String
}

@dynamicMemberLookup
public struct IconProvider: Sendable {}

#if canImport(UIKit)
import UIKit

extension IconProvider {

    public subscript(dynamicMember keypath: KeyPath<ProtonIconSet, ProtonIcon>) -> UIImage {
        guard let image = ProtonIconSet.instance[keyPath: keypath].uiImage else {
            assertionFailure("lack of image in assets catalogue indicates the images misconfiguration")
            return UIImage()
        }
        return image
    }

    public func flag(forCountryCode countryCode: String) -> UIImage? {
        ProtonIconSet.instance.flag(forCountryCode: countryCode).uiImage
    }
}

extension ProtonIcon {
    var uiImage: UIImage? {
        image(name: name)
    }

    private func image(name: String) -> UIImage? {
        UIImage(named: name, in: Bundle.module, compatibleWith: nil)
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI

extension IconProvider {

    public subscript(dynamicMember keypath: KeyPath<ProtonIconSet, ProtonIcon>) -> Image {
        ProtonIconSet.instance[keyPath: keypath].image
    }
}

extension ProtonIcon {
    var image: Image { Image(name, bundle: Bundle.module) }
}
#endif
