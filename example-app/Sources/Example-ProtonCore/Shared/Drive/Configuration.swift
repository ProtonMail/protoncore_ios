import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .drive

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.driveIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.driveShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-drive@")

let predefinedAccountType: AccountType? = nil

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.drive(SummaryStartButtonText("Start using Proton Drive")))
#endif
