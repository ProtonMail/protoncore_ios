import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Payments.ListOfShownPlanNames
import enum ProtonCore_DataModel.ClientApp

let clientApp: ClientApp = .calendar

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.calendarIAPIdentifiers
let listOfShownPlanNames: ListOfShownPlanNames = ObfuscatedConstants.calendarShownPlanNames

let appVersionHeader = AppVersionHeader(appNamePrefix: "iOSCalendar_")

let predefinedAccountType: AccountType? = nil

let updateCredits = true

#if canImport(ProtonCore_LoginUI)
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText

let signupSummaryScreenVariant: SummaryScreenVariant = .screenVariant(.calendar(SummaryStartButtonText("Start using Proton Calendar")))
#endif
