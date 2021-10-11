import class Foundation.Bundle
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Login.SummaryScreenVariant
import typealias ProtonCore_Login.SummaryScreenCustomData
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import UIKit

let listOfIAPIdentifiers: ListOfIAPIdentifiers = []

let appVersionHeader: String = "iOSCoreExampleApp_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = nil

let signupSummaryScreenVariant = SummaryScreenVariant.custom(SummaryScreenCustomData(
  image: UIImage(), startButtonText: "Core Example app — are you sure this is the right target?"
))

let updateCredits = true
