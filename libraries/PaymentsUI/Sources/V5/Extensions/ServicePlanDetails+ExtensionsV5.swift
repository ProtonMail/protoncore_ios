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
import ProtonCore_CoreTranslation_V5

extension Plan {

    var upToXGBStorageDescription: String {
        String(format: CoreString_V5._new_plans_details_up_to_storage,
               storageFormatter.string(fromByteCount: roundedToOneDecimal(maxSpace)))
    }

    var VCustomEmailDomainDescription: String {
        String(format: CoreString_V5._new_plans_details_n_custom_email_domains, maxDomains)
    }
    
    var unlimitedFoldersLabelsFiltersDescription: String {
        CoreString_V5._new_plans_details_unlimited_folders_labels_filters
    }
    
    var freeFoldersLabelsDescription: String {
        String(format: CoreString_V5._new_plans_details_n_folders_labels, 3)
    }
    
    var ZPersonalCalendarsDescription: String? {
        guard let maxCalendars = maxCalendars else { return nil }
        return String(format: CoreString_V5._new_plans_details_n_personal_calendars, maxCalendars)
    }

    var freeVPNDescription: String {
        CoreString_V5._new_plans_details_vpn_on_single_device
    }
    
    var VPNUDevicesDescription: String {
        String(format: CoreString_V5._new_plans_details_vpn_on_n_devices, maxVPN)
    }
    
    var highestVPNSpeedDescription: String {
        CoreString_V5._new_plans_details_highest_VPN_speed
    }
    
    var VPNServersDescription: String {
        String(format: CoreString_V5._new_plans_details_vpn_servers, 1500, 63)
    }
    
    var adBlockerDescription: String {
        CoreString_V5._new_plans_details_ad_blocker
    }
    
    var accessStreamingServicesDescription: String {
        CoreString_V5._new_plans_details_access_streaming_services
    }
    
    var secureCoreServersDescription: String {
        CoreString_V5._new_plans_details_secure_core_servers
    }
    
    var torOverVPNDescription: String {
        CoreString_V5._new_plans_details_tor_over_vpn
    }

    var p2pDescription: String {
        CoreString_V5._new_plans_details_p2p
    }

}
