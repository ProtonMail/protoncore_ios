//
//  Localization+Plurals.swift
//  ProtonCore-CoreTranslation - Created on 02.02.2022
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

// swiftlint:disable line_length identifier_name

import Foundation

public extension LocalizedString_V5 {
    
    // Only plural strings should be placed here
    
    var _new_plans_details_custom_email_domains_number: String {
        NSLocalizedString("New_Plans Support for %d custom email domains", bundle: Common_V5.bundle, comment: "New_Plans Details of custom email domains number")
    }
}
