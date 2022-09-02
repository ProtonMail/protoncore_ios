//
//  NetworkingViewModel.swift
//  ExampleApp - Created on 22/01/2021.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import ProtonCore_APIClient
import ProtonCore_Authentication
import ProtonCore_Doh
import ProtonCore_ForceUpgrade
import ProtonCore_HumanVerification
import ProtonCore_Networking
import ProtonCore_Services

class NetworkingViewModel: ObservableObject {

    private var testApi = PMAPIService(doh: BlackDoHMail.default, sessionUID: "testSessionUID")
    private var testAuthCredential : AuthCredential? = nil
    private var humanVerificationDelegate: HumanVerifyDelegate?

    init() {
        TrustKitWrapper.start(delegate: self)
        setupEnv()
    }
    
    var env = ["Black env.", "Dalton env.", "Lysenko", "Prod env."]
    var selectedIndex: Int = 0 { didSet { setupEnv() } }
    @Published var showingLoginError = false
    
    private func setupEnv() {
        testApi = PMAPIService(doh: currentEnv, sessionUID: "testSessionUID")
        testApi.authDelegate = self
        testApi.serviceDelegate = self
    }
    
    private var currentEnv: DoHInterface {
        switch selectedIndex {
        case 0: return BlackDoHMail.default
        case 1: return DaltonBlackDoHMail.default
        case 2: return LysenkoBlackDoHMail.default
        case 3: return ProdDoHMail.default
        default: return BlackDoHMail.default
        }
    }

    private var forceUpgradeServiceDelegate: APIServiceDelegate?
    private var forceUpgradeDelegate: ForceUpgradeDelegate?
    
    func humanVerificationAuthAction(userName: String, password: String) {
        humanVerification(userName: userName, password: password)
    }
    
    func humanVerificationUnauthAction() {
        humanVerification()
    }

    func forceUpgradeAction() {
        forceUpgrade()
    }
    
    private func forceUpgrade() {
        forceUpgradeServiceDelegate = {
            class TestDelegate: APIServiceDelegate {
                var userAgent: String? = ""
                func onUpdate(serverTime: Int64) {}
                func isReachable() -> Bool { return true }
                var appVersion: String = appVersionHeader.getVersionHeader()
                var additionalHeaders: [String : String]?
                var locale: String { Locale.autoupdatingCurrent.identifier }
            }
            return TestDelegate()
        }()
        
        testApi.serviceDelegate = forceUpgradeServiceDelegate
        
        //set the human verification delegation
        let url = URL(string: "itms-apps://itunes.apple.com/app/id979659905")!
        forceUpgradeDelegate = ForceUpgradeHelper(config: .mobile(url), responseDelegate: self)
        testApi.forceUpgradeDelegate = forceUpgradeDelegate
        
        // TODO: update to a PMAuthentication version that depends on PMNetworking
        let authApi: Authenticator = Authenticator(api: testApi)
        authApi.authenticate(username: "test", password: "test") { result in
            print (result)
        }
    }
    
    private func humanVerification(userName: String, password: String) {
        setupHumanVerification()
        let authApi: Authenticator = Authenticator(api: testApi)
        authApi.authenticate(username: userName, password: password) { result in
            switch result {
            case .failure(Authenticator.Errors.networkingError(let error)): // error response returned by server
                self.showingLoginError = true
                PMLog.info("error)
            case .failure(Authenticator.Errors.apiMightBeBlocked(let message, _)): // error response returned by server
                self.showingLoginError = true
                PMLog.info("message)
            case .failure(Authenticator.Errors.emptyServerSrpAuth):
                PMLog.info("")
            case .failure(Authenticator.Errors.emptyClientSrpAuth):
                PMLog.info("")
            case .failure(Authenticator.Errors.wrongServerProof):
                PMLog.info("")
            case .failure(Authenticator.Errors.emptyAuthResponse):
                PMLog.info("")
            case .failure(Authenticator.Errors.emptyAuthInfoResponse):
                PMLog.info("")
            case .failure(_): // network or parsing error
                PMLog.info("")
            case .success(.ask2FA(let context)): // success but need 2FA
                PMLog.info(context)
            case .success(.newCredential(let credential, let passwordMode)): // success without 2FA
                self.testAuthCredential = AuthCredential(credential)
                PMLog.info("pwd mode: \(passwordMode)")
                self.processHumanVerifyTest()
                break
            case .success(.updatedCredential):
                assert(false, "Should never happen in this flow")
            }
            PMLog.info(result)
        }
    }
    
    private func humanVerification() {
        setupHumanVerification()
        processHumanVerifyTest()
    }
    
    private func setupHumanVerification() {
        testAuthCredential = nil
        currentEnv.status = .off
        testApi.serviceDelegate = self
        testApi.authDelegate = self

        //set the human verification delegation
        let url = HVCommon.defaultSupportURL(clientApp: clientApp)
        humanVerificationDelegate = HumanCheckHelper(apiService: testApi, supportURL: url, viewController: nil, responseDelegate: self)
        testApi.humanDelegate = humanVerificationDelegate
    }

    private func processHumanVerifyTest() {
        // Human Verify request with empty token just to provoke human verification error
        let client = TestApiClient(api: self.testApi)
        client.triggerHumanVerify(isAuth: getToken(bySessionUID: "") != nil) { (_, response) in
            PMLog.info("Human verify test result: \(response.error?.localizedDescription as Any)")
        }
    }
}

extension NetworkingViewModel: AuthDelegate {

    func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) {
        // must call complete - later will have a middle layer manager to handle this because all plantforms will be sharee the same logic

        //steps:
        // - find auth by uid
        // - double check if the auth ok
        // - call refresh token
        // - pass result to complete
    }

    func getToken(bySessionUID uid: String) -> AuthCredential? {
        PMLog.info("looking for auth UID: " + uid)
        PMLog.info("compare cache with index: \(uid == testAuthCredential?.sessionID ?? "") ")
        return self.testAuthCredential
    }

    func onUpdate(auth: Credential) {
        /// update your local cache
    }

    // right now the logout and revoke do the same but they triggered by a different event. will try to unify this.
    func onLogout(sessionUID uid: String) {
        //try to logout this user by uid
    }

    func onForceUpgrade() {
        //
    }
}

extension NetworkingViewModel: APIServiceDelegate {
    
    var additionalHeaders: [String : String]? { nil }
    
    var userAgent: String? { "" }

    func isReachable() -> Bool { true }

    var appVersion: String { appVersionHeader.getVersionHeader() }

    func onUpdate(serverTime: Int64) { }
}

extension NetworkingViewModel: TrustKitUIDelegate {
    func onTrustKitValidationError(_ alert: UIAlertController) {
        //pops up error alert
    }
}

extension NetworkingViewModel: ForceUpgradeResponseDelegate {
    func onQuitButtonPressed() {
        // on quit button pressed
    }

    func onUpdateButtonPressed() {
        // on update button pressed
    }
}

extension NetworkingViewModel: HumanVerifyResponseDelegate {
    func onHumanVerifyStart() {
        print ("Human verify start")
    }

    func onHumanVerifyEnd(result: HumanVerifyEndResult) {
        switch result {
        case .success:
            print ("Human verify success")
        case .cancel:
            print ("Human verify cancel")
        }
    }
}
