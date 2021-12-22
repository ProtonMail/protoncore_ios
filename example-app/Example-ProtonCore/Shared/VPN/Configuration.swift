import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .vpn

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.vpnIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.vpnShownPlanNames

let appVersionHeader: String = "iOSVPN_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = AccountType.username

let updateCredits = false

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant = SummaryScreenVariant.vpn(SummaryStartButtonText("Start using Proton VPN"))
#endif
