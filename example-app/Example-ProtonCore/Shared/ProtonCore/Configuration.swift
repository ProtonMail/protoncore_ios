import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .other(named: "proton-core-example-app")

let listOfIAPIdentifiers: ListOfIAPIdentifiers = []

let appVersionHeader: String = "iOSCoreExampleApp_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let updateCredits = true

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryScreenCustomData

let signupSummaryScreenVariant = SummaryScreenVariant.custom(SummaryScreenCustomData(
  image: UIImage(), startButtonText: "Core Example app — are you sure this is the right target?"
))
#endif
