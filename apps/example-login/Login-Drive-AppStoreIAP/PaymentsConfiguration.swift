import class Foundation.Bundle
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Login.SummaryScreenVariant
import typealias ProtonCore_Login.SummaryStartButtonText

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.driveIAPIdentifiers

let appVersionHeader: String = "iOSDrive_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let signupSummaryScreenVariant = SummaryScreenVariant.drive(SummaryStartButtonText("Start using Proton Drive"))
