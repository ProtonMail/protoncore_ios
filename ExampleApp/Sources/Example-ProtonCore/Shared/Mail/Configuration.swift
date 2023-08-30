import class Foundation.Bundle
import ProtonCoreFeatureSwitch
import ProtonCoreObfuscatedConstants
import typealias ProtonCoreLogin.AccountType
import typealias ProtonCorePayments.ListOfIAPIdentifiers
import typealias ProtonCorePayments.ListOfShownPlanNames
import enum ProtonCoreDataModel.ClientApp

let clientApp: ClientApp = .mail

let listOfIAPIdentifiers: ListOfIAPIdentifiers = FeatureFactory.shared.isEnabled(.dynamicPlans) ? [] : ObfuscatedConstants.mailIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = FeatureFactory.shared.isEnabled(.dynamicPlans) ? [] : ObfuscatedConstants.mailShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-mail@")

let predefinedAccountType: AccountType? = nil

#if os(iOS)
import typealias ProtonCoreLoginUI.SummaryScreenVariant
import typealias ProtonCoreLoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.mail(SummaryStartButtonText("Start using Proton Mail")))
#endif
