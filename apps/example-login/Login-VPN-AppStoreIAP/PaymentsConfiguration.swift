import class Foundation.Bundle
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_Login.SummaryScreenVariant
import typealias ProtonCore_Login.SummaryStartButtonText

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.vpnIAPIdentifiers

let appVersionHeader: String = "iOSVPN_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = AccountType.username

let signupSummaryScreenVariant = SummaryScreenVariant.vpn(SummaryStartButtonText("Start using Proton VPN"))
