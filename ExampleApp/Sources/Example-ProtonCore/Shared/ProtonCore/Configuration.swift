import class Foundation.Bundle
import ProtonCoreObfuscatedConstants
import typealias ProtonCoreLogin.AccountType
import typealias ProtonCorePayments.ListOfIAPIdentifiers
import typealias ProtonCorePayments.ListOfShownPlanNames
import enum ProtonCoreDataModel.ClientApp

let clientApp: ClientApp = .pass

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.passIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.passShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-pass@")

let predefinedAccountType: AccountType? = nil

#if os(iOS)
import typealias ProtonCoreLoginUI.SummaryScreenVariant
import typealias ProtonCoreLoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.pass(SummaryStartButtonText("Start using Proton Pass")))
#endif
