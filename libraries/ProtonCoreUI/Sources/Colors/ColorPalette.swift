//
//  ColorPalette.swift
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

public struct ProtonColorPalette: ColorPalette {}

public protocol ColorPalette: Sendable {

    // MARK: MobileBrand
    var brandNorm: ProtonColor { get }
    var brandDarken10: ProtonColor { get }
    var brandDarken20: ProtonColor { get }
    var brandDarken30: ProtonColor { get }
    var brandLighten10: ProtonColor { get }
    var brandLighten20: ProtonColor { get }
    var brandLighten30: ProtonColor { get }

    // MARK: Shade
    var shade100: ProtonColor { get }
    var shade80: ProtonColor { get }
    var shade60: ProtonColor { get }
    var shade50: ProtonColor { get }
    var shade40: ProtonColor { get }
    var shade20: ProtonColor { get }
    var shade0: ProtonColor { get }

    // MARK: Notification
    var notificationError: ProtonColor { get }
    var notificationWarning: ProtonColor { get }
    var notificationSuccess: ProtonColor { get }
    var notificationNorm: ProtonColor { get }

    // MARK: Interaction norm
    var interactionNorm: ProtonColor { get }
    var interactionNormPressed: ProtonColor { get }
    var interactionNormDisabled: ProtonColor { get }

    // MARK: Text
    var textNorm: ProtonColor { get }
    var textWeak: ProtonColor { get }
    var textHint: ProtonColor { get }
    var textDisabled: ProtonColor { get }
    var textInverted: ProtonColor { get }
    var textAccent: ProtonColor { get }

    // MARK: Icon
    var iconNorm: ProtonColor { get }
    var iconWeak: ProtonColor { get }
    var iconHint: ProtonColor { get }
    var iconDisabled: ProtonColor { get }
    var iconInverted: ProtonColor { get }
    var iconAccent: ProtonColor { get }

    // MARK: Interaction
    var interactionWeak: ProtonColor { get }
    var interactionWeakPressed: ProtonColor { get }
    var interactionWeakDisabled: ProtonColor { get }
    var interactionStrong: ProtonColor { get }
    var interactionStrongPressed: ProtonColor { get }

    // MARK: Background
    var backgroundNorm: ProtonColor { get }
    var backgroundDeep: ProtonColor { get }
    var backgroundSecondary: ProtonColor { get }

    // MARK: Separator
    var separatorNorm: ProtonColor { get }
    var separatorStrong: ProtonColor { get }

    // MARK: Sidebar
    var sidebarBackground: ProtonColor { get }
    var sidebarInteractionWeakNorm: ProtonColor { get }
    var sidebarInteractionWeakPressed: ProtonColor { get }
    var sidebarSeparator: ProtonColor { get }
    var sidebarTextNorm: ProtonColor { get }
    var sidebarTextWeak: ProtonColor { get }
    var sidebarIconNorm: ProtonColor { get }
    var sidebarIconWeak: ProtonColor { get }
    var sidebarInteractionPressed: ProtonColor { get }
    var sidebarInteractionSelected: ProtonColor { get }
    var sidebarInteractionAlternative: ProtonColor { get }

    // MARK: Accent
    var purpleBase: ProtonColor { get }
    var enzianBase: ProtonColor { get }
    var pinkBase: ProtonColor { get }
    var plumBase: ProtonColor { get }
    var strawberryBase: ProtonColor { get }
    var ceriseBase: ProtonColor { get }
    var carrotBase: ProtonColor { get }
    var copperBase: ProtonColor { get }
    var saharaBase: ProtonColor { get }
    var soilBase: ProtonColor { get }
    var slateblueBase: ProtonColor { get }
    var cobaltBase: ProtonColor { get }
    var pacificBase: ProtonColor { get }
    var oceanBase: ProtonColor { get }
    var reefBase: ProtonColor { get }
    var pineBase: ProtonColor { get }
    var fernBase: ProtonColor { get }
    var forestBase: ProtonColor { get }
    var oliveBase: ProtonColor { get }
    var pickleBase: ProtonColor { get }

    // MARK: Two special colors that consistently occur in designs even though they are not part af the palette
    var white: ProtonColor { get }
    var black: ProtonColor { get }

    // MARK: Special banner colors
    var ebb: ProtonColor { get }
    var cloud: ProtonColor { get }
}

public extension ColorPalette {
    // MARK: Default colors

    // MARK: MobileBrand
    var brandNorm: ProtonColor { ProtonColor(name: "CornflowerBlue", darkName: "LightSlateBlue") }
    var brandDarken10: ProtonColor { ProtonColor(name: "PurpleHeart", darkName: "BlueBell") }
    var brandDarken20: ProtonColor { ProtonColor(name: "SanMarino", darkName: "Periwinkle") }
    var brandDarken30: ProtonColor { ProtonColor(name: "Chambray", darkName: "PaleBlue") }
    var brandLighten10: ProtonColor { ProtonColor(name: "Portage", darkName: "CornflowerBlue") }
    var brandLighten20: ProtonColor { ProtonColor(name: "WhisperLila", darkName: "DarkBlue") }
    var brandLighten30: ProtonColor { ProtonColor(name: "BlueChalk", darkName: "DarkSapphireBlue") }

    // MARK: Shade
    var shade100: ProtonColor { ProtonColor(name: "Charade", darkName: "Platinum") }
    var shade80: ProtonColor { ProtonColor(name: "Trout", darkName: "CoolGray") }
    var shade60: ProtonColor { ProtonColor(name: "OsloGray", darkName: "SonicSilver") }
    var shade50: ProtonColor { ProtonColor(name: "Manatee", darkName: "CadetGray") }
    var shade40: ProtonColor { ProtonColor(name: "Ghost", darkName: "Gunmetal") }
    var shade20: ProtonColor { ProtonColor(name: "AthensGray", darkName: "MidnightBlue") }
    var shade10: ProtonColor { ProtonColor(name: "Porcelain", darkName: "Swamp") }
    var shade0: ProtonColor { ProtonColor(name: "White", darkName: "EerieBlack") }

    // MARK: Text
    var textNorm: ProtonColor { shade100 }
    var textWeak: ProtonColor { shade80 }
    var textHint: ProtonColor { shade50 }
    var textDisabled: ProtonColor { shade40 }
    var textInverted: ProtonColor { shade0 }
    var textAccent: ProtonColor { brandNorm }

    // MARK: Icon
    var iconNorm: ProtonColor { shade100 }
    var iconWeak: ProtonColor { shade80 }
    var iconHint: ProtonColor { shade50 }
    var iconDisabled: ProtonColor { shade40 }
    var iconInverted: ProtonColor { shade0 }
    var iconAccent: ProtonColor { brandNorm }

    // MARK: Notification
    var notificationError: ProtonColor { ProtonColor(name: "Amaranth", darkName: "FlamingoPink") }
    var notificationWarning: ProtonColor { ProtonColor(name: "Orange", darkName: "AtomicTangerine") }
    var notificationSuccess: ProtonColor { ProtonColor(name: "Gossamer", darkName: "Turquoise") }
    var notificationNorm: ProtonColor { shade100 }

    // MARK: Interaction norm
    var interactionNorm: ProtonColor { brandNorm }
    var interactionNormPressed: ProtonColor { brandDarken10 }
    var interactionNormDisabled: ProtonColor { brandLighten30 }

    // MARK: Interaction
    var interactionStrong: ProtonColor { brandDarken10 }
    var interactionStrongPressed: ProtonColor { brandDarken20 }
    var interactionWeak: ProtonColor { shade10 }
    var interactionWeakPressed: ProtonColor { shade20 }
    var interactionWeakDisabled: ProtonColor { shade10 }

    // MARK: Background
    var backgroundNorm: ProtonColor { shade0 }
    var backgroundSecondary: ProtonColor { shade10 }
    var backgroundDeep: ProtonColor { shade20 }

    // MARK: Separator
    var separatorNorm: ProtonColor { shade10 }
    var separatorStrong: ProtonColor { shade20 }

    // MARK: Sidebar
    var sidebarBackground: ProtonColor { ProtonColor(name: "DeepCove") }
    var sidebarTextNorm: ProtonColor { ProtonColor(name: "CadetBlue") }
    var sidebarTextWeak: ProtonColor { ProtonColor(name: "MulledWine") }
    var sidebarIconNorm: ProtonColor { ProtonColor(name: "Topaz") }
    var sidebarIconWeak: ProtonColor { ProtonColor(name: "MulledWine") }

    var sidebarInteractionWeakNorm: ProtonColor { ProtonColor(name: "Jacarta") }
    var sidebarInteractionWeakPressed: ProtonColor { ProtonColor(name: "Valhalla") }
    var sidebarInteractionPressed: ProtonColor { ProtonColor(name: "PortGore") }
    var sidebarInteractionSelected: ProtonColor { ProtonColor(name: "CornflowerBlue") }
    var sidebarInteractionAlternative: ProtonColor { ProtonColor(name: "TexasRose") }

    var sidebarSeparator: ProtonColor { ProtonColor(name: "PortGore") }
}

public extension ColorPalette {
    // MARK: Accent
    var purpleBase: ProtonColor { ProtonColor(name: "SharedPurpleBase") }
    var enzianBase: ProtonColor { ProtonColor(name: "SharedEnzianBase") }
    var pinkBase: ProtonColor { ProtonColor(name: "SharedPinkBase") }
    var plumBase: ProtonColor { ProtonColor(name: "SharedPlumBase") }
    var strawberryBase: ProtonColor { ProtonColor(name: "SharedStrawberryBase") }
    var ceriseBase: ProtonColor { ProtonColor(name: "SharedCeriseBase") }
    var carrotBase: ProtonColor { ProtonColor(name: "SharedCarrotBase") }
    var copperBase: ProtonColor { ProtonColor(name: "SharedCopperBase") }
    var saharaBase: ProtonColor { ProtonColor(name: "SharedSaharaBase") }
    var soilBase: ProtonColor { ProtonColor(name: "SharedSoilBase") }
    var slateblueBase: ProtonColor { ProtonColor(name: "SharedSlateblueBase") }
    var cobaltBase: ProtonColor { ProtonColor(name: "SharedCobaltBase") }
    var pacificBase: ProtonColor { ProtonColor(name: "SharedPacificBase") }
    var oceanBase: ProtonColor { ProtonColor(name: "SharedOceanBase") }
    var reefBase: ProtonColor { ProtonColor(name: "SharedReefBase") }
    var pineBase: ProtonColor { ProtonColor(name: "SharedPineBase") }
    var fernBase: ProtonColor { ProtonColor(name: "SharedFernBase") }
    var forestBase: ProtonColor { ProtonColor(name: "SharedForestBase") }
    var oliveBase: ProtonColor { ProtonColor(name: "SharedOliveBase") }
    var pickleBase: ProtonColor { ProtonColor(name: "SharedPickleBase") }

    // MARK: Two special colors that consistently occur in designs even though they are not part af the palette
    var white: ProtonColor { ProtonColor(name: "White") }
    var black: ProtonColor { ProtonColor(name: "Black") }

    // MARK: Special banner colors
    var ebb: ProtonColor { ProtonColor(name: "Ebb") }
    var cloud: ProtonColor { ProtonColor(name: "Cloud") }
}

extension ColorPalette where Self == ProtonColorPalette {
    static var proton: ProtonColorPalette {
        ProtonColorPalette()
    }
}
