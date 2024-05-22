//
//  WalletColorPaletteiOS.swift
//  ProtonCore-UIFoundations - Created on 21.05.24.
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

public struct WalletColorPaletteiOS: ColorPaletteiOS {

    public typealias T = WalletColorPaletteiOS

    public static let instance = WalletColorPaletteiOS()

    private init() {}

    // MARK: MobileBrand
    public var BrandNorm: ProtonColor {
        ProtonColor(name: "DreamyBlue")
    }
    public var BrandDarken10: ProtonColor {
        ProtonColor(name: "MoodyBlue")
    }
    public var BrandDarken20: ProtonColor {
        ProtonColor(name: "Victoria")
    }
    public var BrandDarken30: ProtonColor {
        ProtonColor(name: "Meteorite")
    }
    public var BrandLighten10: ProtonColor {
        ProtonColor(name: "LavenderMist")
    }
    public var BrandLighten20: ProtonColor {
        ProtonColor(name: "WhisperLila")
    }
    public var BrandLighten30: ProtonColor {
        ProtonColor(name: "TitanWhite")
    }

    // MARK: Notification
    public var NotificationError: ProtonColor {
        ProtonColor(name: "Bittersweet")
    }
    public var NotificationWarning: ProtonColor {
        ProtonColor(name: "TreePoppy")
    }
    public var NotificationSuccess: ProtonColor {
        ProtonColor(name: "MountainMeadow")
    }
    public var NotificationNorm: ProtonColor {
        BrandNorm
    }

    // MARK: Interaction norm
    public var InteractionNorm: ProtonColor {
        BrandNorm
    }
    public var InteractionNormPressed: ProtonColor {
        BrandDarken10
    }
    public var InteractionNormDisabled: ProtonColor {
        BrandLighten30
    }

    // MARK: Interaction Strong
    public var InteractionStrong: ProtonColor {
        ProtonColor(name: "Mirage")
    }
    public var InteractionStrongPressed: ProtonColor {
        ProtonColor(name: "Trout")
    }

    // MARK: Interaction Weak
    public var InteractionWeak: ProtonColor {
        White
    }
    public var InteractionWeakPressed: ProtonColor {
        ProtonColor(name: "Mercury")
    }
    public var InteractionWeakDisabled: ProtonColor {
        ProtonColor(name: "FrostWhisper")
    }

    // MARK: Shade
    public var Shade100: ProtonColor {
        ProtonColor(name: "Mirage")
    }
    public var Shade80: ProtonColor {
        ProtonColor(name: "Trout")
    }
    public var Shade60: ProtonColor {
        ProtonColor(name: "MistySilver")
    }
    public var Shade50: ProtonColor {
        ProtonColor(name: "Mischka")
    }
    public var Shade40: ProtonColor {
        ProtonColor(name: "Mercury")
    }
    public var Shade20: ProtonColor {
        ProtonColor(name: "FrostWhisper")
    }
    public var Shade10: ProtonColor {
        ProtonColor(name: "CloudVeil")
    }
    public var Shade0: ProtonColor {
        White
    }

    // MARK: Text
    public var TextNorm: ProtonColor {
        ProtonColor(name: "Mirage")
    }
    public var TextWeak: ProtonColor {
        ProtonColor(name: "Trout")
    }
    public var TextHint: ProtonColor {
        ProtonColor(name: "MistySilver")
    }
    public var TextDisabled: ProtonColor {
        ProtonColor(name: "Mischka")
    }
    public var TextInverted: ProtonColor {
        White
    }
    public var TextAccent: ProtonColor {
        BrandNorm
    }

    // MARK: Icon
    public var IconNorm: ProtonColor {
        ProtonColor(name: "Mirage")
    }
    public var IconWeak: ProtonColor {
        ProtonColor(name: "Trout")
    }
    public var IconHint: ProtonColor {
        ProtonColor(name: "MistySilver")
    }
    public var IconDisabled: ProtonColor {
        ProtonColor(name: "Mischka")
    }
    public var IconInverted: ProtonColor {
        White
    }
    public var IconAccent: ProtonColor {
        BrandNorm
    }

    // MARK: Background
    public var BackgroundNorm: ProtonColor {
        ProtonColor(name: "CloudVeil")
    }
    public var BackgroundDeep: ProtonColor {
        ProtonColor(name: "FrostWhisper")
    }
    public var BackgroundSecondary: ProtonColor {
        White
    }

    // MARK: Separator
    public var SeparatorNorm: ProtonColor {
        ProtonColor(name: "FrostWhisper")
    }

    public var SeparatorStrong: ProtonColor {
        ProtonColor(name: "Mercury")
    }

    // MARK: Sidebar
    public var SidebarBackground: ProtonColor {
        ProtonColor(name: "MidnightPulse")
    }
    public var SidebarInteractionWeakPressed: ProtonColor {
        ProtonColor(name: "PortGore")
    }
    public var SidebarInteractionSelected: ProtonColor {
        ProtonColor(name: "DreamyBlue")
    }
    public var SidebarInteractionAlternative: ProtonColor {
        ProtonColor(name: "TexasRose")
    }
    public var SidebarTextNorm: ProtonColor {
        ProtonColor(name: "CadetBlue")
    }
    public var SidebarTextWeak: ProtonColor {
        ProtonColor(name: "MulledWine")
    }
    public var SidebarIconNorm: ProtonColor {
        ProtonColor(name: "Topaz")
    }
    public var SidebarIconWeak: ProtonColor {
        ProtonColor(name: "Trout")
    }
    public var SidebarInteractionPressed: ProtonColor {
        ProtonColor(name: "PortGore")
    }
}
