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
    
    /// Plan details n custom email domains
    var _new_plans_details_n_custom_email_domains: String {
        NSLocalizedString("New_Plans Support for %d custom email domains", tableName: "Localizable_V5", bundle: Common_V5.bundle, comment: "New_Plans details n custom email domains")
    }
    
    /// Plan details n folders and  labels
    var _new_plans_details_n_folders_labels: String {
        NSLocalizedString("New_Plans %d folders and labels", tableName: "Localizable_V5", bundle: Common_V5.bundle, comment: "New_Plans Plan details n folders and labels")
    }
    
    /// Plan details n personal calendars
    var _new_plans_details_n_personal_calendars: String {
        NSLocalizedString("New_Plans %d personal calendars", tableName: "Localizable_V5", bundle: Common_V5.bundle, comment: "New_Plans Plan details n personal calendars")
    }
    
    /// Plan details VPN on n devices
    var _new_plans_details_vpn_on_n_devices: String {
        NSLocalizedString("New_Plans High-speed VPN on %d devices", tableName: "Localizable_V5", bundle: Common_V5.bundle, comment: "New_Plans Plan details VPN on n devices")
    }
    
    /// Plan details VPN connections
    var _new_plans_details_vpn_servers: String {
        NSLocalizedString("New_Plans %d+ servers in %d countries", tableName: "Localizable_V5", bundle: Common_V5.bundle, comment: "New_Plans Plan details n servers in m countries")
    }
}
