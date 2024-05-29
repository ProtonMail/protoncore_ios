//
//  BugReportViewModel.swift
//  ProtonCore-Settings - Created on 28.05.2024.
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
import ProtonCoreUtilities

private class Handler {}

public enum BugReportTranslations: TranslationsExposing {

    public static var bundle: Bundle {
        #if SPM
        return Bundle.module
        #else
        return Bundle(path: Bundle(for: Handler.self).path(forResource: "Resources-Settings", ofType: "bundle")!)!
        #endif
    }

    public static var prefixForMissingValue: String = ""

    case bugReport
    case sendReport
    case title
    case whatWentWrong
    case whatWentWrongPlaceholder
    case reportSentSuccessfully

    public var l10n: String {
        switch self {
        case .bugReport:
            return localized(key: "Bug report", comment: "Title of the screen")
        case .sendReport:
            return localized(key: "Send report", comment: "Action button")
        case .title:
            return localized(key: "Title", comment: "Title of the title text field")
        case .whatWentWrong:
            return localized(key: "What went wrong", comment: "Title of the description text field")
        case .whatWentWrongPlaceholder:
            return localized(key: "Please describe the problem in as much detail as you can. If there was an error message, let us know what it said. Minimum 10 characters.", comment: "Placeholder of the description text field")
        case .reportSentSuccessfully:
            return localized(key: "Your report was sent successfully", comment: "Banner message after the report is sent")
        }
    }
}
