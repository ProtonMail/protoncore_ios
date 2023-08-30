import class Foundation.Bundle
import ProtonCoreFeatureSwitch
import ProtonCoreObfuscatedConstants
import typealias ProtonCoreLogin.AccountType
import typealias ProtonCorePayments.ListOfIAPIdentifiers
import typealias ProtonCorePayments.ListOfShownPlanNames
import enum ProtonCoreDataModel.ClientApp

let clientApp: ClientApp = .calendar

let listOfIAPIdentifiers: ListOfIAPIdentifiers = FeatureFactory.shared.isEnabled(.dynamicPlans) ? [] : ObfuscatedConstants.calendarIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = FeatureFactory.shared.isEnabled(.dynamicPlans) ? [] : ObfuscatedConstants.calendarShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-calendar@")

let predefinedAccountType: AccountType? = nil

#if os(iOS)
import typealias ProtonCoreLoginUI.SummaryScreenVariant
import typealias ProtonCoreLoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.calendar(SummaryStartButtonText("Start using Proton Calendar")))
#endif
