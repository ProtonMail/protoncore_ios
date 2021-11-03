//
//  ServicePlanDetails+Extensions.swift
//  ProtonCore_PaymentsUI - Created on 01/06/2021.
//
//  Copyright (c) 2021 Proton Technologies AG
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
import ProtonCore_Payments
import ProtonCore_CoreTranslation

extension Plan {

    public var titleDescription: String {
        return title
    }

    private var storageFormatter: ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowedUnits = [.useGB]
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }

    private func roundedToOneDecimal(_ maxSpace: Int64) -> Int64 {
        let bytesInGB: Double = 1024 * 1024 * 1024
        let spaceInGB = Double(maxSpace) / bytesInGB
        let roundedSpaceInGB = round(spaceInGB * 10) / 10
        let roundedSpace = roundedSpaceInGB * bytesInGB
        return Int64(roundedSpace)
    }

    var XGBStorageDescription: String {
        String(format: CoreString._pu_plan_details_storage,
               storageFormatter.string(fromByteCount: roundedToOneDecimal(maxSpace)))
    }

    var XGBStoragePerUserDescription: String {
        return String(format: CoreString._pu_plan_details_storage_per_user,
                      storageFormatter.string(fromByteCount: roundedToOneDecimal(maxSpace)))
    }

    var YAddressesDescription: String {
        maxAddresses == 1
            ? String(format: CoreString._pu_plan_details_n_address, maxAddresses)
            : String(format: CoreString._pu_plan_details_n_addresses, maxAddresses)
    }

    var YAddressesPerUserDescription: String {
        maxAddresses == 1
            ? String(format: CoreString._pu_plan_details_n_address_per_user, maxAddresses)
            : String(format: CoreString._pu_plan_details_n_addresses_per_user, maxAddresses)
    }

    var ZCalendarsDescription: String? {
        guard let maxCalendars = maxCalendars else { return nil }
        return maxCalendars == 1
            ? String(format: CoreString._pu_plan_details_n_calendar, maxCalendars)
            : String(format: CoreString._pu_plan_details_n_calendars, maxCalendars)
    }

    var ZCalendarsPerUserDescription: String? {
        guard let maxCalendars = maxCalendars else { return nil }
        return maxCalendars == 1
            ? String(format: CoreString._pu_plan_details_n_calendar_per_user, maxCalendars)
            : String(format: CoreString._pu_plan_details_n_calendars_per_user, maxCalendars)
    }

    var UVPNConnectionsDescription: String {
        maxVPN == 1
            ? String(format: CoreString._pu_plan_details_n_connection, maxVPN)
            : String(format: CoreString._pu_plan_details_n_connections, maxVPN)
    }

    var UHighSpeedVPNConnectionsDescription: String {
        maxVPN == 1
            ? String(format: CoreString._pu_plan_details_n_high_speed_connection, maxVPN)
            : String(format: CoreString._pu_plan_details_n_high_speed_connections, maxVPN)
    }

    var UHighSpeedVPNConnectionsPerUserDescription: String {
        maxVPN == 1
            ? String(format: CoreString._pu_plan_details_n_high_speed_connection_per_user, maxVPN)
            : String(format: CoreString._pu_plan_details_n_high_speed_connections_per_user, maxVPN)
    }

    var VCustomDomainDescription: String {
        maxDomains == 1
            ? String(format: CoreString._pu_plan_details_n_custom_domain, maxDomains)
            : String(format: CoreString._pu_plan_details_n_custom_domains, maxDomains)
    }

    var WUsersDescription: String {
        maxMembers == 1
            ? String(format: CoreString._pu_plan_details_n_user, maxMembers)
            : String(format: CoreString._pu_plan_details_n_users, maxMembers)
    }

    var YAddressesAndZCalendars: String {
        guard let ZCalendarsDescription = ZCalendarsDescription else { return YAddressesDescription }
        if maxAddresses == maxCalendars {
            return maxAddresses == 1
                ? String(format: CoreString._pu_plan_details_n_address_and_calendar, maxAddresses)
                : String(format: CoreString._pu_plan_details_n_addresses_and_calendars, maxAddresses)
        } else {
            return String(format: CoreString._pu_plan_details_n_uneven_amounts_of_addresses_and_calendars,
                          YAddressesDescription, ZCalendarsDescription)
        }
    }

    var highSpeedDescription: String {
        CoreString._pu_plan_details_high_speed
    }

    var highestSpeedDescription: String {
        CoreString._pu_plan_details_highest_speed
    }

    var multiUserSupportDescription: String {
        CoreString._pu_plan_details_multi_user_support
    }
    
    var cycleDescription: String? {
        guard let cycle = cycle else { return nil }
        let years = cycle / 12
        if years > 0 {
            return years == 1 ? CoreString._pu_plan_details_price_time_period_1_y : String(format: CoreString._pu_plan_details_price_time_period_x_y, years)
        } else {
            return cycle == 1 ? CoreString._pu_plan_details_price_time_period_1_m : nil
        }
    }
}
