//
//  NotificationColors.swift
//  ProtonCore-HumanVerification - Created on 10/03/22.
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

import ProtonCore_UIFoundations

enum NotificationColors {
    
    static var error: NSColor { ColorProvider.SignalDanger }
    
    static var warning: NSColor { ColorProvider.SignalWarning }
    
    static var info: NSColor { ColorProvider.SignalInfo }
    
    static var success: NSColor { ColorProvider.SignalSuccess }
    
    static var text: NSColor { ColorProvider.TextNorm }
    
    static var textInverted: NSColor { ColorProvider.TextNorm }
    
}
