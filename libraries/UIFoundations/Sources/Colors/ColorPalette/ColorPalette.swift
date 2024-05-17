//
//  ColorPalette.swift
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

public protocol ColorPalette<T> {
    associatedtype T
    static var instance: T { get }

    // MARK: MobileBrand
    var BrandNorm: ProtonColor { get }
    var BrandDarken10: ProtonColor { get }
    var BrandDarken20: ProtonColor { get }
    var BrandDarken30: ProtonColor { get }
    var BrandDarken40: ProtonColor { get }
    var BrandLighten10: ProtonColor { get }
    var BrandLighten20: ProtonColor { get }
    var BrandLighten30: ProtonColor { get }
    var BrandLighten40: ProtonColor { get }

    // MARK: Notification
    var NotificationError: ProtonColor { get }
    var NotificationWarning: ProtonColor { get }
    var NotificationSuccess: ProtonColor { get }
    var NotificationNorm: ProtonColor { get }

    // MARK: Interaction norm
    var InteractionNorm: ProtonColor { get }
    var InteractionNormPressed: ProtonColor { get }
    var InteractionNormDisabled: ProtonColor { get }
    var InteractionNormMajor1PassTheme: ProtonColor { get }
    var InteractionNormMajor2PassTheme: ProtonColor { get }

    // MARK: Shade
    var Shade100: ProtonColor { get }
    var Shade80: ProtonColor { get }
    var Shade60: ProtonColor { get }
    var Shade50: ProtonColor { get }
    var Shade40: ProtonColor { get }
    var Shade20: ProtonColor { get }
    var Shade15: ProtonColor { get }
    var Shade10: ProtonColor { get }
    var Shade0: ProtonColor { get }

    // MARK: Text
    var TextNorm: ProtonColor { get }
    var TextWeak: ProtonColor { get }
    var TextHint: ProtonColor { get }
    var TextDisabled: ProtonColor { get }
    var TextInverted: ProtonColor { get }
    var TextAccent: ProtonColor { get }

    // MARK: Icon
    var IconNorm: ProtonColor { get }
    var IconWeak: ProtonColor { get }
    var IconHint: ProtonColor { get }
    var IconDisabled: ProtonColor { get }
    var IconInverted: ProtonColor { get }
    var IconAccent: ProtonColor { get }

    // MARK: Interaction
    var InteractionWeak: ProtonColor { get }
    var InteractionWeakPressed: ProtonColor { get }
    var InteractionWeakDisabled: ProtonColor { get }
    var InteractionStrong: ProtonColor { get }
    var InteractionStrongPressed: ProtonColor { get }

    // MARK: Floaty
    var FloatyBackground: ProtonColor { get }
    var FloatyPressed: ProtonColor { get }
    var FloatyText: ProtonColor { get }

    // MARK: Background
    var BackgroundNorm: ProtonColor { get }
    var BackgroundDeep: ProtonColor { get }
    var BackgroundSecondary: ProtonColor { get }

    // MARK: Separator
    var SeparatorNorm: ProtonColor { get }
    var SeparatorStrong: ProtonColor { get }

    // MARK: Sidebar
    var SidebarBackground: ProtonColor { get }
    var SidebarInteractionWeakNorm: ProtonColor { get }
    var SidebarInteractionWeakPressed: ProtonColor { get }
    var SidebarSeparator: ProtonColor { get }
    var SidebarTextNorm: ProtonColor { get }
    var SidebarTextWeak: ProtonColor { get }
    var SidebarIconNorm: ProtonColor { get }
    var SidebarIconWeak: ProtonColor { get }
    var SidebarInteractionPressed: ProtonColor { get }
    var SidebarInteractionSelected: ProtonColor { get }
    var SidebarInteractionAlternative: ProtonColor { get }

    // MARK: Blenders
    var BlenderNorm: ProtonColor { get }

    // MARK: Accent
    var PurpleBase: ProtonColor { get }
    var EnzianBase: ProtonColor { get }
    var PinkBase: ProtonColor { get }
    var PlumBase: ProtonColor { get }
    var StrawberryBase: ProtonColor { get }
    var CeriseBase: ProtonColor { get }
    var CarrotBase: ProtonColor { get }
    var CopperBase: ProtonColor { get }
    var SaharaBase: ProtonColor { get }
    var SoilBase: ProtonColor { get }
    var SlateblueBase: ProtonColor { get }
    var CobaltBase: ProtonColor { get }
    var PacificBase: ProtonColor { get }
    var OceanBase: ProtonColor { get }
    var ReefBase: ProtonColor { get }
    var PineBase: ProtonColor { get }
    var FernBase: ProtonColor { get }
    var ForestBase: ProtonColor { get }
    var OliveBase: ProtonColor { get }
    var PickleBase: ProtonColor { get }

    // MARK: Two special colors that consistently occur in designs even though they are not part af the palette
    var White: ProtonColor { get }
    var Black: ProtonColor { get }

    // MARK: Special banner colors
    var Ebb: ProtonColor { get }
    var Cloud: ProtonColor { get }
}

public extension ColorPalette {
    // MARK: Accent
    var PurpleBase: ProtonColor { ProtonColor(name: "SharedPurpleBase") }
    var EnzianBase: ProtonColor { ProtonColor(name: "SharedEnzianBase") }
    var PinkBase: ProtonColor { ProtonColor(name: "SharedPinkBase") }
    var PlumBase: ProtonColor { ProtonColor(name: "SharedPlumBase") }
    var StrawberryBase: ProtonColor { ProtonColor(name: "SharedStrawberryBase") }
    var CeriseBase: ProtonColor { ProtonColor(name: "SharedCeriseBase") }
    var CarrotBase: ProtonColor { ProtonColor(name: "SharedCarrotBase") }
    var CopperBase: ProtonColor { ProtonColor(name: "SharedCopperBase") }
    var SaharaBase: ProtonColor { ProtonColor(name: "SharedSaharaBase") }
    var SoilBase: ProtonColor { ProtonColor(name: "SharedSoilBase") }
    var SlateblueBase: ProtonColor { ProtonColor(name: "SharedSlateblueBase") }
    var CobaltBase: ProtonColor { ProtonColor(name: "SharedCobaltBase") }
    var PacificBase: ProtonColor { ProtonColor(name: "SharedPacificBase") }
    var OceanBase: ProtonColor { ProtonColor(name: "SharedOceanBase") }
    var ReefBase: ProtonColor { ProtonColor(name: "SharedReefBase") }
    var PineBase: ProtonColor { ProtonColor(name: "SharedPineBase") }
    var FernBase: ProtonColor { ProtonColor(name: "SharedFernBase") }
    var ForestBase: ProtonColor { ProtonColor(name: "SharedForestBase") }
    var OliveBase: ProtonColor { ProtonColor(name: "SharedOliveBase") }
    var PickleBase: ProtonColor { ProtonColor(name: "SharedPickleBase") }

    // MARK: Two special colors that consistently occur in designs even though they are not part af the palette
    var White: ProtonColor { ProtonColor(name: "White") }
    var Black: ProtonColor { ProtonColor(name: "Black") }

    // MARK: Special banner colors
    var Ebb: ProtonColor { ProtonColor(name: "Ebb") }
    var Cloud: ProtonColor { ProtonColor(name: "Cloud") }
}
