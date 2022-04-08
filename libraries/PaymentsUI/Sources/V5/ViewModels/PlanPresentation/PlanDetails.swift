//
//  PlanDetails.swift
//  ProtonCore_PaymentsUI - Created on 01/06/2021.
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

import ProtonCore_Payments
import typealias ProtonCore_DataModel.ClientApp
import ProtonCore_CoreTranslation
import ProtonCore_CoreTranslation_V5
import ProtonCore_UIFoundations
import UIKit

struct PlanDetails {
    let name: String
    let title: String?
    var price: String?
    let cycle: String?
    var isSelectable: Bool
    let details: [(DetailType, String)]
    var isPreferred: Bool = false
}

extension PlanDetails {
    // swiftlint:disable function_parameter_count
    static func createPlan(from details: Plan,
                           plan: InAppPurchasePlan,
                           countriesCount: Int?,
                           clientApp: ClientApp,
                           storeKitManager: StoreKitManagerProtocol,
                           protonPrice: String?,
                           isSelectable: Bool) -> PlanDetails {
        let planDataDetails = planDataDetails(from: details, countriesCount: countriesCount, clientApp: clientApp)
        let name = planDataDetails.name ?? details.titleDescription
        let price = plan.planPrice(from: storeKitManager) ?? protonPrice
        return PlanDetails(name: name, title: planDataDetails.description, price: price, cycle: details.cycleDescription, isSelectable: isSelectable, details: planDataDetails.details, isPreferred: planDataDetails.isPreferred)
    }
    
    typealias PlanDataDetails = (name: String?, description: String?, details: [(DetailType, String)], isPreferred: Bool)
    typealias PlanDataOptDetails = (name: String?, description: String?, optDetails: [(DetailType, String?)], isPreferred: Bool)
    
    private static func planDataDetails(from details: Plan, countriesCount: Int?, clientApp: ClientApp) -> PlanDataDetails {
        let strDetails: PlanDataOptDetails
        switch details.iD {
        case "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==":
            strDetails = (name: "Plus",
                          description:
                            CoreString._pu_plan_details_plus_description,
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.plusLabelsDescription),
                            (.checkmark, details.customEmailDescription),
                            (.checkmark, details.prioritySupportDescription)
                          ],
                          isPreferred: false)

        case "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==":
            strDetails = (name: "Basic",
                          description: nil,
                          optDetails: [
                            (.checkmark, details.vpnPaidCountriesDescriptionV5(countries: countriesCount)),
                            (.checkmark, details.UConnectionsDescription),
                            (.checkmark, details.highSpeedDescription)
                          ],
                          isPreferred: false)
            
        case "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==":
            strDetails = (name: "Plus",
                          description: nil,
                          optDetails: [
                            (.checkmark, details.vpnPaidCountriesDescriptionV5(countries: countriesCount)),
                            (.checkmark, details.UConnectionsDescription),
                            (.checkmark, details.highestSpeedDescription),
                            (.checkmark, details.adblockerDescription),
                            (.checkmark, details.streamingServiceDescription)
                          ],
                          isPreferred: false)

        case "fEZ6naOcmw7obzRd1UVIgN3yaXUKH9SgfoC8Jj_4n2q1uTq1rES78h_eaO3RHAHZ4T5vgnpAi24hgWq0QZhk8g==":
            strDetails = (name: nil,
                          description: CoreString_V5._new_plans_plan_details_plus_description,
                          optDetails: [
                            (.storage, details.XGBStorageDescription),
                            (.envelope, details.YAddressesDescription),
                            (.globe, details.VCustomEmailDomainDescription),
                            (.tag, details.unlimitedFoldersLabelsFiltersDescription),
                            (.calendarCheckmark, details.ZPersonalCalendarsDescription),
                            (.shield, details.VPNFreeDescription)
                          ],
                          isPreferred: false)

        case "r-cumUipwfofNYhXQWTf36Q9FBpFBdd--ZaLoGLeNGzTpKo86_yqCYWNETc4EubgVm-hgHEqbfae-t4Lw6MJSg==":
            strDetails = (name: nil,
                          description: CoreString_V5._new_plans_plan_details_vpn_plus_description,
                          optDetails: [
                            (.powerOff, details.UVPNConnectionsDescription),
                            (.rocket, details.VPNHighestSpeedDescription),
                            (.servers, details.VPNServersDescription(countries: countriesCount)),
                            (.shield, details.adBlockerDescription),
                            (.play, details.accessStreamingServicesDescription),
                            (.locks, details.secureCoreServersDescription),
                            (.brandTor, details.torOverVPNDescription),
                            (.arrowsSwitch, details.p2pDescription)
                          ],
                          isPreferred: false)

        case "38pKeB043dpMLfF_hjmZb7Zq3Gzrx6vpgojF5tPHKhJXNGUmwvNMKTSMYHDsp8Y-n8EUqYem3QMvUQh7LZDnaw==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.storage, details.XGBStorageDescription),
                            (.envelope, details.YAddressesDescription),
                            (.calendarCheckmark, details.ZPersonalCalendarsDescription),
                            (.shield, details.UVPNConnectionsDescription),
                          ],
                          isPreferred: false)

        case "KLMoowYF45_Q0hRhQ_bFx11rMIBCm3Ljr_d-U_eDQhbHSf5-j6Q2CPZxffw37BOel8uOoM0ouUmiO301xt_q7w==":
            strDetails = (name: nil,
                          description: CoreString_V5._new_plans_plan_details_bundle_description,
                          optDetails: [
                            (.storage, details.XGBStorageDescription),
                            (.envelope, details.YAddressesDescription),
                            (.globe, details.VCustomEmailDomainDescription),
                            (.tag, details.unlimitedFoldersLabelsFiltersDescription),
                            (.calendarCheckmark, details.ZPersonalCalendarsDescription),
                            (.shield, details.VPNUDevicesDescription)
                          ],
                          isPreferred: true)

        default:
            // default description, used for no plan (aka free) or for plans with unknown ID
            switch clientApp {
            case .vpn:
                strDetails = (name: "Free",
                              description: CoreString._pu_plan_details_free_description,
                              optDetails: [
                                (.servers, details.VPNFreeServersDescription(countries: countriesCount)),
                                (.rocket, details.VPNFreeSpeedDescription),
                                (.eyeSlash, details.VPNNoLogsPolicy)
                              ],
                              isPreferred: false)
            default:
                strDetails = (name: "Free",
                              description: CoreString_V5._new_plans_plan_details_free_description,
                              optDetails: [
                                (.storage, details.upToXGBStorageDescription),
                                (.envelope, details.YAddressesDescription),
                                (.tag, details.freeFoldersLabelsDescription),
                                (.calendarCheckmark, details.ZPersonalCalendarsDescription),
                                (.shield, details.VPNFreeDescription)
                              ],
                              isPreferred: false)
            }
        }
        return (name: strDetails.name, strDetails.description, strDetails.optDetails.compactMap { t in t.1.map { (t.0, $0) } }, isPreferred: strDetails.isPreferred)
    }

}
