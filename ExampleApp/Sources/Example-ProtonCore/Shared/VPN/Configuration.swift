import class Foundation.Bundle
import ProtonCoreObfuscatedConstants
import typealias ProtonCoreLogin.AccountType
import typealias ProtonCorePayments.ListOfIAPIdentifiers
import typealias ProtonCorePayments.ListOfShownPlanNames
import enum ProtonCoreDataModel.ClientApp

let clientApp: ClientApp = .vpn

let listOfIAPIdentifiers: ListOfIAPIdentifiers = [
    "ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing", "iosvpn_vpn2022_12_usd_non_renewing", "iosvpn_bundle2022_12_usd_non_renewing"
] // ObfuscatedConstants.vpnIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = [
    "vpnbasic", "vpnplus", "visionary", "vpn2022", "bundle2022", "family2022", "visionary2022", "bundlepro2022", "enterprise2022"
] // ObfuscatedConstants.vpnShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-vpn@")

let predefinedAccountType: AccountType? = AccountType.username

#if os(iOS)
import typealias ProtonCoreLoginUI.SummaryScreenVariant
import typealias ProtonCoreLoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.vpn(SummaryStartButtonText("Start using Proton VPN")))
#endif
