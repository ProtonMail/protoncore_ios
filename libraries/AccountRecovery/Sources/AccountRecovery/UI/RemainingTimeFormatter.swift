//
//  RemainingTimeFormatter.swift
//  ProtonCore-AccountRecovery - Created on 31/7/23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation

public extension TimeInterval {
    func asRemainingTimeString(allowingDays: Bool = false) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full

        switch (allowingDays, self) {
        case (_, 0...59): formatter.allowedUnits = [ .second ]
        case (_, 60...3599): formatter.allowedUnits = [ .minute ]
        case (_, 3600...86399): formatter.allowedUnits = [ .hour ]
        case (false, _): formatter.allowedUnits = [ .hour ]
        default: formatter.allowedUnits = [ .day ]
        }

        return formatter.string(from: self) ?? ARTranslation.graceViewUndefinedTimeLeft.l10n
    }
}
