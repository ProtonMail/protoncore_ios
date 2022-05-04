//
//  NetworkingViewController.swift
//  ExampleApp - Created on 02/25/2020.
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

import UIKit
import ProtonCore_APIClient
import ProtonCore_Authentication
import ProtonCore_Common
import ProtonCore_Doh
import ProtonCore_ForceUpgrade
import ProtonCore_HumanVerification
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_ObfuscatedConstants
import ProtonCore_UIFoundations
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

///each user will have one api service  & you can create more than one unauthed apiService
///session/auth data are controlled by a central manager. it needs to extend & implment the API service delegates.

// e.g. we use main view controller as a central manager. it could be any management class instance
class NetworkingViewController: UIViewController {
    
    @IBOutlet var environmentSelector: EnvironmentSelector!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var requestsNumberTextField: UITextField!
    @IBOutlet weak var timeoutTextField: UITextField!
    
    var testApi = PMAPIService(doh: BlackDoH.default, sessionUID: "testSessionUID")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TrustKitWrapper.start(delegate: self)
        setupEnv()
    }
    
    func setupEnv() {
        testApi = PMAPIService(doh: environmentSelector.currentDoh, sessionUID: "testSessionUID")
        testApi.authDelegate = self
        testApi.serviceDelegate = self
    }
    
    struct GenericRequest: Request {
        var path: String
        var nonDefaultTimeout: TimeInterval?
        var isAuth: Bool
    }
    
    @IBAction func stressTestRefreshToken() {
        setupEnv()
        guard let username = username.text, let password = password.text,
              let requestsNumber = requestsNumberTextField.text, !username.isEmpty,
              !password.isEmpty, !requestsNumber.isEmpty, let iterations = Int(requestsNumber)
        else { return }
        
        final class StressTestAuthDelegate: AuthDelegate {
            var auth: Credential?
            let authenticator: Authenticator
            init(authenticator: Authenticator) { self.authenticator = authenticator }
            func getToken(bySessionUID uid: String) -> AuthCredential? {
                guard let credential = auth else { return nil }
                return AuthCredential(credential)
            }
            func onLogout(sessionUID uid: String) {
                assertionFailure("Should never be called")
                auth = nil
            }
            var wasUpdateCalled = false
            func onUpdate(auth newAuth: Credential) {
                if wasUpdateCalled {
                    assertionFailure("Update should be called only once")
                }
                wasUpdateCalled = true
                auth = newAuth
            }
            var wasRefreshCalled = false
            func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) {
                if wasRefreshCalled {
                    assertionFailure("Refresh should be called only once")
                }
                wasRefreshCalled = true
                guard let auth = auth else {
                    assertionFailure("Auth must be available")
                    return
                }
                
                authenticator.refreshCredential(auth) { result in
                    switch result {
                    case .success(let stage):
                        guard case Authenticator.Status.updatedCredential(let updatedCredential) = stage else {
                            return complete(nil, nil)
                        }
                        complete(updatedCredential, nil)
                    case .failure(let error):
                        complete(nil, error)
                    }
                }
            }
        }
        
        let authenticator = Authenticator(api: testApi)
        let delegate: StressTestAuthDelegate? = StressTestAuthDelegate(authenticator: authenticator)
        testApi.authDelegate = delegate

        authenticator.authenticate(username: username, password: password, challenge: nil) { [weak self] result in
            switch result {
            case .success(.newCredential(var credential, _)):
                credential.expiration = .distantPast
                delegate?.onUpdate(auth: credential)
                delegate?.wasUpdateCalled = false // because we don't consider this update relevant
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let group = DispatchGroup()
                    for _ in 0..<iterations {
                        group.enter()
                        DispatchQueue.global(qos: .userInitiated).async {
                            authenticator.getUserInfo { result in
                                guard delegate?.wasRefreshCalled == true, delegate?.wasUpdateCalled == true else {
                                    assertionFailure("The refresh and update have to be called once")
                                    return
                                }
                                group.leave()
                            }
                        }
                    }
                    group.wait()
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlertView(title: "Finished all \(iterations) iterations")
                    }
                }
                
            default:
                break
            }
        }
    }
    
    @IBAction func timeoutAction(_ sender: Any) {
        setupEnv()
        let timeout = TimeInterval(timeoutTextField.text ?? "") ?? 0.1
        
        let path = "/users/available?Name=" + "oneverystrangeusername".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let request = GenericRequest(path: path, nonDefaultTimeout: timeout, isAuth: false)
        testApi.exec(route: request, responseObject: Response()) { (response: Response) in
            let message = """
                    timeout: \(timeout)
                    
                    url: \(self.testApi.doh.getCurrentlyUsedHostUrl() + request.path)
                    """
            guard let error = response.error else {
                self.showAlertView(title: "request succeeded", message: message)
                return
            }
            self.showAlertView(title: "request failed with \"\(error.localizedDescription)\"", message: message)
        }
    }
    
    @IBAction func authAction(_ sender: Any) {
        setupEnv()
        guard let username = username.text, let password = password.text, !username.isEmpty, !password.isEmpty
        else { return }
        testFramework(userName: username, password: password)
    }
    
    @IBAction func forceUpgradeAction(_ sender: Any) {
        setupEnv()
        forceUpgrade()
    }
    
    @IBAction func humanVerificationAuthAction(_ sender: Any) {
        setupEnv()
        guard let username = username.text, let password = password.text, !username.isEmpty, !password.isEmpty
        else { return }
        humanVerification(userName: username, password: password)
    }
    
    @IBAction func humanVerificationUnauthAction(_ sender: Any) {
        setupEnv()
        self.humanVerification(version: .v2)
    }
    
    @IBAction func humanVerificationV3UnauthAction(_ sender: Any) {
        setupEnv()
        self.humanVerification(version: .v3)
    }
    
    /// simulate the cache of auth credential
    var testAuthCredential : AuthCredential? = nil
    
    func testFramework(userName: String, password: String) {
        setupHumanVerification(version: .v3)

        let authApi: Authenticator = Authenticator(api: testApi)
        authApi.authenticate(username: userName, password: password, challenge: nil) { result in
            switch result {
            case .failure(Authenticator.Errors.networkingError(let error)): // error response returned by server
                self.showAlertView(title: "Error", message: error.localizedDescription)
                print(error)
            case .failure(Authenticator.Errors.emptyServerSrpAuth):
                print("")
            case .failure(Authenticator.Errors.emptyClientSrpAuth):
                print("")
            case .failure(Authenticator.Errors.wrongServerProof):
                print("")
            case .failure(Authenticator.Errors.emptyAuthResponse):
                print("")
            case .failure(Authenticator.Errors.emptyAuthInfoResponse):
                print("")
            case .failure(_): // network or parsing error
                print("")
            case .success(.ask2FA(let context)): // success but need 2FA
                print(context)
            case .success(.newCredential(let credential, let passwordMode)): // success without 2FA
                self.testAuthCredential = AuthCredential(credential)
                print("pwd mode: \(passwordMode)")
                self.testAccessToken(userName: userName)
                self.showAlertView(title: "Success")
                break
            case .success(.updatedCredential):
                assert(false, "Should never happen in this flow")
            }
            print(result)
        }
    }
    
    func testAccessToken(userName: String) {
        let request = UserAPI.Router.checkUsername(userName)
        testApi.exec(route: request, responseObject: Response()) { (task, response) in
            print(response.responseCode as Any)
        }
        let request2 = UserAPI.Router.checkUsername("sflkjaslkfjaslkdjf")
        testApi.exec(route: request2, responseObject: Response()) { (task, response) in
            print(response.responseCode as Any)
        }
        let request3 = UserAPI.Router.userInfo
        testApi.exec(route: request3, responseObject: GetUserInfoResponse()) { (task, response: GetUserInfoResponse) in
            print(response.responseCode as Any)
        }
    }
    
    var humanVerificationDelegate: HumanVerifyDelegate?
    
    func setupHumanVerification(version: HumanVerificationVersion) {
        testAuthCredential = nil
        testApi.serviceDelegate = self
        testApi.authDelegate = self
        
        //set the human verification delegation
        let url = HVCommon.defaultSupportURL(clientApp: clientApp)
        humanVerificationDelegate = HumanCheckHelper(apiService: testApi, supportURL: url, viewController: self, clientApp: clientApp, versionToBeUsed: version, responseDelegate: self, paymentDelegate: self)
        testApi.humanDelegate = humanVerificationDelegate
    }
    
    func humanVerification(userName: String, password: String) {
        setupHumanVerification(version: .v2)

        let authApi: Authenticator = Authenticator(api: testApi)
        authApi.authenticate(username: userName, password: password, challenge: nil) { result in
            switch result {
            case .failure(Authenticator.Errors.networkingError(let error)): // error response returned by server
                self.showAlertView(title: "Error", message: error.localizedDescription)
                print(error)
            case .failure(Authenticator.Errors.emptyServerSrpAuth):
                print("")
            case .failure(Authenticator.Errors.emptyClientSrpAuth):
                print("")
            case .failure(Authenticator.Errors.wrongServerProof):
                print("")
            case .failure(Authenticator.Errors.emptyAuthResponse):
                print("")
            case .failure(Authenticator.Errors.emptyAuthInfoResponse):
                print("")
            case .failure(_): // network or parsing error
                print("")
            case .success(.ask2FA(let context)): // success but need 2FA
                print(context)
            case .success(.newCredential(let credential, let passwordMode)): // success without 2FA
                self.testAuthCredential = AuthCredential(credential)
                print("pwd mode: \(passwordMode)")
                self.processHumanVerifyTest()
                break
            case .success(.updatedCredential):
                assert(false, "Should never happen in this flow")
            }
            print(result)
        }
    }
    
    func humanVerification(version: HumanVerificationVersion) {
        setupHumanVerification(version: version)
        processHumanVerifyTest()
    }
    
    func processHumanVerifyTest() {
        // Human Verify request with empty token just to provoke human verification error
        let client = TestApiClient(api: self.testApi)
        client.triggerHumanVerify(isAuth: getToken(bySessionUID: "") != nil) { (_, response) in
            print("Human verify test result: \(response.error?.localizedDescription as Any)")
        }
    }
    
    var forceUpgradeServiceDelegate: APIServiceDelegate?
    var forceUpgradeDelegate: ForceUpgradeDelegate?
    
    func forceUpgrade() {
        forceUpgradeServiceDelegate = {
            class TestDelegate: APIServiceDelegate {
                var locale: String = Locale.autoupdatingCurrent.identifier
                var additionalHeaders: [String: String]?
                var userAgent: String? = ""
                func onUpdate(serverTime: Int64) {}
                func isReachable() -> Bool { return true }
                var appVersion: String = "iOS_0.0.1"
                func onDohTroubleshot() {}
            }
            return TestDelegate()
        }()
        
        testApi.serviceDelegate = forceUpgradeServiceDelegate
        
        let url = URL(string: "itms-apps://itunes.apple.com/app/id979659905")!
        forceUpgradeDelegate = ForceUpgradeHelper(config: .mobile(url), responseDelegate: self)
        testApi.forceUpgradeDelegate = forceUpgradeDelegate
        
        // TODO: update to a PMAuthentication version that depends on PMNetworking
        let authApi: Authenticator = Authenticator(api: testApi)
        authApi.authenticate(username: "test", password: "test", challenge: nil) { result in
            print (result)
        }
    }
    
    @IBAction func dohUIAction(_ sender: Any) {
        let coordinator = NetworkingTroubleShootCoordinator(
            nav: self.navigationController!, services: ServiceFactory.default
        )
        coordinator.start()
    }
}

extension NetworkingViewController : AuthDelegate {
    
    func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) { }
    
    func getToken(bySessionUID uid: String) -> AuthCredential? {
        print("looking for auth UID: " + uid)
        print("compare cache with index: \(uid == testAuthCredential?.sessionID ?? "") ")
        return self.testAuthCredential
    }
    
    func onUpdate(auth: Credential) { }
    
    func onLogout(sessionUID uid: String) { }
    
    func onForceUpgrade() { }
}


extension NetworkingViewController : APIServiceDelegate {
    
    var additionalHeaders: [String: String]? { ["x-pm-core-ios-tests": "Testing header, please ignore"] }
    
    var locale: String { Locale.autoupdatingCurrent.identifier }
    
    var userAgent: String? { return "" }
    
    func isReachable() -> Bool { true }
    
    var appVersion: String { appVersionHeader.getVersionHeader() }
    
    func onUpdate(serverTime: Int64) { }
    
    func onDohTroubleshot() { }
}

extension NetworkingViewController: TrustKitUIDelegate {
    func onTrustKitValidationError(_ alert: UIAlertController) { }
}

extension NetworkingViewController: ForceUpgradeResponseDelegate {
    func onQuitButtonPressed() { }
    
    func onUpdateButtonPressed() { }
}

extension NetworkingViewController: HumanVerifyPaymentDelegate {
    func paymentTokenStatusChanged(status: PaymentTokenStatusResult) {
        print("Payment token status: \(status)")
    }
    
    var paymentToken: String? {
        return nil
    }
}

extension NetworkingViewController: HumanVerifyResponseDelegate {
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
    
    func humanVerifyToken(token: String?, tokenType: String?) {
        print("Human verify token: \(String(describing: token)), type: \(String(describing: tokenType))")
    }
}

extension NetworkingViewController {
    
    func showAlertView(title: String, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
