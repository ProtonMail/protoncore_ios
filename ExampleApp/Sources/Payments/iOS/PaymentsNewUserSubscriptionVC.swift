//
//  PaymentsNewUserSubscriptionVC.swift
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
import ProtonCoreFoundations
import ProtonCoreAuthentication
import ProtonCoreLog
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreUIFoundations
import ProtonCorePayments
import ProtonCoreEnvironment
import ProtonCoreChallenge
import ProtonCoreFeatureSwitch

class PaymentsNewUserSubscriptionVC: PaymentsBaseUIViewController, AccessibleView {
    
    // MARK: - Outlets
    @IBOutlet weak var picker: UIPickerView!
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
    @IBOutlet weak var canExtendSubscriptionSwitch: UISwitch!
    @IBOutlet weak var forceSubscriptionButton: UISwitch!
    @IBOutlet weak var purchaseSubscriptionButton: ProtonButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scrollBottomPaddingConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var currentEnv: Environment!
    var inAppPurchases: ListOfIAPIdentifiers!
    var serviceDelegate: APIServiceDelegate!
    var testPicker: PaymentsTestUserPickerData?

    // MARK: - Auth properties
    private var testApi: PMAPIService!
    private var authHelper: AuthHelper?
    private var userInfo: User?
    
    // MARK: - Payment credentials
    private var payments: Payments!
    private var userCachedStatus: UserCachedStatus!
    
    // MARK: - Payment data
    private var isValid = false { didSet { self.showVerify() } }

    private var availablePlans: [InAppPurchasePlan] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testApi = PMAPIService.createAPIService(environment: currentEnv,
                                                sessionUID: "testSessionUID",
                                                challengeParametersProvider: .forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        testApi.serviceDelegate = serviceDelegate
        loginButton.isEnabled = true
        currentSubscriptionButton.isEnabled = false
        purchaseSubscriptionButton.isEnabled = false
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        subscriptionSelector.removeAllSegments()
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
    
    @IBAction func onCurrentSurscriptionButtonTap(_ sender: Any) {
        currentSubscription()
    }
    
    @IBAction func onPurchaseSubscriptionButtonTap(_ sender: ProtonButton) {
        self.buyPlan()
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    @IBAction func canExtendSubscriptionAction(_ sender: Any) {
        setupPayments()
    }
    
    private func storeKitSetup() {
        // setup StoreKitManager
        userCachedStatus = UserCachedStatus(updateSubscriptionBlock: { [weak self] newSubscription in
            DispatchQueue.main.async { [weak self] in
                self?.showSubscriptionData()
            }
        }, updateUserInfoBlock: { [weak self] credits in
            DispatchQueue.main.async { [weak self] in
                self?.showCreditsData(credits: credits)
            }
        })
        setupPayments()
    }
    
    private func setupPayments() {
        payments = Payments(
            inAppPurchaseIdentifiers: inAppPurchases,
            apiService: testApi,
            localStorage: userCachedStatus,
            canExtendSubscription: canExtendSubscriptionSwitch.isOn,
            reportBugAlertHandler: { [weak self] receipt in self?.reportBugAlertHandler(receipt) }
        )
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
        currentSubscriptionButton.isEnabled = false
        purchaseSubscriptionButton.isEnabled = false
        
        guard let username = usernameTextField.text, username != "", let password = passwordTextField.text, password != "" else {
            loginStatusLabel.text = "Login status: Wrong credentials"
            return
        }
        authHelper = AuthHelper()
        testApi.authDelegate = authHelper
        let authApi = Authenticator(api: testApi)
        loginButton.isSelected = true
        testApi.serviceDelegate = onlyForAuthServiceDelegate

        authApi.authenticate(username: username, password: password, challenge: nil) { [weak self] result in
            guard let self = self else { return }
            self.loginButton.isSelected = false
            switch result {
            case .success(.newCredential(let credential, _)):
                self.authHelper?.onSessionObtaining(credential: credential)
                self.testApi.setSessionUID(uid: credential.UID)
                authApi.getUserInfo(credential) { [weak self] (result: Result<User, AuthErrors>) in
                    guard let self = self else { return }
                    self.testApi.serviceDelegate = self.serviceDelegate
                    switch result {
                    case .success(let user):
                        self.userInfo = user
                        self.setupStoreKit { [weak self] error in
                            guard let self = self else { return }
                            guard error == nil else {
                                self.loginStatusLabel.text = "Login status: \(error!.localizedDescription)"
                                self.currentSubscriptionButton.isEnabled = false
                                self.userInfo = nil
                                self.clearData()
                                PMLog.debug("Error: \(result)")
                                return
                            }
                            self.loginStatusLabel.text = "Login status: OK"
                            self.clearData()
                            // TODO: support purchase process with PlansDataSource object
                            guard !FeatureFactory.shared.isEnabled(.dynamicPlans), case .left(let planService) = self.payments.planService else {
                                assertionFailure("Purchase process with dynamic plans is not supported yet")
                                return
                            }
                            planService.updateServicePlans { [weak self] in
                                guard let self = self else { return }
                                self.currentSubscriptionButton.isEnabled = true
                                self.processPossiblePlans()
                            } failure: { error in
                                PMLog.debug("Error: Update Service Plans error: \(error)")
                            }
                        }
                    case .failure(let error):
                        self.loginStatusLabel.text = "Login status: \(error.userFacingMessageInNetworking)"
                        self.currentSubscriptionButton.isEnabled = false
                        self.userInfo = nil
                        self.clearData()
                        PMLog.debug("Error: \(result)")
                    }
                }
            case .failure(Authenticator.Errors.networkingError(let error)):
                self.loginStatusLabel.text = "Login status: \(error.localizedDescription)"
                PMLog.debug("Error: \(result)")
            case .failure(Authenticator.Errors.apiMightBeBlocked(let message, _)):
                self.loginStatusLabel.text = "Login status: \(message)"
                PMLog.debug("Error: \(result)")
                self.serviceDelegate.onDohTroubleshot()
            case .failure:
                self.loginStatusLabel.text = "Login status: Not OK"
            case .success(.ask2FA):
                self.loginStatusLabel.text = "Login status: Not supportd 2FA"
                break
            case .success(.ssoChallenge):
                self.loginStatusLabel.text = "Login status: Not supportd SSO Challenge"
                break
            case .success(.updatedCredential):
                break
                // should not happen
            }
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
        // TODO: support purchase process with PlansDataSource object
        guard !FeatureFactory.shared.isEnabled(.dynamicPlans), case .left(let planService) = self.payments.planService else {
            assertionFailure("Purchase process with dynamic plans is not supported yet")
            return nil
        }
        return planService.detailsOfPlanCorrespondingToIAP(accountPlan)
    }
    
    private func updateAvailablePlans() {
        for (index, planData) in availablePlans.enumerated() {
            subscriptionSelector.insertSegment(withTitle: planData.protonName, at: index, animated: false)
        }
        if subscriptionSelector.numberOfSegments > 0 {
            subscriptionSelector.selectedSegmentIndex = 0
        }
    }
    
    private func setupStoreKit(completion: @escaping (Error?) -> Void) {
        payments.activate(delegate: self, storeKitProductsFetched: completion)
        if FeatureFactory.shared.isEnabled(.dynamicPlans) {
            completion(nil)
        }
        
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
        verifyPurchase { [weak self] isValid in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isValid = isValid
                self.currentSubscriptionButton.isSelected = false
            }
        }
    }
    
    private func showSubscriptionData() {
        // TODO: support purchase process with PlansDataSource object
        guard !FeatureFactory.shared.isEnabled(.dynamicPlans), case .left(let planService) = self.payments.planService else {
            assertionFailure("Purchase process with dynamic plans is not supported yet")
            return
        }
        let planNames = planService.currentSubscription?.planDetails?
            .filter { $0.isAPrimaryPlan }
            .compactMap { $0.name } ?? [InAppPurchasePlan.freePlanName]
        let plansStr = planNames.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let addonNames = planService.currentSubscription?.planDetails?.filter { $0.isAnAddOn }.compactMap { $0.name }
        let addonsStr = addonNames?.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        var addonsDispStr = addonsStr ?? "---"
        if addonsDispStr == "" {
            addonsDispStr = "---"
        }
        var cycle = "---"
        if let servicePlanCycle = planService.currentSubscription?.cycle, servicePlanCycle > 0 {
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
        guard let storeKitProductId = availablePlans[subscriptionSelector.selectedSegmentIndex].storeKitProductId else {
            completion(false)
            return
        }
        payments.storeKitManager.isValidPurchase(storeKitProductId: storeKitProductId, completion: completion)
    }
    
    private func showVerify() {
        self.purchaseSubscriptionButton.isEnabled = isValid || self.forceSubscriptionButton.isOn
        if self.isValid || self.forceSubscriptionButton.isOn {
            var title = "Purchase subscription"
            if self.isValid {
                // TODO: support purchase process with PlansDataSource object
                guard !FeatureFactory.shared.isEnabled(.dynamicPlans), case .left(let planService) = self.payments.planService else {
                    assertionFailure("Purchase process with dynamic plans is not supported yet")
                    return
                }
                if planService.currentSubscription?.planDetails != nil {
                    title = "Add credits"
                }
            } else {
                title = "Force purchase subscription"
            }
            self.purchaseSubscriptionButton.setTitle(title, for: .normal)
            self.subscriptionToPurchaseLabel.text = "Subscription to purchase: \(availablePlans[subscriptionSelector.selectedSegmentIndex].protonName)"
        } else {
            self.subscriptionToPurchaseLabel.text = "Subscription to purchase: ---"
        }
    }
    
    private func buyPlan() {
        self.statusLabel.text = "Status:"
        guard !payments.storeKitManager.hasUnfinishedPurchase(), userInfo?.ID.isEmpty == false else {
            self.statusLabel.text = "Status: Not ready to purchase"
            PMLog.debug("StoreKitManager is not ready to purchase")
            return
        }
        purchaseSubscriptionButton.isSelected = true
        guard let storeKitProductId = availablePlans[subscriptionSelector.selectedSegmentIndex].storeKitProductId,
              let plan = InAppPurchasePlan(storeKitProductId: storeKitProductId) else {
            assertionFailure("The list of IAPs was configured wrong")
            return
        }
        payments.purchaseManager.buyPlan(plan: plan) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .purchasedPlan:
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: Success"
                PMLog.debug("Purchace success")
                self.verifyPurchase { isValid in
                    DispatchQueue.main.async {
                        self.isValid = isValid
                    }
                }
            case .toppedUpCredits:
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: Credits topped up"
                PMLog.debug("Credits topped up")
            case .planPurchaseProcessingInProgress(let processingPlan):
                self.statusLabel.text = "Plan purchase in progress: \(processingPlan)"
                PMLog.debug("Plan purchase in progress")
            case let .purchaseError(error, _):
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: \(error.localizedDescription)"
                PMLog.debug(error.localizedDescription)
            case let .apiMightBeBlocked(message, _, _):
                PMLog.debug(message)
                self.serviceDelegate.onDohTroubleshot()
            case .purchaseCancelled:
                self.purchaseSubscriptionButton.isSelected = false
                self.statusLabel.text = "Status: Cancelled"
            }
        }
    }
    
    private func dismissKeyboard() {
        _ = usernameTextField.resignFirstResponder()
        _ = passwordTextField.resignFirstResponder()
    }
}

extension PaymentsNewUserSubscriptionVC: StoreKitManagerDelegate {
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
        return userInfo?.ID
    }
    
    var servicePlanDataService: ServicePlanDataServiceProtocol? {
        // TODO: support purchase process with PlansDataSource object
        guard !FeatureFactory.shared.isEnabled(.dynamicPlans), case .left(let planService) = self.payments.planService else {
            assertionFailure("Purchase process with dynamic plans is not supported yet")
            return nil
        }
        return planService
    }
}

extension PaymentsNewUserSubscriptionVC {
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

extension PaymentsNewUserSubscriptionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        login()
        return true
    }
}
