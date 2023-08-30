import class Foundation.Bundle
import ProtonCoreFeatureSwitch
import ProtonCoreObfuscatedConstants
import typealias ProtonCoreLogin.AccountType
import typealias ProtonCorePayments.ListOfIAPIdentifiers
import typealias ProtonCorePayments.ListOfShownPlanNames
import enum ProtonCoreDataModel.ClientApp

let clientApp: ClientApp = .vpn

let listOfIAPIdentifiers: ListOfIAPIdentifiers = FeatureFactory.shared.isEnabled(.dynamicPlans) ? [] : ObfuscatedConstants.vpnIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = FeatureFactory.shared.isEnabled(.dynamicPlans) ? [] : ObfuscatedConstants.vpnShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-vpn@")

let predefinedAccountType: AccountType? = AccountType.username

#if os(iOS)
import typealias ProtonCoreLoginUI.SummaryScreenVariant
import typealias ProtonCoreLoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.vpn(SummaryStartButtonText("Start using Proton VPN")))
#endif
