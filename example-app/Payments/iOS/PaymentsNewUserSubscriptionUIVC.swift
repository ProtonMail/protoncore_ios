//
//  PaymentsNewUserSubscriptionUIVC.swift
//  Example-Payments - Created on 11/12/2020.
//
//
//  Copyright (c) 2020 Proton Technologies AG
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

#if canImport(UIKit)
import UIKit
import ProtonCore_HumanVerification
import ProtonCore_Doh
import ProtonCore_Services
import ProtonCore_Authentication
import ProtonCore_Log
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_UIFoundations
import ProtonCore_Payments
import ProtonCore_PaymentsUI
import ProtonCore_Foundations

class PaymentsNewUserSubscriptionUIVC: PaymentsBaseUIViewController, AccessibleView {
    
    // MARK: - Outlets
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: ProtonButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var backendFetchSwitch: UISwitch!
    @IBOutlet weak var modalVCSwitch: UISwitch!
    @IBOutlet weak var showCurrentPlanButton: ProtonButton!
    @IBOutlet weak var showUpdatePlansButton: ProtonButton!
    
    // MARK: - Payment credentials
    private var payments: Payments!
    private var userCachedStatus: UserCachedStatus!
    
    // MARK: - Properties
    var currentEnv: (DoH & ServerConfig)!
    var inAppPurchases: ListOfIAPIdentifiers!
    var serviceDelegate: APIServiceDelegate!
    var usePathsWithoutV4Prefix: Bool = false
    var updateCredits: Bool?

    var testPicker: PaymentsTestUserPickerData?

    private var paymentsUI: PaymentsUI?
    
    // MARK: - Auth properties
    private var testApi: PMAPIService!
    private var authCredential: Credential?
    private var userInfo: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PMAPIService.noTrustKit = true
        testApi = PMAPIService(doh: currentEnv, sessionUID: "testSessionUID")
        testApi.serviceDelegate = serviceDelegate
        loginButton.isEnabled = true
        showCurrentPlanButton.isEnabled = false
        showUpdatePlansButton.isEnabled = false
        storeKitSetup()
        testPicker?.setup(picker: picker) { [weak self] user in
            self?.usernameTextField.text = user?.0 ?? ""
            self?.passwordTextField.text = user?.1 ?? ""
        }
        generateAccessibilityIdentifiers()
    }
    
    @IBAction func onLoginButtonTap(_ sender: Any) {
        login()
    }
    
    @IBAction func onShowCurrentPlanButtonTap(_ sender: Any) {
        showCurrentPlanButton.isSelected = true
        paymentsUI?.showCurrentPlan(presentationType: modalVCSwitch.isOn ? .modal : .none, backendFetch: backendFetchSwitch.isOn, updateCredits: updateCredits ?? false, completionHandler: { [unowned self] result in
            switch result {
            case .open(let vc, let opened):
                self.showCurrentPlanButton.isSelected = false
                if !opened {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .purchasedPlan(let plan):
                print("Selected plan: \(plan)")
            default:
                break
            }
        })
    }
    
    @IBAction func onShowUpdatePlansButtonTap(_ sender: Any) {
        showUpdatePlansButton.isSelected = true
        paymentsUI?.showUpgradePlan(presentationType: modalVCSwitch.isOn ? .modal : .none, backendFetch: backendFetchSwitch.isOn, updateCredits: updateCredits ?? false, completionHandler: { [unowned self] result in
            switch result {
            case .open(let vc, let opened):
                self.showUpdatePlansButton.isSelected = false
                if !opened {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .purchasedPlan(let plan):
                print("Selected plan: \(plan)")
            default:
                break
            }
        })
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    private func storeKitSetup() {
        userCachedStatus = UserCachedStatus()
        payments = Payments(inAppPurchaseIdentifiers: inAppPurchases,
                            apiService: testApi,
                            localStorage: userCachedStatus,
                            usePathsWithoutV4Prefix: usePathsWithoutV4Prefix)
        paymentsUI = PaymentsUI(payments: payments)
    }
    
    private func login() {
        dismissKeyboard()
        loginStatusLabel.text = "Login status:"
        showCurrentPlanButton.isEnabled = false
        showUpdatePlansButton.isEnabled = false
        guard let username = usernameTextField.text, username != "", let password = passwordTextField.text, password != "" else {
            loginStatusLabel.text = "Login status: Wrong credentials"
            return
        }
        testApi.authDelegate = self
        testApi.serviceDelegate = onlyForAuthServiceDelegate
        currentEnv.status = .off
        let authApi = Authenticator(api: testApi)
        loginButton.isSelected = true
        authApi.authenticate(username: username, password: password) { [unowned self] result in
            switch result {
            case .success(.newCredential(let credential, _)):
                let actualCredential = credential
                self.authCredential = actualCredential
                authApi.getUserInfo(actualCredential) { [unowned self] (result: Result<User, AuthErrors>) in
                    self.testApi.serviceDelegate = self.serviceDelegate
                    switch result {
                    case .success(let user):
                        self.setupStoreKit { [unowned self] error in
                            self.loginButton.isSelected = false
                            guard error == nil else {
                                self.loginStatusLabel.text = "Login status: \(error!.messageForTheUser)"
                                self.showCurrentPlanButton.isEnabled = false
                                self.showUpdatePlansButton.isEnabled = false
                                self.userInfo = nil
                                PMLog.debug("Error: \(result)")
                                return
                            }
                            self.userInfo = user
                            self.loginStatusLabel.text = "Login status: OK"
                            self.showCurrentPlanButton.isEnabled = true
                            self.showUpdatePlansButton.isEnabled = true
                        }
                    case .failure(let error):
                        self.loginButton.isSelected = false
                        self.loginStatusLabel.text = "Login status: \(error.messageForTheUser)"
                        self.showCurrentPlanButton.isEnabled = false
                        self.showUpdatePlansButton.isEnabled = false
                        self.userInfo = nil
                        PMLog.debug("Error: \(result)")
                    }
                }
            case .failure(Authenticator.Errors.networkingError(let error)):
                self.loginStatusLabel.text = "Login status: \(error.messageForTheUser)"
                self.loginButton.isSelected = false
                PMLog.debug("Error: \(result)")
            case .failure(_):
                self.loginStatusLabel.text = "Login status: Not OK"
                self.loginButton.isSelected = false
            case .success(.ask2FA((_, _))):
                self.loginStatusLabel.text = "Login status: Not supportd 2FA"
                self.loginButton.isSelected = false
                break
            case .success(.updatedCredential(_)):
                self.loginButton.isSelected = false
                break
                // should not happen
            }
        }
    }
    
    private func setupStoreKit(completion: @escaping (Error?) -> Void) {
        payments.storeKitManager.delegate = self
        payments.storeKitManager.subscribeToPaymentQueue()
        payments.storeKitManager.updateAvailableProductsList(completion: completion)
    }
    
    private func dismissKeyboard() {
        _ = usernameTextField.resignFirstResponder()
        _ = passwordTextField.resignFirstResponder()
    }
}

extension PaymentsNewUserSubscriptionUIVC: StoreKitManagerDelegate {
    
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
        return userInfo?.ID
    }
    
    func reportBugAlert() {
        let alert = UIAlertController(title: "Report Bug Example", message: "Example", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PaymentsNewUserSubscriptionUIVC {
    
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

extension PaymentsNewUserSubscriptionUIVC: AuthDelegate {
    func getToken(bySessionUID uid: String) -> AuthCredential? {
        return authCredential.map(AuthCredential.init)
    }
    
    func onLogout(sessionUID uid: String) {
        self.authCredential = nil
    }
    
    func onUpdate(auth: Credential) {
        self.authCredential = auth
    }
    
    func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) {
    }
    
    func onForceUpgrade() {
    }
}

extension PaymentsNewUserSubscriptionUIVC {
    class UserCachedStatus: ServicePlanDataStorage {
        var updateSubscriptionBlock: ((Subscription?) -> Void)?
        var updateCreditsBlock: ((Credits?) -> Void)?
        
        init(updateSubscriptionBlock: ((Subscription?) -> Void)? = nil, updateCreditsBlock: ((Credits?) -> Void)? = nil) {
            self.updateSubscriptionBlock = updateSubscriptionBlock
            self.updateCreditsBlock = updateCreditsBlock
        }

        var servicePlansDetails: [Plan]? {
            get {
                guard let data = PaymentsStorage.userDefaults().data(forKey: "servicePlansDetails") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(Array<Plan>.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                PaymentsStorage.setValue(data, forKey: "servicePlansDetails")
            }
        }
        
        var defaultPlanDetails: Plan? {
            get {
                guard let data = PaymentsStorage.userDefaults().data(forKey: "defaultPlanDetails") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(Plan.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                PaymentsStorage.setValue(data, forKey: "defaultPlanDetails")
            }
        }
        
        var currentSubscription: Subscription? {
            get {
                guard let data = PaymentsStorage.userDefaults().data(forKey: "currentSubscription") else {
                    return nil
                }
                return try? PropertyListDecoder().decode(Subscription.self, from: data)
            }
            set {
                let data = try? PropertyListEncoder().encode(newValue)
                PaymentsStorage.setValue(data, forKey: "currentSubscription")
                self.updateSubscriptionBlock?(newValue)
            }
        }
        
        var isIAPUpgradePlanAvailable: Bool {
            get {
                return PaymentsStorage.userDefaults().bool(forKey: "isIAPUpgradePlanAvailable")
            }
            set {
                PaymentsStorage.setValue(newValue, forKey: "isIAPUpgradePlanAvailable")
            }
        }

        var credits: Credits? {
            didSet {
                self.updateCreditsBlock?(credits)
            }
        }
    }
}
// MARK: - PMTextFieldDelegate

extension PaymentsNewUserSubscriptionUIVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}

#endif
