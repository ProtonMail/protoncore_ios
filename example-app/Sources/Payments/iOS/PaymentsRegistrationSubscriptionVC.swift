//
//  PaymentsRegistrationSubscriptionVC.swift
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
import GoLibs
import ProtonCore_APIClient
import ProtonCore_HumanVerification
import ProtonCore_Doh
import ProtonCore_Services
import ProtonCore_Authentication
import ProtonCore_Log
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Foundations
import ProtonCore_UIFoundations
import ProtonCore_Payments
import ProtonCore_Environment
import TrustKit

class PaymentsRegistrationSubscriptionVC: PaymentsBaseUIViewController, AccessibleView {
    
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
    var currentEnv: Environment!

    var inAppPurchases: ListOfIAPIdentifiers!
    var serviceDelegate: APIServiceDelegate!
    var testPicker: PaymentsTestUserPickerData?
    
    // MARK: - Private auth properties
    private var testApi: PMAPIService!
    private var authHelper: AuthHelper?
    private var userInfo: User?
    
    // MARK: - Private payment credentials
    private var payments: Payments!
    private var userCachedStatus: UserCachedStatus!

    private var availablePlans: [InAppPurchasePlan] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testApi = PMAPIService.createAPIService(environment: currentEnv, sessionUID: "testSessionUID")
        testApi.serviceDelegate = serviceDelegate
        userCachedStatus = UserCachedStatus()
        payments = Payments(
            inAppPurchaseIdentifiers: inAppPurchases,
            apiService: testApi,
            localStorage: userCachedStatus,
            reportBugAlertHandler: { [weak self] receipt in self?.reportBugAlertHandler(receipt) }
        )
        NotificationCenter.default.addObserver(self, selector: #selector(finish),
                                               name: Payments.transactionFinishedNotification, object: nil)
        setupStoreKit { _ in }
        loginButton.isEnabled = false
        humanVerificationButton.isEnabled = false
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        subscriptionSelector.removeAllSegments()
        purchaseSubscriptionButton.isEnabled = false
        updatePlans()
        generateAccessibilityIdentifiers()
    }
    
    private func reportBugAlertHandler(_ receipt: String?) -> Void {
        guard let alertWindow = self.alertWindow else { return }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Report Bug Example", message: "Example", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupStoreKit(completion: @escaping (Error?) -> Void) {
        payments.storeKitManager.delegate = self
        payments.storeKitManager.subscribeToPaymentQueue()
        payments.storeKitManager.updateAvailableProductsList(completion: completion)
    }
    
    @IBAction func onPurchaseSubscriptionButtonTap(_ sender: Any) {
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
    
    private func updatePlans() {
        self.payments.planService.updateServicePlans { [weak self] in
            self?.purchaseSubscriptionButton.isEnabled = true
            self?.processPossiblePlans()
        } failure: { error in
            PMLog.debug("Error: Update Service Plans error: \(error)")
        }
    }
    
    private func processPossiblePlans() {
        availablePlans.removeAll()
        subscriptionSelector.removeAllSegments()
        inAppPurchases.compactMap(InAppPurchasePlan.init(storeKitProductId:)).forEach {
            if let details = fetchDetails(accountPlan: $0), details.isPurchasable == true {
                availablePlans.append($0)
            }
        }
        updateAvailablePlans()
    }
    
    private func fetchDetails(accountPlan: InAppPurchasePlan) -> Plan? {
        return payments.planService.detailsOfServicePlan(named: accountPlan.protonName)
    }
    
    private func updateAvailablePlans() {
        for (index, planData) in availablePlans.enumerated() {
            subscriptionSelector.insertSegment(withTitle: planData.protonName, at: index, animated: false)
        }
        if subscriptionSelector.numberOfSegments > 0 {
            subscriptionSelector.selectedSegmentIndex = 0
        }
    }
    
    private func buyPlan() {
        // STEP 1: buy plan and store payment token
        authHelper = AuthHelper()
        testApi.authDelegate = authHelper
        self.statusLabel.text = "Status:"
        guard let storeKitProductId = availablePlans[subscriptionSelector.selectedSegmentIndex].storeKitProductId,
              let plan = InAppPurchasePlan(storeKitProductId: storeKitProductId) else {
            assertionFailure("The list of IAPs was configured wrong")
            return
        }
        purchaseSubscriptionButton.isSelected = true
        payments.purchaseManager.buyPlan(plan: plan) { [unowned self] result in
            switch result {
            case let .purchasedPlan(accountPlan):
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: plan \(accountPlan.protonName) purchased"
                self.humanVerificationButton.isEnabled = true
                PMLog.debug("Status: PaymentToken received")
                self.loginButton.isEnabled = true
                self.purchaseSubscriptionButton.isEnabled = false
            case .toppedUpCredits:
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: Credits topped up"
                self.humanVerificationButton.isEnabled = true
                PMLog.debug("Credits topped up")
                self.loginButton.isEnabled = true
                self.purchaseSubscriptionButton.isEnabled = false
            case .planPurchaseProcessingInProgress(let processingPlan):
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: purchasing in progress \(processingPlan)"
                self.humanVerificationButton.isEnabled = true
                PMLog.debug("Status: purchasing in progress \(processingPlan)")
                self.loginButton.isEnabled = true
                self.purchaseSubscriptionButton.isEnabled = false
            case let .purchaseError(error, _):
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: \(error.messageForTheUser)"
                PMLog.debug(error.messageForTheUser)
            case let .apiMightBeBlocked(message, _, _):
                PMLog.debug(message)
                self.serviceDelegate.onDohTroubleshot()
            case .purchaseCancelled:
                self.statusLabel.text = "Status: cancelled"
                self.purchaseSubscriptionButton.isEnabled = true
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
        let authApi = Authenticator(api: testApi)
        testApi.serviceDelegate = onlyForAuthServiceDelegate
        loginButton.isSelected = true

        authApi.authenticate(username: username, password: password, challenge: nil) { [unowned self] result in
            switch result {
            case .success(.newCredential(let credential, _)):
                self.authHelper?.onAuthentication(credential: credential, service: testApi)
                self.loginStatusLabel.text = "Login status: OK"
                self.userInfoAndUpdatePlans(authApi: authApi, credential: credential)
            case .failure(Authenticator.Errors.networkingError(let error)):
                self.loginButton.isSelected = false
                self.loginStatusLabel.text = "Login status: \(error.networkResponseMessageForTheUser)"
                PMLog.debug("Error: \(result)")
            case .failure(Authenticator.Errors.apiMightBeBlocked(let message, _)):
                self.loginButton.isSelected = false
                self.loginStatusLabel.text = "Login status: \(message)"
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
    
    private func userInfoAndUpdatePlans(authApi: Authenticator, credential: Credential) {
        // STEP 3: Get user info and current plan
        authApi.getUserInfo(credential) { [unowned self] (result: Result<User, AuthErrors>) in
            switch result {
            case .success(let user):
                self.userInfo = user
                self.payments.planService.updateServicePlans { [unowned self] in
                    if self.payments.planService.isIAPAvailable {
                        self.payments.planService.updateCurrentSubscription() { [unowned self] in
                            let planNames = self.payments.planService.currentSubscription?.planDetails?
                                .filter { $0.isAPrimaryPlan }
                                .compactMap { $0.name } ?? [InAppPurchasePlan.freePlanName]
                            let plansStr = planNames.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                            self.currentSubscriptionLabel.text = "Current subscriptions: \(plansStr)"
                            self.contunuePurchase()
                        } failure: { error in
                            PMLog.debug(error.messageForTheUser)
                        }
                    }
                } failure: { error in
                    self.loginButton.isSelected = false
                    PMLog.debug(error.messageForTheUser)
                }
            case .failure(let error):
                self.loginButton.isSelected = false
                PMLog.debug(error.userFacingMessageInNetworking)
            }
        }
    }

    private func contunuePurchase() {
        // STEP 4: Continue purchase
        self.payments.storeKitManager.retryProcessingAllPendingTransactions() { [unowned self] in
            DispatchQueue.main.async { [unowned self] in
                self.loginButton.isSelected = false
                self.statusAfterSignLabel.text = "Subscription status: Success"
                PMLog.debug("Subscription Success")
                self.loginButton.isEnabled = false
                let planNames = self.payments.planService.currentSubscription?.planDetails?
                    .filter { $0.type == 1 }
                    .compactMap { $0.name } ?? [InAppPurchasePlan.freePlanName]
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
        testApi.serviceDelegate = self
        testApi.authDelegate = authHelper

        //set the human verification delegation
        let url = HVCommon.defaultSupportURL(clientApp: clientApp)
        humanVerificationDelegate = HumanCheckHelper(apiService: testApi, supportURL: url, viewController: self, clientApp: clientApp, versionToBeUsed: .v3, responseDelegate: self, paymentDelegate: self)
        testApi.humanDelegate = humanVerificationDelegate
    }
    
    private func processHumanVerifyTest() {
        // Human Verify request with empty token just to provoke human verification error
        let client = TestApiClient(api: self.testApi)
        humanVerificationButton.isSelected = true
        client.triggerHumanVerify(isAuth: false) { [unowned self] (_, response) in
            self.humanVerificationButton.isSelected = false
            if let error = response.error {
                self.humanVerificationResultLabel.text = "HV result: Code=\(String(describing: error.responseCode)) \(error.networkResponseMessageForTheUser)"
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

extension PaymentsRegistrationSubscriptionVC: StoreKitManagerDelegate {
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
        return userInfo?.ID
    }
    
    var servicePlanDataService: ServicePlanDataServiceProtocol? {
        return payments.planService
    }
}

extension PaymentsRegistrationSubscriptionVC {
    
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

// MARK: - HumanVerifyResponseDelegate

extension PaymentsRegistrationSubscriptionVC: APIServiceDelegate {
    
    var additionalHeaders: [String: String]? { nil }
    
    var locale: String { Locale.autoupdatingCurrent.identifier }
    
    var userAgent: String? { "" }
    
    func isReachable() -> Bool { true }
    
    var appVersion: String { appVersionHeader.getVersionHeader() }
    
    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }
    
    func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}


// MARK: - HumanVerifyResponseDelegate

extension PaymentsRegistrationSubscriptionVC: HumanVerifyResponseDelegate {
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
        PMLog.info("Human verify token: \(String(describing: token)), type: \(String(describing: tokenType))")
    }
}

extension PaymentsRegistrationSubscriptionVC: HumanVerifyPaymentDelegate {
    var paymentToken: String? {
        return TokenStorage.default.get()?.token
    }
    
    func paymentTokenStatusChanged(status: PaymentTokenStatusResult) {
        PMLog.info("Human verification token status changed to: \(status)")
    }
}

// MARK: - PMTextFieldDelegate

extension PaymentsRegistrationSubscriptionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}
