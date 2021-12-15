import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .mail

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.mailIAPIdentifiers

let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.mailShownPlanNames

let appVersionHeader: String = "iOSMail_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let updateCredits = true

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant = SummaryScreenVariant.mail(SummaryStartButtonText("Start using Proton Mail"))
#endif
