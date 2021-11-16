import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_UIFoundations.Brand

let brand: Brand = .proton

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.mailIAPIdentifiers

let appVersionHeader: String = "iOSMail_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let signupSummaryScreenVariant = SummaryScreenVariant.mail(SummaryStartButtonText("Start using Proton Mail"))

let updateCredits = true
