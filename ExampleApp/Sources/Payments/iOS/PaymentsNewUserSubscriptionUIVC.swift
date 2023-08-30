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

import UIKit
import ProtonCoreHumanVerification
import ProtonCoreDoh
import ProtonCoreServices
import ProtonCoreAuthentication
import ProtonCoreLog
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreUIFoundations
import ProtonCorePayments
import ProtonCorePaymentsUI
import ProtonCoreFoundations
import ProtonCoreEnvironment
import ProtonCoreChallenge

class PaymentsNewUserSubscriptionUIVC: PaymentsBaseUIViewController, AccessibleView {
    
    // MARK: - Outlets
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: ProtonButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var canExtendSubscriptionSwitch: UISwitch!
    @IBOutlet weak var backendFetchSwitch: UISwitch!
    @IBOutlet weak var modalVCSwitch: UISwitch!
    @IBOutlet weak var showCurrentPlanButton: ProtonButton!
    @IBOutlet weak var showUpdatePlansButton: ProtonButton!
    
    // MARK: - Payment credentials
    private var payments: Payments!
    private var userCachedStatus: UserCachedStatus!
    
    // MARK: - Properties
    var currentEnv: Environment!

    var inAppPurchases: ListOfIAPIdentifiers!
    var serviceDelegate: APIServiceDelegate!
    
    var testPicker: PaymentsTestUserPickerData?
    
    private var paymentsUI: PaymentsUI?
    
    // MARK: - Auth properties
    private var testApi: PMAPIService!
    private var authHelper: AuthHelper?
    private var userInfo: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testApi = PMAPIService.createAPIService(environment: currentEnv,
                                                sessionUID: "testSessionUID",
                                                challengeParametersProvider: .forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        testApi.serviceDelegate = serviceDelegate
        loginButton.isEnabled = true
        showCurrentPlanButton.isEnabled = false
        showUpdatePlansButton.isEnabled = false
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
        configurePayments { [weak self] in
            guard let self = self else { return }
            self.paymentsUI?.showCurrentPlan(presentationType: self.modalVCSwitch.isOn ? .modal : .none, backendFetch: self.backendFetchSwitch.isOn, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .open(let vc, let opened):
                    self.showCurrentPlanButton.isSelected = false
                    if !opened {
                        self.adjustNavigationController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                case .purchasedPlan(let plan):
                    PMLog.info("purchasedPlan: \(plan)")
                case .close:
                    self.restoreNavigationController()
                    self.paymentsUI = nil
                    self.cleanupStoreKit()
                case .toppedUpCredits:
                    PMLog.info("toppedUpCredits")
                case .planPurchaseProcessingInProgress(let accountPlan):
                    PMLog.info("planPurchaseProcessingInProgress \(accountPlan)")
                case .purchaseError(let error):
                    PMLog.info("purchaseError \(error)")
                case let .apiMightBeBlocked(message, _):
                    PMLog.debug(message)
                    self.serviceDelegate.onDohTroubleshot()
                }
            })

        }
    }
    
    @IBAction func onShowUpdatePlansButtonTap(_ sender: Any) {
        showUpdatePlansButton.isSelected = true
        configurePayments { [weak self] in
            guard let self = self else { return }
            self.paymentsUI?.showUpgradePlan(presentationType: self.modalVCSwitch.isOn ? .modal : .none, backendFetch: self.backendFetchSwitch.isOn, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .open(let vc, let opened):
                    self.showUpdatePlansButton.isSelected = false
                    if !opened {
                        self.adjustNavigationController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                case .purchasedPlan(let plan):
                    PMLog.info("purchasedPlan: \(plan)")
                case .close:
                    self.restoreNavigationController()
                    self.cleanupStoreKit()
                case .toppedUpCredits:
                    PMLog.info("toppedUpCredits")
                case .planPurchaseProcessingInProgress(let accountPlan):
                    PMLog.info("planPurchaseProcessingInProgress \(accountPlan)")
                case .purchaseError(let error):
                    PMLog.info("purchaseError \(error)")
                case let .apiMightBeBlocked(message, _):
                    PMLog.debug(message)
                    self.serviceDelegate.onDohTroubleshot()
                }
            })
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    private func adjustNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func restoreNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    private func reportBugAlertHandler(_ receipt: String?) -> Void {
        guard let alertWindow = self.alertWindow else { return }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Report Bug Example", message: "Example", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
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
        authHelper = AuthHelper()
        testApi.authDelegate = authHelper
        testApi.serviceDelegate = onlyForAuthServiceDelegate
        let authApi = Authenticator(api: testApi)
        loginButton.isSelected = true

        authApi.authenticate(username: username, password: password, challenge: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(.newCredential(let credential, _)):
                let actualCredential = credential
                self.authHelper?.onSessionObtaining(credential: credential)
                self.testApi.setSessionUID(uid: credential.UID)
                authApi.getUserInfo(actualCredential) { [weak self] (result: Result<User, AuthErrors>) in
                    guard let self = self else { return }
                    self.testApi.serviceDelegate = self.serviceDelegate
                    switch result {
                    case .success(let user):
                        self.loginButton.isSelected = false
                        self.userInfo = user
                        self.loginStatusLabel.text = "Login status: OK"
                        self.showCurrentPlanButton.isEnabled = true
                        self.showUpdatePlansButton.isEnabled = true
                    case .failure(let error):
                        self.loginButton.isSelected = false
                        self.loginStatusLabel.text = "Login status: \(error.userFacingMessageInNetworking)"
                        self.showCurrentPlanButton.isEnabled = false
                        self.showUpdatePlansButton.isEnabled = false
                        self.userInfo = nil
                        PMLog.debug("Error: \(result)")
                    }
                }
            case .failure(Authenticator.Errors.networkingError(let error)):
                self.loginStatusLabel.text = "Login status: \(error.localizedDescription)"
                self.loginButton.isSelected = false
                PMLog.debug("Error: \(result)")
            case .failure(Authenticator.Errors.apiMightBeBlocked(let message, _)):
                self.loginStatusLabel.text = "Login status: \(message)"
                self.loginButton.isSelected = false
                PMLog.debug("Error: \(result)")
                self.serviceDelegate.onDohTroubleshot()
            case .failure:
                self.loginStatusLabel.text = "Login status: Not OK"
                self.loginButton.isSelected = false
            case .success(.ask2FA):
                self.loginStatusLabel.text = "Login status: Not supportd 2FA"
                self.loginButton.isSelected = false
                break
            case .success(.ssoChallenge):
                self.loginStatusLabel.text = "Login status: Not supportd SSO Challenge"
                self.loginButton.isSelected = false
                break
            case .success(.updatedCredential):
                self.loginButton.isSelected = false
                break
                // should not happen
            }
        }
    }

    private func configurePayments(completion: @escaping () -> Void) {
        setupPayments { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                self.loginStatusLabel.text = "Login status: \(error!.localizedDescription)"
                self.showCurrentPlanButton.isEnabled = false
                self.showUpdatePlansButton.isEnabled = false
                self.userInfo = nil
                self.cleanupStoreKit()
                return
            }
            completion()
        }
    }
    
    private func setupPayments(completion: @escaping (Error?) -> Void) {
        userCachedStatus = UserCachedStatus()
        payments = Payments(
            inAppPurchaseIdentifiers: inAppPurchases,
            apiService: testApi,
            localStorage: userCachedStatus,
            canExtendSubscription: canExtendSubscriptionSwitch.isOn,
            reportBugAlertHandler: { [weak self] receipt in self?.reportBugAlertHandler(receipt) }
        )
        payments.activate(delegate: self, storeKitProductsFetched: completion)
        paymentsUI = PaymentsUI(
            payments: payments, clientApp: clientApp, shownPlanNames: listOfShownPlanNames, customization: .empty
        )
    }
    
    private func cleanupStoreKit() {
        paymentsUI = nil
        payments.storeKitManager.unsubscribeFromPaymentQueue()
        payments.storeKitManager.delegate = nil
        payments = nil
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

// MARK: - PMTextFieldDelegate

extension PaymentsNewUserSubscriptionUIVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}
