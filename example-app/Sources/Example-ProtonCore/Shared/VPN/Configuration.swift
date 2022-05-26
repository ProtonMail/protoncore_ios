import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .vpn

let listOfIAPIdentifiers: ListOfIAPIdentifiers = [
    "ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing", "iosvpn_vpn2022_12_usd_non_renewing", "iosvpn_bundle2022_12_usd_non_renewing"
] // ObfuscatedConstants.vpnIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = [
    "vpnbasic", "vpnplus", "visionary", "vpn2022", "bundle2022", "family2022", "visionary2022", "bundlepro2022", "enterprise2022"
] // ObfuscatedConstants.vpnShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "iOSVPN_")

let predefinedAccountType: AccountType? = AccountType.username

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.vpn(SummaryStartButtonText("Start using Proton VPN")))
#endif
