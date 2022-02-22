//
//  PlanPresentation.swift
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

import ProtonCore_Payments
import typealias ProtonCore_DataModel.ClientApp
import ProtonCore_CoreTranslation
import ProtonCore_CoreTranslation_V5
import ProtonCore_UIFoundations
import UIKit

enum DetailType {
    case checkmark, storage, envelope, globe, folders, calendar, shield
    case vpnConnections, vpnSpeed, vpnServers, stremingServices, secureCoreServers, tor, p2p
    
    var icon: UIImage {
        // TODO: Update icons when ready
        switch self {
        case .checkmark: return IconProvider.checkmark
        case .storage: return IconProvider.storage
        case .envelope: return IconProvider.envelope
        case .globe: return IconProvider.globe
        case .folders: return IconProvider.checkmark // TODO: Missing icon
        case .calendar: return IconProvider.calendarCheckmark
        case .shield: return IconProvider.shield
        case .vpnConnections: return IconProvider.checkmark // TODO: Missing icon
        case .vpnSpeed: return IconProvider.checkmark // TODO: Missing icon
        case .vpnServers: return IconProvider.checkmark // TODO: Missing icon
        case .stremingServices: return IconProvider.checkmark // TODO: Missing icon
        case .secureCoreServers: return IconProvider.checkmark // TODO: Missing icon
        case .tor: return IconProvider.checkmark // TODO: Missing icon
        case .p2p: return IconProvider.checkmark // TODO: Missing icon
        }
    }
}

struct PlanPresentation {
    let name: String
    let title: PlanTitle
    var price: String?
    let details: [(DetailType, String)]
    var isSelectable: Bool
    var endDate: NSAttributedString?
    let cycle: String?
    let accountPlan: InAppPurchasePlan
    var storeKitProductId: String? { accountPlan.storeKitProductId }
    var isPreferred: Bool = false
    var isCurrentlyProcessed: Bool = false

    static var unavailableBecauseUserHasNoAccessToPlanDetails: PlanPresentation {
        PlanPresentation(name: "", title: .unavailable, price: nil, details: [], isSelectable: false, endDate: nil, cycle: nil,
                         accountPlan: InAppPurchasePlan(protonName: InAppPurchasePlan.freePlanName, listOfIAPIdentifiers: [])!)
    }
}

enum PlanTitle: Equatable {
    case description(String?)
    case current
    case unavailable
}

extension PlanPresentation {

    // swiftlint:disable function_parameter_count
    static func createPlan(from details: Plan,
                           clientApp: ClientApp,
                           storeKitManager: StoreKitManagerProtocol,
                           isCurrent: Bool,
                           isSelectable: Bool,
                           isMultiUser: Bool,
                           hasPaymentMethods: Bool,
                           endDate: NSAttributedString?,
                           price protonPrice: String?) -> PlanPresentation? {
        guard let plan = InAppPurchasePlan(protonName: details.name,
                                           listOfIAPIdentifiers: storeKitManager.inAppPurchaseIdentifiers)
        else { return nil }
        let price: String?
        if isCurrent, hasPaymentMethods {
            price = protonPrice
        } else if isCurrent, let currentPlanCycle = details.cycle.map(String.init), let iapCycle = plan.period, currentPlanCycle != iapCycle {
            price = protonPrice
        } else {
            price = plan.planPrice(from: storeKitManager) ?? protonPrice
        }
        let planDetails = planDetails(from: details, clientApp: clientApp, isMultiUser: isMultiUser)
        let name = planDetails.name ?? details.titleDescription
        let title: PlanTitle = isCurrent == true ? .current : .description(planDetails.description)
        return PlanPresentation(name: name, title: title, price: price, details: planDetails.details, isSelectable: isSelectable, endDate: endDate, cycle: details.cycleDescription, accountPlan: plan, isPreferred: planDetails.isPreferred)
    }
    
    static func getLocale(from name: String, storeKitManager: StoreKitManagerProtocol) -> Locale? {
        guard let plan = InAppPurchasePlan(protonName: name, listOfIAPIdentifiers: storeKitManager.inAppPurchaseIdentifiers) else { return nil }
        return plan.planLocale(from: storeKitManager)
    }
    
    typealias PlanDetails = (name: String?, description: String?, details: [(DetailType, String)], isPreferred: Bool)
    typealias PlanOptDetails = (name: String?, description: String?, optDetails: [(DetailType, String?)], isPreferred: Bool)
    // swiftlint:disable function_body_length
    private static func planDetails(from details: Plan, clientApp: ClientApp, isMultiUser: Bool) -> PlanDetails {
        let strDetails: PlanOptDetails
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
                            (.checkmark, details.vpnPaidCountriesDescription),
                            (.checkmark, details.UConnectionsDescription),
                            (.checkmark, details.highSpeedDescription)
                          ],
                          isPreferred: false)
            
        case "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==":
            strDetails = (name: "Plus",
                          description: nil,
                          optDetails: [
                            (.checkmark, details.vpnPaidCountriesDescription),
                            (.checkmark, details.UConnectionsDescription),
                            (.checkmark, details.highestSpeedDescription),
                            (.checkmark, details.adblockerDescription),
                            (.checkmark, details.streamingServiceDescription)
                          ],
                          isPreferred: false)
            
        case "R0wqZrMt5moWXl_KqI7ofCVzgV0cinuz-dHPmlsDJjwoQlu6_HxXmmHx94rNJC1cNeultZoeFr7RLrQQCBaxcA==":
            strDetails = (name: "Professional",
                          description: CoreString._pu_plan_details_pro_description,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)
            
        case "ARy95iNxhniEgYJrRrGvagmzRdnmvxCmjArhv3oZhlevziltNm07euTTWeyGQF49RxFpMqWE_ZGDXEvGV2CEkA==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)

        case "m-dPNuHcP8N4xfv6iapVg2wHifktAD1A1pFDU95qo5f14Vaw8I9gEHq-3GACk6ef3O12C3piRviy_D43Wh7xxQ==":
            strDetails = (name: "Visionary",
                          description: CoreString._pu_plan_details_visionary_description,
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.ZCalendarsDescription),
                            (.checkmark, details.UHighSpeedVPNConnectionsDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.WUsersDescription)
                          ],
                          isPreferred: false)

        case "fEZ6naOcmw7obzRd1UVIgN3yaXUKH9SgfoC8Jj_4n2q1uTq1rES78h_eaO3RHAHZ4T5vgnpAi24hgWq0QZhk8g==":
            strDetails = (name: nil,
                          description: CoreString_V5._new_plans_plan_details_plus_description,
                          optDetails: [
                            (.storage, details.XGBStorageDescription),
                            (.envelope, details.YAddressesDescription),
                            (.globe, details.VCustomEmailDomainDescription),
                            (.folders, details.unlimitedFoldersLabelsFiltersDescription),
                            (.calendar, details.ZPersonalCalendarsDescription),
                            (.shield, details.freeVPNDescription)
                          ],
                          isPreferred: false)

        case "r-cumUipwfofNYhXQWTf36Q9FBpFBdd--ZaLoGLeNGzTpKo86_yqCYWNETc4EubgVm-hgHEqbfae-t4Lw6MJSg==":
            strDetails = (name: nil,
                          description: CoreString_V5._new_plans_plan_details_vpn_plus_description,
                          optDetails: [
                            (.vpnConnections, details.UVPNConnectionsDescription),
                            (.vpnSpeed, details.highestVPNSpeedDescription),
                            (.vpnServers, details.VPNServersDescription),
                            (.shield, details.adBlockerDescription),
                            (.stremingServices, details.accessStreamingServicesDescription),
                            (.secureCoreServers, details.secureCoreServersDescription),
                            (.tor, details.torOverVPNDescription),
                            (.p2p, details.p2pDescription)
                          ],
                          isPreferred: false)

        case "sW6Msiby3tNWhOQycK3dOolAL341K40KHOPNv5wSVVFZwkayc7PIflVDxGU8oMwYoGVuI8RWz5OL3yomRfcO6A==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.ZCalendarsDescription),
                            (.checkmark, details.UVPNConnectionsDescription)
                          ],
                          isPreferred: false)

        case "KLMoowYF45_Q0hRhQ_bFx11rMIBCm3Ljr_d-U_eDQhbHSf5-j6Q2CPZxffw37BOel8uOoM0ouUmiO301xt_q7w==":
            strDetails = (name: nil,
                          description: CoreString_V5._new_plans_plan_details_bundle_description,
                          optDetails: [
                            (.storage, details.XGBStorageDescription),
                            (.envelope, details.YAddressesDescription),
                            (.globe, details.VCustomEmailDomainDescription),
                            (.folders, details.unlimitedFoldersLabelsFiltersDescription),
                            (.calendar, details.ZPersonalCalendarsDescription),
                            (.shield, details.VPNUDevicesDescription)
                          ],
                          isPreferred: true)
            
        case "Bq1saqZsuqU5bf4pfkaQWs6I1pj4-w4XWMaeYMhsF5AiU5KZw_PFUkGi8F3cPi3wcxhbsyyGMWUGkEgY7pqFjg==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, isMultiUser ? details.ZCalendarsDescription : details.ZCalendarsPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)
            
        case "eV6W5eQXiEchPojDM6SPSy7ph6tkHS1U52TBoZpT_EVqKJsO8rLjHaxS2p0MV9TmugYPdato-OX_NGF-yUEa6Q==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)
            
        case "TZ0gXiJpXxhLyU2NB1ClFY1mkNISAk0vQKuLUV7MLAynE99drRWsw-7deVSaX8vhZ_Q6rCe4GHrF-9LX345S_w==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, isMultiUser ? details.ZCalendarsDescription : details.ZCalendarsPerUserDescription),
                            (.checkmark, isMultiUser ? details.UHighSpeedVPNConnectionsDescription : details.UHighSpeedVPNConnectionsPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)

        case "hkw1pXa83IP_hkXMWCR5LraS6XIxCjCeVfgiuu3Rkge7pdwFJSoGa4H_9_9-qol9f4Cee0KLNXmiNYCcBRl8Aw==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.ZCalendarsDescription),
                            (.checkmark, details.UHighSpeedVPNConnectionsDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.WUsersDescription)
                          ],
                          isPreferred: false)

        case "ihu53A4CrTd3dTadqbbZOhcnoPZpT2fwUVXoO2nai2IIl9urLn9CU04d8tWtRS4mbZEZ261RkagN1J1l42K6dw==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.ZCalendarsDescription),
                            (.checkmark, details.UHighSpeedVPNConnectionsDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.WUsersDescription)
                          ],
                          isPreferred: false)
            
        case "B78qtYLE6I1BjXKknSHfCGRBlpkWhe-QnR68jPYnO5clBmhF9AGwBlgt_mh5M9Dje4vuMdz9QyMKXVorCx0feg==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, isMultiUser ? details.ZCalendarsDescription : details.ZCalendarsPerUserDescription),
                            (.checkmark, isMultiUser ? details.UHighSpeedVPNConnectionsDescription : details.UHighSpeedVPNConnectionsPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)

        case "gi_MHe7rStGdIGADZ0zR5fqgqD4FIjq_G53NRs-2uZfiNqYLhA6YSCTX6Ho_OYEwi0v8NLUDoZFPJZouJ_YGzw==":
            strDetails = (name: nil,
                          description: nil,
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, isMultiUser ? details.ZCalendarsDescription : details.ZCalendarsPerUserDescription),
                            (.checkmark, isMultiUser ? details.UHighSpeedVPNConnectionsDescription : details.UHighSpeedVPNConnectionsPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ],
                          isPreferred: false)

        default:
            // default description, used for no plan (aka free) or for plans with unknown ID
            switch clientApp {
            case .vpn:
                strDetails = (name: "Free",
                              description: CoreString._pu_plan_details_free_description,
                              optDetails: [
                                (.checkmark, details.vpnFreeCountriesDescription),
                                (.checkmark, details.UConnectionsDescription),
                                (.checkmark, details.vpnFreeSppedDescription)
                              ],
                              isPreferred: false)
            default:
                strDetails = (name: "Free",
                              description: CoreString_V5._new_plans_plan_details_free_description,
                              optDetails: [
                                (.storage, details.upToXGBStorageDescription),
                                (.envelope, details.YAddressesDescription),
                                (.folders, details.freeFoldersLabelsDescription),
                                (.calendar, details.ZPersonalCalendarsDescription),
                                (.shield, details.freeVPNDescription)
                              ],
                              isPreferred: false)
            }
        }
        return (name: strDetails.name, strDetails.description, strDetails.optDetails.compactMap { t in t.1.map { (t.0, $0) } }, isPreferred: strDetails.isPreferred)
    }

}
