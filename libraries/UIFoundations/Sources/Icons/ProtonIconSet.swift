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

    public let arrowLeft = ProtonIcon(name: "ic-arrow-left")
    
    public let arrowRight = ProtonIcon(name: "ic-arrow-right")
    
    @available(*, deprecated, message: "Please use ProtonIconSet.arrowRight and set appropriate tint colors")
    public let arrowRightDisabled = ProtonIcon(name: "ic-arrow-right")
    
    public let check = ProtonIcon(name: "ic-check")
    
    public let chevronDown = ProtonIcon(name: "ic-chevron-down")
    
    public let clearFilled = ProtonIcon(name: "ic-clear-filled")
    
    public let crossClose = ProtonIcon(name: "ic-cross-close")
    
    public let eyeSlash = ProtonIcon(name: "ic-eye-slash")
    
    public let eye = ProtonIcon(name: "ic-eye")
    
    public let minus = ProtonIcon(name: "ic-minus")
    
    public let calendarMain = ProtonIcon(name: "CalendarMain")
    
    public let driveMain = ProtonIcon(name: "DriveMain")
    
    public let logoProton = ProtonIcon(name: "logo-proton")
    
    public let mailMain = ProtonIcon(name: "MailMain")
    
    public let vpnMain = ProtonIcon(name: "VPNMain")
    
}
