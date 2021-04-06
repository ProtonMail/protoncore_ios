//
//  NewUserSubscriptionVC.swift
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

class NewUserSubscriptionVC: BaseUIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: ProtonButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var subscriptionSelector: UISegmentedControl!
    @IBOutlet weak var currentSubscriptionButton: ProtonButton!
    @IBOutlet weak var currentSubscriptionLabel: UILabel!
    @IBOutlet weak var currentTimePeriodLabel: UILabel!
    @IBOutlet weak var currentAddonLabel: UILabel!
    @IBOutlet weak var currentCreditLabel: UILabel!
    @IBOutlet weak var subscriptionToPurchaseLabel: UILabel!
    @IBOutlet weak var forceSubscriptionButton: UISwitch!
    @IBOutlet weak var purchaseSubscriptionButton: ProtonButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scrollBottomPaddingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var currentEnv: (DoH & ServerConfig)!
    var accountPlans: [AccountPlan]!
    var selectedAccountPlanIndex = 0
    
    // MARK: - Auth properties
    private var testApi: PMAPIService!
    private var authCredential: AuthCredential?
    private var userInfo: UserInfo?
    
    // MARK: - Payment credentials
    private let storeKitManager = StoreKitManager.default
    private var userCachedStatus: UserCachedStatus!
    private var servicePlan: ServicePlanDataService!
    private var paymentToken: PaymentToken?
    
    // MARK: - Payment data
    private var isValid = false { didSet { self.showVerify() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PMAPIService.noTrustKit = true
        testApi = PMAPIService(doh: currentEnv, sessionUID: "testSessionUID")
        loginButton.isEnabled = true
        currentSubscriptionButton.isEnabled = false
        purchaseSubscriptionButton.isEnabled = false
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    
        subscriptionSelector.removeAllSegments()
        for (index, plan) in accountPlans.enumerated() {
            subscriptionSelector.insertSegment(withTitle: plan.rawValue, at: index, animated: false)
        }
        subscriptionSelector.selectedSegmentIndex = 0
        selectedAccountPlanIndex = 0

        storeKitSetup()
    }
    
    @IBAction func onLoginButtonTap(_ sender: Any) {
        login()
    }
    
    @IBAction func onCurrentSurscriptionButtonTap(_ sender: Any) {
        selectedAccountPlanIndex = subscriptionSelector.selectedSegmentIndex
        currentSubscription()
    }
    
    @IBAction func onPurchaseSubscriptionButtonTap(_ sender: ProtonButton) {
        self.buyPlan()
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    private func storeKitSetup() {
        // setup StoreKitManager
        userCachedStatus = UserCachedStatus(updateSubscriptionBlock: { newSubscription in
            DispatchQueue.main.async {
                self.showSubscriptionData()
            }
        }, updateCreditsBlock: { credits in
            DispatchQueue.main.async {
                self.showCreditsData(credits: credits)
            }
        })
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
    }
    
    private func login() {
        dismissKeyboard()
        loginStatusLabel.text = "Login status:"
        currentSubscriptionButton.isEnabled = false
        purchaseSubscriptionButton.isEnabled = false
        
        guard let username = usernameTextField.text, username != "", let password = passwordTextField.text, password != "" else {
            loginStatusLabel.text = "Login status: Wrong credentials"
            return
        }
        testApi.authDelegate = self
        currentEnv.status = .off
        let authApi = Authenticator(api: testApi)
        loginButton.isSelected = true
        authApi.authenticate(username: username, password: password) { result in
            self.loginButton.isSelected = false
            switch result {
            case .success(.newCredential(let credential, _)):
                self.authCredential = AuthCredential(credential)
                let request = UserAPI.Router.userInfo
                self.apiService?.exec(route: request) { (task, response: GetUserInfoResponse) in
                    self.userInfo = response.userInfo
                    self.loginStatusLabel.text = "Login status: OK"
                    self.currentSubscriptionButton.isEnabled = true
                    self.setupStoreKit()
                    self.clearData()
                }
            case .failure(Authenticator.Errors.networkingError(let error)):
                self.loginStatusLabel.text = "Login status: \(error.localizedDescription)"
                PMLog.debug("Error: \(result)")
            case .failure(_):
                self.loginStatusLabel.text = "Login status: Not OK"
            case .success(.ask2FA((_, _))):
                self.loginStatusLabel.text = "Login status: Not supportd 2FA"
                break
            case .success(.updatedCredential(_)):
                break
                // should not happen
            }
        }
    }
    
    private func setupStoreKit() {
        storeKitManager.delegate = self
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.updateAvailableProductsList()
    }
    
    private func clearData() {
        currentSubscriptionLabel.text = "Current subscriptions:"
        currentTimePeriodLabel.text = "Current time period:"
        currentAddonLabel.text = "Current addons:"
        currentCreditLabel.text = "Current credit:"
        subscriptionToPurchaseLabel.text = "Subscription to purchase:"
        statusLabel.text = "Status:"
        purchaseSubscriptionButton.setTitle("Purchase subscription / add credits", for: .normal)
        purchaseSubscriptionButton.isEnabled = false
    }
    
    private func currentSubscription() {
        currentSubscriptionButton.isSelected = true
        clearData()
        verifyPurchase { isValid in
            self.isValid = isValid
            self.currentSubscriptionButton.isSelected = false
        }
    }
    
    private func showSubscriptionData() {
        let planNames = servicePlan.currentSubscription?.planDetails?.filter { $0.type == 1 }.compactMap { $0.name } ?? [AccountPlan.free.rawValue]
        let plansStr = planNames.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let addonNames = servicePlan.currentSubscription?.planDetails?.filter { $0.type == 0 }.compactMap { $0.name }
        let addonsStr = addonNames?.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        var addonsDispStr = addonsStr ?? "---"
        if addonsDispStr == "" {
            addonsDispStr = "---"
        }
        var cycle = "---"
        if let servicePlanCycle = servicePlan.currentSubscription?.cycle, servicePlanCycle > 0 {
            cycle = String(servicePlanCycle) + " month(s)"
        }
        currentSubscriptionLabel.text = "Current subscriptions: \(plansStr)"
        currentAddonLabel.text = "Current addons: \(addonsDispStr)"
        currentTimePeriodLabel.text = "Current time period: \(cycle)"
    }
    
    private func showCreditsData(credits: Credits?) {
        var creditStr = "---"
        if let credits = credits {
            creditStr = "\(credits.credit) \(credits.currency)"
        }
        currentCreditLabel.text = "Current credit: \(creditStr)"
    }
    
    private func verifyPurchase(completion: @escaping (Bool) -> Void) {
        let productId = accountPlans[selectedAccountPlanIndex].storeKitProductId!
        storeKitManager.isValidPurchase(identifier: productId) { isValid in
            completion(isValid)
        }
    }
    
    private func showVerify() {
        self.purchaseSubscriptionButton.isEnabled = isValid || self.forceSubscriptionButton.isOn
        if self.isValid || self.forceSubscriptionButton.isOn {
            var title = "Purchase subscription"
            if self.isValid {
                if self.servicePlan.currentSubscription?.planDetails != nil {
                    title = "Add credits"
                }
            } else {
                title = "Force purchase subscription"
            }
            self.purchaseSubscriptionButton.setTitle(title, for: .normal)
            self.subscriptionToPurchaseLabel.text = "Subscription to purchase: \(accountPlans[selectedAccountPlanIndex].rawValue)"
        } else {
            self.subscriptionToPurchaseLabel.text = "Subscription to purchase: ---"
        }
    }
    
    private func buyPlan() {
        self.statusLabel.text = "Status:"
        guard storeKitManager.isReadyToPurchaseProduct() else {
            self.statusLabel.text = "Status: Not ready to purchase"
            PMLog.debug("StoreKitManager is not ready to purchase")
            return
        }
        purchaseSubscriptionButton.isSelected = true
        let productId = accountPlans[selectedAccountPlanIndex].storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { paymentToken in
            DispatchQueue.main.async {
                self.purchaseSubscriptionButton.isSelected = false
                self.paymentToken = paymentToken
                self.statusLabel.text = "Status: Success"
                PMLog.debug("Purchace success")
                self.verifyPurchase { isValid in
                    self.isValid = isValid
                }
            }
        } errorCompletion: { error in
            DispatchQueue.main.async {
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: \(error.localizedDescription)"
                PMLog.debug(error.localizedDescription)
            }
        }
    }
    
    private func dismissKeyboard() {
        _ = usernameTextField.resignFirstResponder()
        _ = passwordTextField.resignFirstResponder()
    }
}

extension NewUserSubscriptionVC: AuthDelegate {
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

extension NewUserSubscriptionVC {
    class UserCachedStatus: ServicePlanDataStorage {
        var updateSubscriptionBlock: ((ServicePlanSubscription?) -> Void)?
        var updateCreditsBlock: ((Credits?) -> Void)?
        
        init(updateSubscriptionBlock: ((ServicePlanSubscription?) -> Void)? = nil, updateCreditsBlock: ((Credits?) -> Void)? = nil) {
            self.updateSubscriptionBlock = updateSubscriptionBlock
            self.updateCreditsBlock = updateCreditsBlock
        }

        var servicePlansDetails: [ServicePlanDetails]? {
            get {
                guard let data = Storage.userDefaults().data(forKey: "servicePlansDetails") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(Array<ServicePlanDetails>.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                Storage.setValue(data, forKey: "servicePlansDetails")
            }
        }
        
        var defaultPlanDetails: ServicePlanDetails? {
            get {
                guard let data = Storage.userDefaults().data(forKey: "defaultPlanDetails") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(ServicePlanDetails.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                Storage.setValue(data, forKey: "defaultPlanDetails")
            }
        }
        
        var currentSubscription: ServicePlanSubscription? {
            get {
                guard let data = Storage.userDefaults().data(forKey: "currentSubscription") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(ServicePlanSubscription.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                Storage.setValue(data, forKey: "currentSubscription")
                self.updateSubscriptionBlock?(newValue)
            }
        }
        
        var isIAPUpgradePlanAvailable: Bool {
            get {
                return Storage.userDefaults().bool(forKey: "isIAPUpgradePlanAvailable")
            }
            set {
                Storage.setValue(newValue, forKey: "isIAPUpgradePlanAvailable")
            }
        }

        var credits: Credits? {
            didSet {
                self.updateCreditsBlock?(credits)
            }
        }
    }
}

extension NewUserSubscriptionVC: StoreKitManagerDelegate {
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
        return usernameTextField.text
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

extension NewUserSubscriptionVC {
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

// MARK: - PMTextFieldDelegate

extension NewUserSubscriptionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}

#endif
