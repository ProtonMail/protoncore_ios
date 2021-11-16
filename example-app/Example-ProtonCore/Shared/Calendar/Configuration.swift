import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_UIFoundations.Brand

let brand: Brand = .proton

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.calendarIAPIdentifiers

let appVersionHeader: String = "iOSCalendar_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let signupSummaryScreenVariant = SummaryScreenVariant.calendar(SummaryStartButtonText("Start using Proton Calendar"))

let updateCredits = true
