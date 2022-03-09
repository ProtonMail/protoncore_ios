import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .vpn

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.vpnIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.vpnShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "iOSVPN_")

let predefinedAccountType: AccountType? = AccountType.username

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.vpn(SummaryStartButtonText("Start using Proton VPN")))
#endif
