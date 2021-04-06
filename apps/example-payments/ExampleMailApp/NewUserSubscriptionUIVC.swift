//
//  NewUserSubscriptionUIVC.swift
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
import ProtonCore_PaymentsUI

class NewUserSubscriptionUIVC: BaseUIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: ProtonButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var backendFetchSwitch: UISwitch!
    @IBOutlet weak var modalVCSwitch: UISwitch!
    @IBOutlet weak var showCurrentPlanButton: ProtonButton!
    @IBOutlet weak var showUpdatePlansButton: ProtonButton!
    
    // MARK: - Payment credentials
    private let storeKitManager = StoreKitManager.default
    private var userCachedStatus: UserCachedStatus!
    
    // MARK: - Properties
    var currentEnv: (DoH & ServerConfig)!
    var planTypes: PlanTypes!
    
    private var paymentsUI: PaymentsUI?
    private var servicePlan: ServicePlanDataService!
    
    // MARK: - Auth properties
    private var testApi: PMAPIService!
    private var authCredential: AuthCredential?
    private var userInfo: UserInfo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PMAPIService.noTrustKit = true
        testApi = PMAPIService(doh: currentEnv, sessionUID: "testSessionUID")
        loginButton.isEnabled = true
        showCurrentPlanButton.isEnabled = false
        showUpdatePlansButton.isEnabled = false
        storeKitSetup()
    }
    
    @IBAction func onLoginButtonTap(_ sender: Any) {
        login()
    }
    
    @IBAction func onShowCurrentPlanButtonTap(_ sender: Any) {
        showCurrentPlanButton.isSelected = true
        paymentsUI?.showCurrentPlan(presentationType: modalVCSwitch.isOn ? .modal : .none, backendFetch: backendFetchSwitch.isOn, completionHandler: { result in
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
        paymentsUI?.showUpgradePlan(presentationType: modalVCSwitch.isOn ? .modal : .none, backendFetch: backendFetchSwitch.isOn, completionHandler: { result in
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
        // setup StoreKitManager
        userCachedStatus = UserCachedStatus()
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        paymentsUI = PaymentsUI(servicePlanDataService: self.servicePlan, planTypes: planTypes)
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
                    self.showCurrentPlanButton.isEnabled = true
                    self.showUpdatePlansButton.isEnabled = true
                    self.setupStoreKit()
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
    
    private func dismissKeyboard() {
        _ = usernameTextField.resignFirstResponder()
        _ = passwordTextField.resignFirstResponder()
    }
}

extension NewUserSubscriptionUIVC: StoreKitManagerDelegate {
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

extension NewUserSubscriptionUIVC {
    
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

extension NewUserSubscriptionUIVC: AuthDelegate {
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

extension NewUserSubscriptionUIVC {
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
// MARK: - PMTextFieldDelegate

extension NewUserSubscriptionUIVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}

#endif
