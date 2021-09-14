import Crypto_VPN
import ProtonCore_Payments
import ProtonCore_PaymentsUI
import ProtonCore_Services

let inAppPurchases: Set<String> = ObfuscatedConstants.vpnIAPIdentifiers

let serviceDelegate: APIServiceDelegate = VPNServiceDelegate()

let updateCredits = false

final class VPNServiceDelegate: APIServiceDelegate {

    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool {
        true
    }

    var appVersion: String {
        "iOSVPN_\(Bundle.main.majorVersion)"
    }

    var locale: String {
        Locale.autoupdatingCurrent.identifier
    }

    var userAgent: String? = nil

    func onDohTroubleshot() {
        print(#function)
    }
}

