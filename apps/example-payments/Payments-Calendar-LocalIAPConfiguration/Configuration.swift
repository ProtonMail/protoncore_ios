import Crypto_VPN
import ProtonCore_Payments
import ProtonCore_PaymentsUI
import ProtonCore_Services

let inAppPurchases: Set<String> = ObfuscatedConstants.calendarIAPIdentifiers

let serviceDelegate: APIServiceDelegate = CalendarServiceDelegate()

let updateCredits = true

final class CalendarServiceDelegate: APIServiceDelegate {

    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool {
        true
    }

    var appVersion: String {
        "iOSCalendar_\(Bundle.main.majorVersion)"
    }

    var locale: String {
        Locale.autoupdatingCurrent.identifier
    }

    var userAgent: String? = nil

    func onDohTroubleshot() {
        print(#function)
    }
}
