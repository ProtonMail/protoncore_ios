//
//  PMColors.swift
//  ProtonCore-UIFoundations - Created on 04.11.20.
//
//  Copyright (c) 2020 Proton Technologies AG
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

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension ColorManager {

    // MARK: Global
    public static var White = color("GlobalWhite")
    
    // MARK: Brand
    public static var BrandDarken40: Color {
        switch brand {
        case .proton: return color("BrandDarken40")
        case .vpn: return color("BrandDarken40Vpn")
        }
    }
    public static var BrandDarken20: Color {
        switch brand {
        case .proton: return color("BrandDarken20")
        case .vpn: return color("BrandDarken20Vpn")
        }
    }
    public static var BrandNorm: Color {
        switch brand {
        case .proton: return color("BrandNorm")
        case .vpn: return color("BrandNormVpn")
        }
    }
    public static var BrandLighten20: Color {
        switch brand {
        case .proton: return color("BrandLighten20")
        case .vpn: return color("BrandLighten20Vpn")
        }
    }
    public static var BrandLighten40: Color {
        switch brand {
        case .proton: return color("BrandLighten40")
        case .vpn: return color("BrandLighten40Vpn")
        }
    }

    // MARK: Notification
    public static let NotificationError = color("NotificationError")
    public static let NotificationWarning = color("NotificationWarning")
    public static let NotificationSuccess = color("NotificationSuccess")

    // MARK: Interaction norm
    public static var InteractionNorm: Color {
        switch brand {
        case .proton: return color("InteractionNorm")
        case .vpn: return color("InteractionNormVpn")
        }
    }
    public static var InteractionNormPressed: Color {
        switch brand {
        case .proton: return color("InteractionNormPressed")
        case .vpn: return color("InteractionNormPressedVpn")
        }
    }
    public static var InteractionNormDisabled: Color {
        switch brand {
        case .proton: return color("InteractionNormDisabled")
        case .vpn: return color("InteractionNormDisabledVpn")
        }
    }

    // MARK: Shade
    public static let Shade100 = color("Shade100")
    public static let Shade80 = color("Shade80")
    public static let Shade60 = color("Shade60")
    public static let Shade50 = color("Shade50")
    public static let Shade40 = color("Shade40")
    public static let Shade20 = color("Shade20")
    public static let Shade10 = color("Shade10")
    public static let Shade0 = color("Shade0")

    // MARK: Text
    public static let TextNorm = color("TextNorm")
    public static let TextWeak = color("TextWeak")
    public static let TextHint = color("TextHint")
    public static let TextDisabled = color("TextDisabled")
    public static let TextInverted = color("TextInverted")
    public static var TextAccent: Color {
        switch brand {
        case .proton: return color("TextAccent")
        case .vpn: return color("TextAccentVpn")
        }
    }

    // MARK: Icon
    public static let IconNorm = color("IconNorm")
    public static let IconWeak = color("IconWeak")
    public static let IconHint = color("IconHint")
    public static let IconDisabled = color("IconDisabled")
    public static let IconInverted = color("IconInverted")
    public static var IconAccent: Color {
        switch brand {
        case .proton: return color("IconAccent")
        case .vpn: return color("IconAccentVpn")
        }
    }

    // MARK: Interaction
    public static let InteractionWeak = color("InteractionWeak")
    public static let InteractionWeakPressed = color("InteractionWeakPressed")
    public static let InteractionWeakDisabled = color("InteractionWeakDisabled")
    public static let InteractionStrong = color("InteractionStrong")
    public static let InteractionStrongPressed = color("InteractionStrongPressed")
    
    // MARK: Floaty
    public static let FloatyBackground = color("FloatyBackground")
    public static let FloatyPressed = color("FloatyPressed")
    public static let FloatyText = color("FloatyText")
    
    // MARK: Background
    public static let BackgroundNorm = color("BackgroundNorm")
    public static let BackgroundSecondary = color("BackgroundSecondary")

    // MARK: Separator
    public static let SeparatorNorm = color("SeparatorNorm")

	// MARK: Blenders
	public static let BlenderNorm = color("BlenderNorm")
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
fileprivate extension ColorManager {

    // MARK: Private methods
    static func color(_ name: String) -> Color {
        return Color(name, bundle: PMUIFoundations.bundle)
    }
}
