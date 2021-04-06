//
//  RegistrationSubscriptionVC.swift
//  ExampleMailApp - Created on 11/12/2020.
//
//
//  Copyright (c) 2020 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

#if canImport(UIKit)
import UIKit
import ProtonCore_APIClient
import ProtonCore_HumanVerification
import ProtonCore_Doh
import ProtonCore_Services
import ProtonCore_Authentication
import ProtonCore_Log
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_UIFoundations
import ProtonCore_Payments
import TrustKit

class RegistrationSubscriptionVC: BaseUIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var subscriptionSelector: UISegmentedControl!
    @IBOutlet weak var purchaseSubscriptionButton: ProtonButton!
    @IBOutlet weak var statusAfterSignLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var humanVerificationButton: ProtonButton!
    @IBOutlet weak var humanVerificationResultLabel: UILabel!
    @IBOutlet weak var loginButton: ProtonButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var currentSubscriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scrollBottomPaddingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var currentEnv: (DoH & ServerConfig)!
    var accountPlans: [AccountPlan]!
    var selectedAccountPlanIndex = 0
    
    // MARK: - Private auth properties
    private var testApi: PMAPIService!
    private var authCredential: AuthCredential?
    private var userInfo: UserInfo?
    
    // MARK: - Private payment credentials
    private let storeKitManager = StoreKitManager.default
    private var userCachedStatus: UserCachedStatus!
    private var servicePlan: ServicePlanDataService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PMAPIService.noTrustKit = true
        testApi = PMAPIService(doh: currentEnv, sessionUID: "testSessionUID")

        userCachedStatus = UserCachedStatus()
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        NotificationCenter.default.addObserver( self, selector: #selector(finish), name: StoreKitManager.transactionFinishedNotification, object: nil)
        setupStoreKit()
        loginButton.isEnabled = false
        humanVerificationButton.isEnabled = false
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        subscriptionSelector.removeAllSegments()
        for (index, plan) in accountPlans.enumerated() {
            subscriptionSelector.insertSegment(withTitle: plan.rawValue, at: index, animated: false)
        }
        subscriptionSelector.selectedSegmentIndex = 0
        selectedAccountPlanIndex = 0
    }
    
    private func setupStoreKit() {
        storeKitManager.delegate = self
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.updateAvailableProductsList()
    }
    
    @IBAction func onPurchaseSubscriptionButtonTap(_ sender: Any) {
        selectedAccountPlanIndex = subscriptionSelector.selectedSegmentIndex
        buyPlan()
    }
    
    @IBAction func onLoginButtonTap(_ sender: Any) {
        login()
    }
    
    @IBAction func onHumanVerificationButtonTap(_ sender: ProtonButton) {
        humanVerification()
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    private func buyPlan() {
        // STEP 1: buy plan and store payment token
        testApi.authDelegate = self
        self.statusLabel.text = "Status:"
        let productId = accountPlans[selectedAccountPlanIndex].storeKitProductId!
        purchaseSubscriptionButton.isSelected = true
        storeKitManager.purchaseProduct(identifier: productId) { paymentToken in
            DispatchQueue.main.async {
                self.purchaseSubscriptionButton.isSelected = false
                if paymentToken != nil {
                    self.statusLabel.text = "Status: PaymentToken received"
                    self.humanVerificationButton.isEnabled = true
                } else {
                    self.statusLabel.text = "Status: PaymentToken is empty"
                    self.humanVerificationButton.isEnabled = false
                }
                PMLog.debug("Status: PaymentToken received")
                self.loginButton.isEnabled = true
                self.purchaseSubscriptionButton.isEnabled = false
            }
        } errorCompletion: { error in
            DispatchQueue.main.async {
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: \(error.localizedDescription)"
                PMLog.debug(error.localizedDescription)
            }
        }
    }

    private func login() {
        // STEP 2: login
        dismissKeyboard()
        guard let username = usernameTextField.text, username != "", let password = passwordTextField.text, password != "" else {
            self.loginStatusLabel.text = "Login status: Wrong credentials"
            return
        }
        currentEnv.status = .off
        let authApi = Authenticator(api: testApi)
        loginButton.isSelected = true
        authApi.authenticate(username: username, password: password) { result in
            switch result {
            case .success(.newCredential(let credential, _)):
                self.authCredential = AuthCredential(credential)
                self.loginStatusLabel.text = "Login status: OK"
                self.userInfoAndUpdatePlans()
            case .failure(Authenticator.Errors.networkingError(let error)):
                self.loginButton.isSelected = false
                self.loginStatusLabel.text = "Login status: \(error.localizedDescription)"
                PMLog.debug("Error: \(result)")
            case .failure(_):
                self.loginButton.isSelected = false
                self.loginStatusLabel.text = "Login status: Not OK"
            case .success(.ask2FA((_, _))):
                self.loginButton.isSelected = false
                self.loginStatusLabel.text = "Login status: Not supportd 2FA"
                break
            case .success(.updatedCredential(_)):
                self.loginButton.isSelected = false
                break
                // should not happen
            }
        }
    }
    
    private func userInfoAndUpdatePlans() {
        // STEP 3: Get user info and current plan
        let request = UserAPI.Router.userInfo
        self.apiService?.exec(route: request) { (task, response: GetUserInfoResponse) in
            self.userInfo = response.userInfo
            self.servicePlan.updateServicePlans {
                if self.servicePlan.isIAPAvailable {
                    self.servicePlan.updateCurrentSubscription {
                        let planNames = self.servicePlan.currentSubscription?.planDetails?.filter { $0.type == 1 }.compactMap { $0.name } ?? [AccountPlan.free.rawValue]
                        let plansStr = planNames.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                        self.currentSubscriptionLabel.text = "Current subscriptions: \(plansStr)"
                        self.contunuePurchase()
                    } failure: { error in
                        PMLog.debug(error.localizedDescription)
                    }
                }
            } failure: { error in
                self.loginButton.isSelected = false
                PMLog.debug(error.localizedDescription)
            }
        }
    }

    private func contunuePurchase() {
        // STEP 4: Continue purchase
        self.storeKitManager.continueRegistrationPurchase() {
            DispatchQueue.main.async {
                self.loginButton.isSelected = false
                self.statusAfterSignLabel.text = "Subscription status: Success"
                PMLog.debug("Subscription Success")
                self.loginButton.isEnabled = false
                let planNames = self.servicePlan.currentSubscription?.planDetails?.filter { $0.type == 1 }.compactMap { $0.name } ?? [AccountPlan.free.rawValue]
                let plansStr = planNames.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                self.currentSubscriptionLabel.text = "Current subscriptions: \(plansStr)"
            }
        }
    }
        
    @objc private func finish() {
        PMLog.debug("Subscription Success notification")
    }
    
    private func humanVerification() {
        setupHumanVerification()
        processHumanVerifyTest()
    }
    
    var humanVerificationDelegate: HumanVerifyDelegate?
    
    private func setupHumanVerification() {
        currentEnv.status = .off
        testApi.serviceDelegate = self
        testApi.authDelegate = self

        //set the human verification delegation
        let url = URL(string: "https://protonmail.com/support/knowledge-base/human-verification/")!
        humanVerificationDelegate = HumanCheckHelper(apiService: testApi, supportURL: url, viewController: self, responseDelegate: self, paymentDelegate: self)
        testApi.humanDelegate = humanVerificationDelegate
    }
    
    private func processHumanVerifyTest() {
        // Human Verify request with empty token just to provoke human verification error
        let client = TestApiClient(api: self.testApi)
        humanVerificationButton.isSelected = true
        client.triggerHumanVerify(isAuth: false) { (_, response) in
            self.humanVerificationButton.isSelected = false
            if let error = response.error {
                self.humanVerificationResultLabel.text = "HV result: Code=\(error.responseCode) \(error.localizedDescription)"
            } else {
                self.humanVerificationResultLabel.text = "HV result: SUCCESS"
            }
        }
    }

    private func dismissKeyboard() {
        _ = usernameTextField.resignFirstResponder()
        _ = passwordTextField.resignFirstResponder()
    }
}

extension RegistrationSubscriptionVC: AuthDelegate {
    func getToken(bySessionUID uid: String) -> AuthCredential? {
        return authCredential
    }
    
    func onLogout(sessionUID uid: String) {
    }
    
    func onUpdate(auth: Credential) {
    }
    
    func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) {
    }
    
    func onForceUpgrade() {
    }
}

extension RegistrationSubscriptionVC: StoreKitManagerDelegate {
    var apiService: APIService? {
        return testApi
    }
    
    var tokenStorage: PaymentTokenStorage? {
        return TokenStorage.default
    }
    
    var isUnlocked: Bool {
        return true
    }
    
    var isSignedIn: Bool {
        return true
    }
    
    var activeUsername: String? {
        return nil
    }
    
    var userId: String? {
        return userInfo?.userId
    }
    
    var servicePlanDataService: ServicePlanDataService? {
        return servicePlan
    }
    
    func reportBugAlert() {
        let alert = UIAlertController(title: "Report Bug Example", message: "Example", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RegistrationSubscriptionVC {
    
    class TokenStorage: PaymentTokenStorage {
        public static var `default` = TokenStorage()
        var token: PaymentToken?
        
        func add(_ token: PaymentToken) {
            self.token = token
        }
        
        func get() -> PaymentToken? {
            return token
        }
        
        func clear() {
            self.token = nil
        }
    }
}

extension RegistrationSubscriptionVC {
    
    class UserCachedStatus: ServicePlanDataStorage {
        var updateBlock: ((ServicePlanSubscription?) -> Void)?
        
        init(updateBlock: ((ServicePlanSubscription?) -> Void)? = nil) {
            self.updateBlock = updateBlock
        }

        var servicePlansDetails: [ServicePlanDetails]? {
            get {
                guard let data = Storage.userDefaults().data(forKey: "servicePlansDetailsReg") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(Array<ServicePlanDetails>.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                Storage.setValue(data, forKey: "servicePlansDetailsReg")
            }
        }
        
        var defaultPlanDetails: ServicePlanDetails? {
            get {
                guard let data = Storage.userDefaults().data(forKey: "defaultPlanDetailsReg") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(ServicePlanDetails.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                Storage.setValue(data, forKey: "defaultPlanDetailsReg")
            }
        }
        
        var currentSubscription: ServicePlanSubscription? {
            get {
                guard let data = Storage.userDefaults().data(forKey: "currentSubscriptionReg") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(ServicePlanSubscription.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                Storage.setValue(data, forKey: "currentSubscriptionReg")
                self.updateBlock?(newValue)
            }
        }
        
        var isIAPUpgradePlanAvailable: Bool {
            get {
                return Storage.userDefaults().bool(forKey: "isIAPUpgradePlanAvailableReg")
            }
            set {
                Storage.setValue(newValue, forKey: "isIAPUpgradePlanAvailableReg")
            }
        }

        var credits: Credits?
    }
}

// MARK: - HumanVerifyResponseDelegate

extension RegistrationSubscriptionVC: APIServiceDelegate {
    var locale: String {
         return "en_US"
     }
    
    var userAgent: String? {
        return "" //need to be set
    }
    
    func isReachable() -> Bool {
        return true
    }
    
    
    var appVersion: String {
        return "iOS_\(Bundle.main.majorVersion)"
    }
    
    func onChallenge(challenge: URLAuthenticationChallenge, credential: AutoreleasingUnsafeMutablePointer<URLCredential?>?) -> URLSession.AuthChallengeDisposition {

        let dispositionToReturn: URLSession.AuthChallengeDisposition = .performDefaultHandling
        return dispositionToReturn
    }
    
    func onUpdate(serverTime: Int64) {
        // on update the server time for user.
    }
    
    func onChallenge() {
        // on cert pinning challenge
    }
    
    func onDohTroubleshot() {
        // show up Doh Troubleshot view
    }
}


// MARK: - HumanVerifyResponseDelegate

extension RegistrationSubscriptionVC: HumanVerifyResponseDelegate {
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

extension RegistrationSubscriptionVC: HumanVerifyPaymentDelegate {
    var paymentToken: String? {
        return TokenStorage.default.get()?.token
    }
    
    func paymentTokenStatusChanged(status: PaymentTokenStatusResult) {
        print("Human verification token status changed to: \(status)")
    }
}

// MARK: - PMTextFieldDelegate

extension RegistrationSubscriptionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}

#endif
