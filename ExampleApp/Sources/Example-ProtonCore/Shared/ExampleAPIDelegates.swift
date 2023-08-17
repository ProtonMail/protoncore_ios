//
//  ExampleAPIDelegates.swift
//  Example-iOS-ProtonCore-NoIAP
//
//  Created by Krzysztof Siejkowski on 11/10/2021.
//

import ProtonCoreCryptoGoInterface
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices

final class ExampleAPIServiceDelegate: APIServiceDelegate {
    
    var additionalHeaders: [String : String]?

    func onUpdate(serverTime: Int64) {
        CryptoGo.CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool {
        true
    }

    var appVersion: String {
        appVersionHeader.getVersionHeader()
    }

    var locale: String {
        Locale.autoupdatingCurrent.identifier
    }

    var userAgent: String? = nil

    func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}
