//
//  UserPlans.swift
//  ProtonCore-QuarkCommands - Created on 08.12.2023.
//
// Copyright (c) 2023. Proton Technologies AG
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.
import Foundation

public enum UserPlan: String {

    case free = "free"

    case bundle2022 = "bundle2022"
    case bundlepro2022 = "bundlepro2022"
    case drive2022 = "drive2022"
    case drivepro2022 = "drivepro2022"
    case enterprise2022 = "enterprise2022"
    case family2022 = "family2022"
    case mail2022 = "mail2022"
    case mailpro2022 = "mailpro2022"
    case vpn2022 = "vpn2022"
    case visionary2022 = "visionary2022"

    case pass2023 = "pass2023"
    case vpnpass2023 = "vpnpass2023"
    case vpnpro2023 = "vpnpro2023"
    case vpnbiz2023 = "vpnbiz2023"

    case passbiz2024 = "passbiz2024"
    case passpro2024 = "passpro2024"
}
