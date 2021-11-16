import class Foundation.Bundle
import ProtonCore_ObfuscatedConstants
import typealias ProtonCore_Login.AccountType
import typealias ProtonCore_LoginUI.SummaryScreenVariant
import typealias ProtonCore_LoginUI.SummaryStartButtonText
import typealias ProtonCore_Payments.ListOfIAPIdentifiers
import typealias ProtonCore_UIFoundations.Brand

let brand: Brand = .vpn

let listOfIAPIdentifiers: ListOfIAPIdentifiers = ObfuscatedConstants.vpnIAPIdentifiers

let appVersionHeader: String = "iOSVPN_\(Bundle.main.majorVersion)"

let predefinedAccountType: AccountType? = AccountType.username

let signupSummaryScreenVariant = SummaryScreenVariant.vpn(SummaryStartButtonText("Start using Proton VPN"))

let updateCredits = false
