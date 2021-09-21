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

import UIKit

@available(iOS 11.0, *)
extension UIColorManager {
    
    // MARK: Global
    public static var White = color("GlobalWhite")

    // MARK: Brand
    public static var BrandDarken40: UIColor {
        switch brand {
        case .proton: return color("BrandDarken40")
        case .vpn: return color("BrandDarken40Vpn")
        }
    }
    public static var BrandDarken20: UIColor {
        switch brand {
        case .proton: return color("BrandDarken20")
        case .vpn: return color("BrandDarken20Vpn")
        }
    }
    public static var BrandNorm: UIColor {
        switch brand {
        case .proton: return color("BrandNorm")
        case .vpn: return color("BrandNormVpn")
        }
    }
    public static var BrandLighten20: UIColor {
        switch brand {
        case .proton: return color("BrandLighten20")
        case .vpn: return color("BrandLighten20Vpn")
        }
    }
    public static var BrandLighten40: UIColor {
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
    public static var InteractionNorm: UIColor {
        switch brand {
        case .proton: return color("InteractionNorm")
        case .vpn: return color("InteractionNormVpn")
        }
    }
    public static var InteractionNormPressed: UIColor {
        switch brand {
        case .proton: return color("InteractionNormPressed")
        case .vpn: return color("InteractionNormPressedVpn")
        }
    }
    public static var InteractionNormDisabled: UIColor {
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
    public static var TextInverted = color("TextInverted")

    // MARK: Icon
    public static let IconNorm = color("IconNorm")
    public static let IconWeak = color("IconWeak")
    public static let IconHint = color("IconHint")
    public static let IconDisabled = color("IconDisabled")
    public static let IconInverted = color("IconInverted")

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

@available(iOS 11.0, *)
fileprivate extension UIColorManager {

    // MARK: Private methods
    static func color(_ name: String) -> UIColor {
        return UIColor(named: name, in: PMUIFoundations.bundle, compatibleWith: nil)!
    }
}

@available(iOS 11.0, *)
extension UIColorManager {
    
    // TODO: Colors to remove
    
    // MARK: Splash
    public enum Splash {
        public static var Background: UIColor {
            switch brand {
            case .proton:
                return UIColor(named: "SplashBackgroundColorForProton", in: PMUIFoundations.bundle, compatibleWith: nil)!
            case .vpn:
                return UIColor(named: "SplashBackgroundColorForVPN", in: PMUIFoundations.bundle, compatibleWith: nil)!
            }
        }

        static var TextNormForProtonBrand: UIColor {
            UIColor(named: "SplashTextNormForProton", in: PMUIFoundations.bundle, compatibleWith: nil)!
        }

        static var TextNormForVPNBrand: UIColor {
            UIColor(named: "SplashTextNormForVPN", in: PMUIFoundations.bundle, compatibleWith: nil)!
        }

        public static var TextNorm: UIColor {
            switch brand {
            case .proton: return TextNormForProtonBrand
            case .vpn: return TextNormForVPNBrand
            }
        }

        public static var TextHintForProtonBrand: UIColor {
            UIColor(named: "SplashTextHintForProton", in: PMUIFoundations.bundle, compatibleWith: nil)!
        }

        static var TextHintForVPNBrand: UIColor {
            UIColor(named: "SplashTextHintForVPN", in: PMUIFoundations.bundle, compatibleWith: nil)!
        }

        public static var TextHint: UIColor {
            switch brand {
            case .proton: return TextHintForProtonBrand
            case .vpn: return TextHintForVPNBrand
            }
        }
    }

    // MARK: Close
    public static let CloseColor = UIColor(named: "CloseButtonColour", in: PMUIFoundations.bundle, compatibleWith: nil)!
}
