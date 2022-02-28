//
//  ProtonColorPallete.swift
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

public struct ProtonColorPallete {
    static let instance = ProtonColorPallete()
    public static var brand: Brand = .proton

    private init() {}

    // MARK: Brand
    public let BrandDarken40 = ProtonColor(name: "BrandDarken40")
    public let BrandDarken20 = ProtonColor(name: "BrandDarken20")
    public let BrandNorm = ProtonColor(name: "BrandNorm")
    public let BrandLighten20 = ProtonColor(name: "BrandLighten20")
    public let BrandLighten40 = ProtonColor(name: "BrandLighten40")

    // MARK: Notification
    public let NotificationError = ProtonColor(name: "NotificationError")
    public let NotificationWarning = ProtonColor(name: "NotificationWarning")
    public let NotificationSuccess = ProtonColor(name: "NotificationSuccess")
    public var NotificationNorm: ProtonColor {
        ProtonColor(name: "NotificationNorm", vpnFallbackRgb: notificationNormVpn)
    }

    // MARK: Interaction norm
    public let InteractionNorm = ProtonColor(name: "InteractionNorm")
    public let InteractionNormPressed = ProtonColor(name: "InteractionNormPressed")
    public let InteractionNormDisabled = ProtonColor(name: "InteractionNormDisabled")
    
    // MARK: Shade
    public var Shade100: ProtonColor {
        ProtonColor(name: "Shade100", vpnFallbackRgb: shade100Vpn)
    }
    public var Shade80: ProtonColor {
        ProtonColor(name: "Shade80", vpnFallbackRgb: shade80Vpn)
    }
    public var Shade60: ProtonColor {
        ProtonColor(name: "Shade60", vpnFallbackRgb: shade60Vpn)
    }
    public var Shade50: ProtonColor {
        ProtonColor(name: "Shade50", vpnFallbackRgb: shade50Vpn)
    }
    public var Shade40: ProtonColor {
        ProtonColor(name: "Shade40", vpnFallbackRgb: shade40Vpn)
    }
    public var Shade20: ProtonColor {
        ProtonColor(name: "Shade20", vpnFallbackRgb: shade20Vpn)
    }
    public var Shade10: ProtonColor {
        ProtonColor(name: "Shade10", vpnFallbackRgb: shade10Vpn)
    }
    public var Shade0: ProtonColor {
        ProtonColor(name: "Shade0", vpnFallbackRgb: shade0Vpn)
    }

    // MARK: Text
    public var TextNorm: ProtonColor {
        ProtonColor(name: "TextNorm", vpnFallbackRgb: textNormVpn)
    }
    public var TextWeak: ProtonColor {
        ProtonColor(name: "TextWeak", vpnFallbackRgb: textWeakVpn)
    }
    public var TextHint: ProtonColor {
        ProtonColor(name: "TextHint", vpnFallbackRgb: textHintVpn)
    }
    public var TextDisabled: ProtonColor {
        ProtonColor(name: "TextDisabled", vpnFallbackRgb: textDisabledVpn)
    }
    public var TextInverted: ProtonColor {
        ProtonColor(name: "TextInverted", vpnFallbackRgb: textInvertedVpn)
    }

    // MARK: Icon
    public var IconNorm: ProtonColor {
        ProtonColor(name: "IconNorm", vpnFallbackRgb: iconNormVpn)
    }
    public var IconWeak: ProtonColor {
        ProtonColor(name: "IconWeak", vpnFallbackRgb: iconWeakVpn)
    }
    public var IconHint: ProtonColor {
        ProtonColor(name: "IconHint", vpnFallbackRgb: iconHintVpn)
    }
    public var IconDisabled: ProtonColor {
        ProtonColor(name: "IconDisabled", vpnFallbackRgb: iconDisabledVpn)
    }
    public var IconInverted: ProtonColor {
        ProtonColor(name: "IconInverted", vpnFallbackRgb: iconInvertedVpn)
    }
    
    // MARK: Interaction
    public var InteractionWeak: ProtonColor {
        ProtonColor(name: "InteractionWeak", vpnFallbackRgb: interactionWeakVpn)
    }
    public var InteractionWeakPressed: ProtonColor {
        ProtonColor(name: "InteractionWeakPressed", vpnFallbackRgb: interactionWeakPressedVpn)
    }
    public var InteractionWeakDisabled: ProtonColor {
        ProtonColor(name: "InteractionWeakDisabled", vpnFallbackRgb: interactionWeakDisabledVpn)
    }
    public var InteractionStrong: ProtonColor {
        ProtonColor(name: "InteractionStrong", vpnFallbackRgb: interactionStrongVpn)
    }
    public var InteractionStrongPressed: ProtonColor {
        ProtonColor(name: "InteractionStrongPressed", vpnFallbackRgb: interactionStrongPressedVpn)
    }

    // MARK: Floaty
    public let FloatyBackground = ProtonColor(name: "FloatyBackground")
    public let FloatyPressed = ProtonColor(name: "FloatyPressed")
    public let FloatyText = ProtonColor(name: "FloatyText")
    
    // MARK: Background
    public var BackgroundNorm: ProtonColor {
        ProtonColor(name: "BackgroundNorm", vpnFallbackRgb: backgroundNormVpn)
    }
    public var BackgroundSecondary: ProtonColor {
        ProtonColor(name: "BackgroundSecondary", vpnFallbackRgb: backgroundSecondaryVpn)
    }

    // MARK: Separator
    public var SeparatorNorm: ProtonColor {
        ProtonColor(name: "SeparatorNorm", vpnFallbackRgb: separatorNormVpn)
    }

    // MARK: Sidebar
    public var SidebarBackground: ProtonColor {
        ProtonColor(name: "SidebarBackground", vpnFallbackRgb: sidebarBackgroundVpn)
    }
    public var SidebarInteractionWeakNorm: ProtonColor {
        ProtonColor(name: "SidebarInteractionWeakNorm", vpnFallbackRgb: sidebarInteractionWeakNormVpn)
    }
    public var SidebarInteractionWeakPressed: ProtonColor {
        ProtonColor(name: "SidebarInteractionWeakPressed", vpnFallbackRgb: sidebarInteractionWeakPressedVpn)
    }
    public var SidebarSeparator: ProtonColor {
        ProtonColor(name: "SidebarSeparator", vpnFallbackRgb: sidebarSeparatorVpn)
    }
    public var SidebarTextNorm: ProtonColor {
        ProtonColor(name: "SidebarTextNorm", vpnFallbackRgb: sidebarTextNormVpn)
    }
    public var SidebarTextWeak: ProtonColor {
        ProtonColor(name: "SidebarTextWeak", vpnFallbackRgb: sidebarTextWeakVpn)
    }
    public var SidebarIconNorm: ProtonColor {
        ProtonColor(name: "SidebarIconNorm", vpnFallbackRgb: sidebarIconNormVpn)
    }
    public var SidebarIconWeak: ProtonColor {
        ProtonColor(name: "SidebarIconWeak", vpnFallbackRgb: sidebarIconWeakVpn)
    }
    public let SidebarInteractionPressed = ProtonColor(name: "SidebarInteractionPressed")

    // MARK: Blenders
    public let BlenderNorm = ProtonColor(name: "BlenderNorm")
    
    // MARK: Accent
    
    public let PurpleBase = ProtonColor(name: "PurpleBase")
    public let StrawberryBase = ProtonColor(name: "StrawberryBase")
    public let PinkBase = ProtonColor(name: "PinkBase")
    public let SlateblueBase = ProtonColor(name: "SlateblueBase")
    public let PacificBase = ProtonColor(name: "PacificBase")
    public let ReefBase = ProtonColor(name: "ReefBase")
    public let FernBase = ProtonColor(name: "FernBase")
    public let OliveBase = ProtonColor(name: "OliveBase")
    public let SaharaBase = ProtonColor(name: "SaharaBase")
    public let CarrotBase = ProtonColor(name: "CarrotBase")

}

extension ProtonColorPallete {
    private var balticSea: Int { 0x1C1B24 }
    private var bastille: Int { 0x292733 }
    private var steelGray: Int { 0x343140 }
    private var blackcurrant: Int { 0x3B3747 }
    private var gunPowder: Int { 0x4A4658 }
    private var smoky: Int { 0x5B576B }
    private var dolphin: Int { 0x6D697D }
    private var cadetBlue: Int { 0xA7A4B5 }
    private var cinder: Int { 0x0C0C14 }
    private var shipGray: Int { 0x35333D }
    private var doveGray: Int { 0x706D6B }
    private var dawn: Int { 0x999693 }
    private var cottonSeed: Int { 0xC2BFBC }
    private var cloud: Int { 0xD1CFCD }
    private var ebb: Int { 0xEAE7E4 }
    private var cararra: Int { 0xF5F4F2 }
    private var white: Int { 0xFFFFFF }
    
    private var shade100Vpn: Int { white }
    private var shade80Vpn: Int { cadetBlue }
    private var shade60Vpn: Int { dolphin }
    private var shade50Vpn: Int { smoky }
    private var shade40Vpn: Int { gunPowder }
    private var shade20Vpn: Int { blackcurrant }
    private var shade10Vpn: Int { bastille }
    private var shade0Vpn: Int { balticSea }
    private var textNormVpn: Int { shade100Vpn }
    private var textWeakVpn: Int { shade80Vpn }
    private var textHintVpn: Int { shade60Vpn }
    private var textDisabledVpn: Int { shade50Vpn }
    private var textInvertedVpn: Int { shade0Vpn }
    private var iconNormVpn: Int { shade100Vpn }
    private var iconWeakVpn: Int { shade80Vpn }
    private var iconHintVpn: Int { shade60Vpn }
    private var iconDisabledVpn: Int { shade50Vpn }
    private var iconInvertedVpn: Int { shade0Vpn }
    private var interactionWeakVpn: Int { shade20Vpn }
    private var interactionWeakPressedVpn: Int { shade40Vpn }
    private var interactionWeakDisabledVpn: Int { shade10Vpn }
    private var interactionStrongVpn: Int { shade100Vpn }
    private var interactionStrongPressedVpn: Int { shade80Vpn }
    private var backgroundNormVpn: Int { shade0Vpn }
    private var backgroundSecondaryVpn: Int { shade10Vpn }
    private var separatorNormVpn: Int { shade20Vpn }
    private var notificationNormVpn: Int { shade100Vpn }
    private var sidebarBackgroundVpn: Int { balticSea }
    private var sidebarInteractionWeakNormVpn: Int { blackcurrant }
    private var sidebarInteractionWeakPressedVpn: Int { gunPowder }
    private var sidebarSeparatorVpn: Int { blackcurrant }
    private var sidebarTextNormVpn: Int { white }
    private var sidebarTextWeakVpn: Int { cadetBlue }
    private var sidebarIconNormVpn: Int { shade100Vpn }
    private var sidebarIconWeakVpn: Int { cadetBlue }
}

#if canImport(UIKit)

// MARK: Internal core colors

extension ProtonColorPallete {
    
    // MARK: Global
    static var White: UIColor {
        UIColor(rgb: ProtonColorPallete().white)
    }

    // MARK: Splash
    enum Splash {
        static var Background: UIColor {
            switch brand {
            case .proton:
                // LIGHT mode: White, DARK mode: Port Gore
                return UIColor.dynamic(light: ProtonColorPallete.White, dark: UIColor(rgb: ProtonColorPallete().cinder))
            case .vpn:
                // Woodsmoke
                return UIColor(rgb: ProtonColorPallete().balticSea)
            }
        }

        static var TextNorm: UIColor {
            switch brand {
            case .proton:
                // LIGHT mode: Woodsmoke, DARK mode: White
                return UIColor.dynamic(light: UIColor(rgb: ProtonColorPallete().balticSea), dark: ProtonColorPallete.White)
            case .vpn:
                // LIGHT, DARK mode: White
                return ProtonColorPallete.White
            }
        }

        static var TextHint: UIColor {
            switch brand {
            case .proton:
                return ColorProvider.TextHint
            case .vpn:
                // Storm Gray
                return UIColor(rgb: ProtonColorPallete().dolphin)
            }
        }
    }
}
#endif
