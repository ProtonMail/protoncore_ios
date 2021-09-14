import Crypto_VPN
import ProtonCore_Payments
import ProtonCore_PaymentsUI
import ProtonCore_Services

let inAppPurchases: Set<String> = ObfuscatedConstants.mailIAPIdentifiers

let serviceDelegate: APIServiceDelegate = MailServiceDelegate()

let updateCredits = true

final class MailServiceDelegate: APIServiceDelegate {

    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool {
        true
    }

    var appVersion: String {
        "iOSMail_\(Bundle.main.majorVersion)"
    }

    var locale: String {
        Locale.autoupdatingCurrent.identifier
    }

    var userAgent: String? = nil

    func onDohTroubleshot() {
        print(#function)
    }
}
