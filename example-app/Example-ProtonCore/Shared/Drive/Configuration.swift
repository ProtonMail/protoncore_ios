import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .drive

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.driveIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.driveShownPlanNames

let appVersionHeader: String = "iOSDrive_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let updateCredits = true

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant = SummaryScreenVariant.drive(SummaryStartButtonText("Start using Proton Drive"))
#endif
