import Crypto_VPN
import ProtonCore_Services
import ProtonCore_Payments
import ProtonCore_PaymentsUI

let inAppPurchases: Set<String> = ObfuscatedConstants.driveIAPIdentifiers

let serviceDelegate: APIServiceDelegate = DriveServiceDelegate()

let updateCredits = true

final class DriveServiceDelegate: APIServiceDelegate {

    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool {
        true
    }

    var appVersion: String {
        "iOSDrive_\(Bundle.main.majorVersion)"
    }

    var locale: String {
        Locale.autoupdatingCurrent.identifier
    }

    var userAgent: String? = nil

    func onDohTroubleshot() {
        print(#function)
    }
}
