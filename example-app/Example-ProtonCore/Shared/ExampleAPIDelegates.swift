//
//  ExampleAPIDelegates.swift
//  Example-iOS-ProtonCore-NoIAP
//
//  Created by Krzysztof Siejkowski on 11/10/2021.
//

#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_Networking
import ProtonCore_Services

final class ExampleAPIServiceDelegate: APIServiceDelegate {

    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
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
        print(#function)
    }
}

final class ExampleAuthDelegate: AuthDelegate {
    
    private var credential: Credential?
    
    init(credential: Credential? = nil) {
        self.credential = credential
    }
    
    func getToken(bySessionUID uid: String) -> AuthCredential? {
        credential.map(AuthCredential.init)
    }
    
    func onLogout(sessionUID uid: String) {
        credential = nil
    }
    
    func onUpdate(auth: Credential) {
        credential = auth
    }
    
    func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) {
        complete(nil, nil)
    }
}
