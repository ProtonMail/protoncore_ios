import class Foundation.Bundle
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Login.SummaryScreenVariant
import typealias ProtonCore_Login.SummaryStartButtonText

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.mailIAPIdentifiers

let appVersionHeader: String = "iOSMail_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let signupSummaryScreenVariant = SummaryScreenVariant.mail(SummaryStartButtonText("Start using Proton Mail"))
