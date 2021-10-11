import class Foundation.Bundle
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Login.SummaryScreenVariant
import typealias ProtonCore_Login.SummaryStartButtonText
import typealias ProtonCore_Payments.ListOfIAPIdentifiers

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.calendarIAPIdentifiers

let appVersionHeader: String = "iOSCalendar_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let signupSummaryScreenVariant = SummaryScreenVariant.calendar(SummaryStartButtonText("Start using Proton Calendar"))

let updateCredits = true
