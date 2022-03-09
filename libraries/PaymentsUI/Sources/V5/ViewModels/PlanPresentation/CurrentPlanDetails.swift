//
//  CurrentPlanDetails.swift
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

struct CurrentPlanDetails {
    let name: String
    var price: String?
    let cycle: String?
    let details: [(DetailType, String)]
    var endDate: NSAttributedString?
    let usedSpace: Int64
    let maxSpace: Int64
    let usedSpaceDescription: String?
}

extension CurrentPlanDetails {
    // swiftlint:disable function_parameter_count
    static func createPlan(from details: Plan,
                           plan: InAppPurchasePlan,
                           currentSubscription: Subscription?,
                           clientApp: ClientApp,
                           storeKitManager: StoreKitManagerProtocol,
                           isMultiUser: Bool,
                           protonPrice: String?,
                           hasPaymentMethods: Bool,
                           endDate: NSAttributedString?) -> CurrentPlanDetails {
        let planDetails = planDataDetails(from: details, currentSubscription: currentSubscription, clientApp: clientApp, isMultiUser: isMultiUser)
        let name = planDetails.name ?? details.titleDescription
        let price: String?
        if hasPaymentMethods {
            price = protonPrice
        } else if let currentPlanCycle = details.cycle.map(String.init), let iapCycle = plan.period, currentPlanCycle != iapCycle {
            price = protonPrice
        } else {
            price = plan.planPrice(from: storeKitManager) ?? protonPrice
        }
        return CurrentPlanDetails(name: name, price: price, cycle: details.cycleDescription, details: planDetails.details, endDate: endDate, usedSpace: currentSubscription?.organization?.usedSpace ?? 0, maxSpace: details.maxSpace, usedSpaceDescription: planDetails.usedSpace)
    }
    
    typealias PlanDataDetails = (name: String?, usedSpace: String?, details: [(DetailType, String)])
    typealias PlanDataOptDetails = (name: String?, usedSpace: String?, optDetails: [(DetailType, String?)])
    
    // swiftlint:disable function_body_length
    private static func planDataDetails(from details: Plan, currentSubscription: Subscription?, clientApp: ClientApp, isMultiUser: Bool) -> PlanDataDetails {
        let strDetails: PlanDataOptDetails
        let usedSpace = currentSubscription?.organization?.usedSpace ?? currentSubscription?.usedSpace
        switch details.iD {
        case "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==":
            strDetails = (name: "Plus",
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.plusLabelsDescription),
                            (.checkmark, details.customEmailDescription),
                            (.checkmark, details.prioritySupportDescription)
                          ])

        case "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==":
            strDetails = (name: "Basic",
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.checkmark, details.vpnPaidCountriesDescription),
                            (.checkmark, details.UConnectionsDescription),
                            (.checkmark, details.highSpeedDescription)
                          ])
            
        case "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==":
            strDetails = (name: "Plus",
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.checkmark, details.vpnPaidCountriesDescription),
                            (.checkmark, details.UConnectionsDescription),
                            (.checkmark, details.highestSpeedDescription),
                            (.checkmark, details.adblockerDescription),
                            (.checkmark, details.streamingServiceDescription)
                          ])
            
        case "R0wqZrMt5moWXl_KqI7ofCVzgV0cinuz-dHPmlsDJjwoQlu6_HxXmmHx94rNJC1cNeultZoeFr7RLrQQCBaxcA==":
            strDetails = (name: "Professional",
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ])
            
        case "ARy95iNxhniEgYJrRrGvagmzRdnmvxCmjArhv3oZhlevziltNm07euTTWeyGQF49RxFpMqWE_ZGDXEvGV2CEkA==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.checkmark, isMultiUser ? details.XGBStorageDescription : details.XGBStoragePerUserDescription),
                            (.checkmark, isMultiUser ? details.YAddressesDescription : details.YAddressesPerUserDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.multiUserSupportDescription)
                          ])

        case "m-dPNuHcP8N4xfv6iapVg2wHifktAD1A1pFDU95qo5f14Vaw8I9gEHq-3GACk6ef3O12C3piRviy_D43Wh7xxQ==":
            strDetails = (name: "Visionary",
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.checkmark, details.XGBStorageDescription),
                            (.checkmark, details.YAddressesDescription),
                            (.checkmark, details.ZCalendarsDescription),
                            (.checkmark, details.UHighSpeedVPNConnectionsDescription),
                            (.checkmark, details.VCustomDomainDescription),
                            (.checkmark, details.WUsersDescription)
                          ])
            
        case "fEZ6naOcmw7obzRd1UVIgN3yaXUKH9SgfoC8Jj_4n2q1uTq1rES78h_eaO3RHAHZ4T5vgnpAi24hgWq0QZhk8g==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                            (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                            (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                            (.shield, details.UVPNConnectionsDescription)
                          ])

        case "r-cumUipwfofNYhXQWTf36Q9FBpFBdd--ZaLoGLeNGzTpKo86_yqCYWNETc4EubgVm-hgHEqbfae-t4Lw6MJSg==":
            strDetails = (name: nil,
                          usedSpace: nil,
                          optDetails: [
                            (.powerOff, details.UVPNConnectionsDescription),
                            (.rocket, details.VPNHighestSpeedDescription),
                            (.servers, details.VPNServersDescription),
                            (.shield, details.adBlockerDescription),
                            (.play, details.accessStreamingServicesDescription),
                            (.locks, details.secureCoreServersDescription),
                            (.brandTor, details.torOverVPNDescription),
                            (.arrowsSwitch, details.p2pDescription)
                          ])
        case "38pKeB043dpMLfF_hjmZb7Zq3Gzrx6vpgojF5tPHKhJXNGUmwvNMKTSMYHDsp8Y-n8EUqYem3QMvUQh7LZDnaw==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                            (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                            (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                            (.shield, details.UVPNConnectionsDescription)
                          ])

        case "KLMoowYF45_Q0hRhQ_bFx11rMIBCm3Ljr_d-U_eDQhbHSf5-j6Q2CPZxffw37BOel8uOoM0ouUmiO301xt_q7w==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                            (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                            (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                            (.shield, details.UVPNConnectionsDescription)
                          ])
        case "N63r9gPcEBu6cenKrOIjIwPLzuT_So458WgbiBvHbDueZ8K_PQboKAAWu5yH95-3SEk7R4nnxqlU-qhRD07r5w==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                            (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                            (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                            (.shield, details.UVPNConnectionsDescription)
                          ])
        case "Ik65N-aChBuWFdo1JpmHJB4iWetfzjVLNILERQqbYFBZc5crnxOabXKuIMKhiwBNwiuogItetAUvkFTwJFJPQg==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                            (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                            (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                            (.shield, details.UVPNConnectionsDescription)
                          ])
        case "jctxnoKsvmlISYpOtESCWNC4tcFbddXmcQ6yyM94YP4tBngrw4O9IKf8jxSLThqZyqFlX972kKwQCPriEeh4qg==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.WUsersDescription),
                            (.envelope, details.YAddressesPerUserDescriptionV5),
                            (.calendarCheckmark, details.ZPersonalCalendarsPerUserDescription)
                          ])
            
        case "Z33WkziHqmXCEJ1Udm8f2vC3Jss9EIkFrgk4_rlSDoVHASjAemj5FsCUTYr7_27bgrbE4whe41PY4TiIr9Z-TA==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                            (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                            (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                            (.shield, details.UVPNConnectionsDescription)
                          ])
            
        case "Zv2tcvM2nlQ8XiYwWvWtfR-wO9BHprBVm-UxtpNUMlex0M-EEQpfQxdx-dEYscubmbHjMo6ItsHNp0QqTM89oA==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.user, details.WUsersDescription),
                            (.envelope, details.YAddressesPerUserDescriptionV5),
                            (.calendarCheckmark, details.ZPersonalCalendarsPerUserDescription),
                            (.shield, details.UConnectionsPerUserDescription)
                          ])
            
        case "OYB-3pMQQA2Z2Qnp5s5nIvTVO2alU6h82EGLXYHn1mpbsRvE7UfyAHbt0_EilRjxhx9DCAUM9uXfM2ZUFjzPXw==":
            strDetails = (name: nil,
                          usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                          optDetails: [
                            (.envelope, details.YAddressesPerUserDescriptionV5),
                            (.calendarCheckmark, details.ZPersonalCalendarsPerUserDescription),
                            (.shield, details.UConnectionsPerUserDescription)
                          ])

        default:
            // default description, used for no plan (aka free) or for plans with unknown ID
            switch clientApp {
            case .vpn:
                strDetails = (name: "Free",
                              usedSpace: nil,
                              optDetails: [
                                (.servers, details.VPNFreeServersDescription),
                                (.rocket, details.VPNFreeSpeedDescription),
                                (.eyeSlash, details.VPNNoLogsPolicy)
                              ])
            default:
                strDetails = (name: "Free",
                              usedSpace: details.RSGBUsedStorageSpaceDescription(usedSpace: usedSpace),
                              optDetails: [
                                (.user, details.TWUsersDescription(usedMembers: currentSubscription?.organization?.usedMembers)),
                                (.envelope, details.PYAddressesDescription(usedAddresses: currentSubscription?.organization?.usedAddresses)),
                                (.calendarCheckmark, details.QZPersonalCalendarsDescription(usedCalendars: currentSubscription?.organization?.usedCalendars)),
                                (.shield, details.UVPNConnectionsDescription)
                              ])
            }
        }
        return (name: strDetails.name, strDetails.usedSpace, strDetails.optDetails.compactMap { t in t.1.map { (t.0, $0) } })
    }

}
