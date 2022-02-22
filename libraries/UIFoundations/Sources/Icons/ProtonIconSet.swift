//
//  ProtonIconSet.swift
//  ProtonCore-UIFoundations - Created on 08.02.22.
//
//  Copyright (c) 2022 Proton Technologies AG
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

public struct ProtonIconSet {
    static let instance = ProtonIconSet()

    private init() {}
    
    // Icons

    public let arrowLeft = ProtonIcon(name: "ic-arrow-left")
    
    public let arrowOutFromRectangle = ProtonIcon(name: "ic-Arrow-out-from-rectangle")
    
    public let arrowRight = ProtonIcon(name: "ic-arrow-right")
    
    public let arrowsRotate = ProtonIcon(name: "ic-Arrows-rotate")
    
    public let checkmarkCircle = ProtonIcon(name: "ic-Checkmark-circle")
    
    public let checkmark = ProtonIcon(name: "ic-Checkmark")
    
    public let chevronDown = ProtonIcon(name: "ic-chevron-down")
    
    public let crossCircleFilled = ProtonIcon(name: "ic-Cross-circle-filled")
    
    public let cogWheel = ProtonIcon(name: "ic-cog-wheel")
    
    public let crossSmall = ProtonIcon(name: "ic-Cross_small")
    
    public let envelope = ProtonIcon(name: "ic-envelope")
    
    public let eyeSlash = ProtonIcon(name: "ic-eye-slash")
    
    public let eye = ProtonIcon(name: "ic-eye")
    
    public let fileArrowIn = ProtonIcon(name: "ic-File-arrow-in")
    
    public let info = ProtonIcon(name: "ic-info")
    
    public let key = ProtonIcon(name: "ic-key")
    
    public let lightbulb = ProtonIcon(name: "ic-lightbulb")
    
    public let plus = ProtonIcon(name: "ic-plus")
    
    public let minus = ProtonIcon(name: "ic-minus")
    
    public let minusCircle = ProtonIcon(name: "ic-minus-circle")
    
    public let mobile = ProtonIcon(name: "ic-mobile")
    
    public let questionCircle = ProtonIcon(name: "ic-question-circle")
    
    public let signIn = ProtonIcon(name: "ic-sign-in")
    
    public let speechBubble = ProtonIcon(name: "ic-Speech-bubble")
    
    public let threeDotsHorizontal = ProtonIcon(name: "ic-three-dots-horizontal")
    
    public let userCircle = ProtonIcon(name: "ic-user-circle")
    
    // Apple-specific icons
    
    public let faceId = ProtonIcon(name: "ic-face-id")
    
    public let touchId = ProtonIcon(name: "ic-touch-id")
    
    // Flags
    
    public func flag(forCountryCode countryCode: String) -> ProtonIcon {
        ProtonIcon(name: "flags-\(countryCode)")
    }
    
    // Logos
    
    public let calendarMain = ProtonIcon(name: "CalendarMain")
    
    public let driveMain = ProtonIcon(name: "DriveMain")
    
    public let mailMain = ProtonIcon(name: "MailMain")
    
    public let vpnMain = ProtonIcon(name: "VPNMain")
    
    public let logoProton = ProtonIcon(name: "logo-proton")
    
    public let logoProtonCalendar = ProtonIcon(name: "logo-ProtonCalendar")
    
    public let logoProtonDrive = ProtonIcon(name: "logo-ProtonDrive")
    
    public let logoProtonMail = ProtonIcon(name: "logo-ProtonMail")
    
    public let logoProtonVPN = ProtonIcon(name: "logo-ProtonVPN")
    
    // Login-specific
    
    public let loginSummaryBottom = ProtonIcon(name: "summary_bottom")
    
    public let loginSummaryProton = ProtonIcon(name: "summary_proton")
    
    public let loginSummaryVPN = ProtonIcon(name: "summary_vpn")
    
    public let loginWelcomeCalendarLogo = ProtonIcon(name: "WelcomeCalendarLogo")
    
    public let loginWelcomeCalendarSmallLogo = ProtonIcon(name: "WelcomeCalendarSmallLogo")
    
    public let loginWelcomeDriveLogo = ProtonIcon(name: "WelcomeDriveLogo")
    
    public let loginWelcomeDriveSmallLogo = ProtonIcon(name: "WelcomeDriveSmallLogo")
    
    public let loginWelcomeMailLogo = ProtonIcon(name: "WelcomeMailLogo")
    
    public let loginWelcomeMailSmallLogo = ProtonIcon(name: "WelcomeMailSmallLogo")
    
    public let loginWelcomeVPNLogo = ProtonIcon(name: "WelcomeVPNLogo")
    
    public let loginWelcomeVPNSmallLogo = ProtonIcon(name: "WelcomeVPNSmallLogo")
    
    public let loginWelcomeTopImageForProton = ProtonIcon(name: "WelcomeTopImageForProton")
    
    public let loginWelcomeTopImageForVPN = ProtonIcon(name: "WelcomeTopImageForVPN")
    
}
