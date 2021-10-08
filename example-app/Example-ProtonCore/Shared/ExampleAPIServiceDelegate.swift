//
//  ExampleAPIServiceDelegate.swift
//  Example-iOS-ProtonCore-NoIAP
//
//  Created by Krzysztof Siejkowski on 11/10/2021.
//

#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_Services

final class ExampleAPIServiceDelegate: APIServiceDelegate {

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
