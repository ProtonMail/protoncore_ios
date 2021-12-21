//
//  LoginViewController.swift
//  SampleApp
//
//  Created by Igor Kulman on 03/11/2020.
//

import UIKit

import StoreKit
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_AccountDeletion
import ProtonCore_Foundations
import ProtonCore_Networking
import ProtonCore_UIFoundations
import ProtonCore_ForceUpgrade
import ProtonCore_HumanVerification
import ProtonCore_Services
import ProtonCore_APIClient
import ProtonCore_Doh
import ProtonCore_Login
import ProtonCore_LoginUI
import ProtonCore_Payments
import ProtonCore_PaymentsUI
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands

final class LoginViewController: UIViewController, AccessibleView {

    // MARK: - Outlets
    @IBOutlet private weak var headline: UILabel!
    @IBOutlet private weak var clearTransactionsButton: ProtonButton!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var signupSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var closeButtonSwitch: UISwitch!
    @IBOutlet private weak var planSelectorSwitch: UISwitch!
    @IBOutlet private weak var alternativeErrorPresenterSwitch: UISwitch!
    @IBOutlet private weak var welcomeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var additionalWork: UISegmentedControl!
    @IBOutlet private weak var loginButton: ProtonButton!
    @IBOutlet private weak var signupButton: ProtonButton!
    @IBOutlet private weak var logoutButton: ProtonButton!
    @IBOutlet private weak var deleteAccountButton: ProtonButton!
    @IBOutlet private weak var mailboxButton: ProtonButton!
    @IBOutlet private weak var humanVerificationSwitch: UISwitch!
    @IBOutlet private weak var appNameTextField: UITextField!
    @IBOutlet private weak var customDomainTextField: UITextField!
    @IBOutlet private weak var backendSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var hvVersionSegmented: UISegmentedControl!
    
    // MARK: - Properties

    private var data: LoginData? {
        didSet {
            logoutButton.isHidden = data == nil
            deleteAccountButton.isHidden = data == nil
        }
    }

    private let serviceDelegate = AnonymousServiceManager()
    private var forceUpgradeServiceDelegate: ForceUpgradeDelegate {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id979659905")!
        return ForceUpgradeHelper(config: .mobile(url), responseDelegate: self)
    }
    private var login: LoginAndSignup?
    private var humanVerificationDelegate: HumanVerifyDelegate?
    
    deinit {
        TemporaryHacks.isV3 = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let dynamicDomain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"] {
            customDomainTextField.text = dynamicDomain
            customDomainTextField.isHidden = false
            backendSegmentedControl.selectedSegmentIndex = 4
            print("Filled customDomainTextField with dynamic domain: \(dynamicDomain)")
        } else {
            print("Dynamic domain not found, customDomainTextField left unfilled")
        }
        headline.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        logoutButton.setMode(mode: .outlined)
        appNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setMinimumAccountType(accountType: predefinedAccountType)
        deleteAccountButton.setTitle(AccountDeletionService.defaultButtonName, for: .normal) 
        generateAccessibilityIdentifiers()
    }

    // MARK: - Actions

    @IBAction private func showLogin(_ sender: Any) {

        removePaymentsObserver()
        let prodDoH: DoH & ServerConfig = clientApp == .vpn ? ProdDoHVPN.default : ProdDoHMail.default
        if getDoh.getSignUpString() != prodDoH.signupDomain {
            executeQuarkUnban(doh: getDoh, serviceDelegate: serviceDelegate)
        }
        updateHVVersion()

        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }

        if humanVerificationSwitch.isOn {
            LoginHumanVerificationSetup.start(hostUrl: getDoh.getCurrentlyUsedHostUrl())
        } else {
            LoginHumanVerificationSetup.stop()
        }

        login = LoginAndSignup(
            appName: appName,
            clientApp: clientApp,
            doh: getDoh,
            apiServiceDelegate: serviceDelegate,
            forceUpgradeDelegate: forceUpgradeServiceDelegate,
            minimumAccountType: getMinimumAccountType,
            isCloseButtonAvailable: closeButtonSwitch.isOn,
            paymentsAvailability: planSelectorSwitch.isOn
            ? .available(parameters: .init(listOfIAPIdentifiers: listOfIAPIdentifiers, listOfShownPlanNames: listOfShownPlanNames, reportBugAlertHandler: reportBugAlertHandler))
                : .notAvailable,
            signupAvailability: getSignupAvailability
        )

        if let welcomeScreen = getShowWelcomeScreen {
            login?.presentFlowFromWelcomeScreen(
                over: self,
                welcomeScreen: welcomeScreen,
                username: nil,
                performBeforeFlow: getAdditionalWork,
                customErrorPresenter: getCustomErrorPresenter,
                completion: processLoginResult(_:)
            )
        } else {
            login?.presentLoginFlow(
                over: self,
                performBeforeFlow: getAdditionalWork,
                customErrorPresenter: getCustomErrorPresenter,
                completion: processLoginResult(_:)
            )
        }
    }

    private func processLoginResult(_ result: LoginResult) {
        switch result {
        case let .loggedIn(data):
            self.data = data
            print("Login OK with data: \(data)")
            login = nil
        case .dismissed:
            self.data = nil
            print("Dismissed by user")
            login = nil
        }
    }

    @IBAction private func showSignup(_ sender: Any) {

        removePaymentsObserver()
        let prodDoH: DoH & ServerConfig = clientApp == .vpn ? ProdDoHVPN.default : ProdDoHMail.default
        if getDoh.getSignUpString() != prodDoH.signupDomain {
            executeQuarkUnban(doh: getDoh, serviceDelegate: serviceDelegate)
        }
        updateHVVersion()
        self.data = nil
        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }
        
        login = LoginAndSignup(
            appName: appName,
            clientApp: clientApp,
            doh: getDoh,
            apiServiceDelegate: serviceDelegate,
            forceUpgradeDelegate: forceUpgradeServiceDelegate,
            minimumAccountType: getMinimumAccountType,
            isCloseButtonAvailable: closeButtonSwitch.isOn,
            paymentsAvailability: planSelectorSwitch.isOn
            ? .available(parameters: .init(listOfIAPIdentifiers: listOfIAPIdentifiers, listOfShownPlanNames: listOfShownPlanNames, reportBugAlertHandler: reportBugAlertHandler))
                : .notAvailable,
            signupAvailability: getSignupAvailability
        )
        
        login?.presentSignupFlow(
            over: self, performBeforeFlow: getAdditionalWork, customErrorPresenter: getCustomErrorPresenter
        ) { result in
            switch result {
            case let .loggedIn(data):
                self.data = data
                self.login = nil
                print("Signup OK with data: \(data)")
            case .dismissed:
                self.data = nil
                self.login = nil
                print("Dismissed by user")
            }
        }
    }
    
    private func reportBugAlertHandler(_ receipt: String?) -> Void {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Report Bug Example", message: "Example", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.alertWindow?.isHidden = true
                self?.alertWindow?.removeFromSuperview()
                self?.alertWindow = nil
            }))
            self.alertWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13.0, *)
    private var windowScene: UIWindowScene? {
        return UIApplication.getInstance()?.connectedScenes.first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }

    private lazy var alertWindow: UIWindow? = {
        let alertWindow: UIWindow?
        if #available(iOS 13.0, *) {
            if let windowScene = windowScene {
                alertWindow = UIWindow(windowScene: windowScene)
            } else {
                alertWindow = UIWindow(frame: UIScreen.main.bounds)
            }
        } else {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
        }
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.backgroundColor = UIColor.clear
        alertWindow?.windowLevel = .alert
        alertWindow?.makeKeyAndVisible()
        return alertWindow
    }()
    
    private var currentAuthCredential: AuthCredential? {
        guard let data = data else { return nil }
        switch data {
        case .userData(let userData): return userData.credential
        case .credential(let credential): return AuthCredential(credential)
        }
    }

    @IBAction private func logout(_ sender: Any) {
        guard let authCredential = currentAuthCredential else { return }
        guard let appName = appNameTextField.text, !appName.isEmpty else { return }
        login = LoginAndSignup(
            appName: appName,
            clientApp: clientApp,
            doh: getDoh,
            apiServiceDelegate: serviceDelegate,
            forceUpgradeDelegate: forceUpgradeServiceDelegate,
            minimumAccountType: getMinimumAccountType,
            isCloseButtonAvailable: closeButtonSwitch.isOn,
            paymentsAvailability: planSelectorSwitch.isOn
            ? .available(parameters: .init(listOfIAPIdentifiers: listOfIAPIdentifiers, listOfShownPlanNames: listOfShownPlanNames, reportBugAlertHandler: reportBugAlertHandler))
                : .notAvailable,
            signupAvailability: getSignupAvailability
        )
        login?.logout(credential: authCredential) { result in
            switch result {
            case .success:
                self.data = nil
                self.login = nil
                let alert = UIAlertController(title: "Logout", message: "Everything OK", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            case let .failure(error):
                self.login = nil
                var message = "Failed with \(error.localizedDescription)"
                if case AuthErrors.networkingError(let err) = error, err.httpCode == 401 {
                    // Invalid access token
                    self.data = nil
                    message = "Invalid access token logout"
                }
                let alert = UIAlertController(title: "Logout", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction private func deleteAccount(_ sender: Any) {
        guard let authCredential = currentAuthCredential else { return }
        let api = PMAPIService(doh: getDoh, sessionUID: "delete account test session")
        let accountDeletion = AccountDeletionService(api: api)
        accountDeletion.initiateAccountDeletionProcess(credential: Credential(authCredential), over: self) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let success): self?.handleSuccessfulAccountDeletion(success)
                case .failure(.closedByUser): break
                case .failure(let failure): self?.handleAccountDeletionFailure(failure)
                }
            }
        }
    }
    
    private func handleSuccessfulAccountDeletion(_ success: AccountDeletionSuccess) {
        let alert = UIAlertController(title: "Account deletion", message: "Everything OK", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        logoutButton.isHidden = true
        deleteAccountButton.isHidden = true
    }
    
    private func handleAccountDeletionFailure(_ failure: AccountDeletionError) {
        let alert = UIAlertController(title: "Account deletion failure", message: "\(failure.userFacingMessageInAccountDeletion)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        logoutButton.isHidden = false
        deleteAccountButton.isHidden = false
    }

    @IBAction private func mailbox(_ sender: Any) {
        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }
        
        login = LoginAndSignup(appName: appName,
                               clientApp: clientApp,
                               doh: getDoh,
                               apiServiceDelegate: serviceDelegate,
                               forceUpgradeDelegate: forceUpgradeServiceDelegate,
                               minimumAccountType: getMinimumAccountType,
                               isCloseButtonAvailable: closeButtonSwitch.isOn,
                               paymentsAvailability: .notAvailable,
                               signupAvailability: .notAvailable)

        login?.presentMailboxPasswordFlow(over: self) { password in
            self.login = nil
            let alert = UIAlertController(title: "Mailbox password", message: password, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }

    @IBAction private func clearTransactions(_ sender: Any) {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.transactions
            .filter { $0.transactionState != .failed }
            .forEach { paymentQueue.finishTransaction($0) }
        paymentQueue.add(self)

        clearTransactionsButton.setTitle("Checking for unfinished transactions...", for: .normal)
        clearTransactionsButton.setMode(mode: .outlined)
    }

    private func removePaymentsObserver() {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.remove(self)
        clearTransactionsButton.setTitle("Check for unfinished transactions", for: .normal)
        clearTransactionsButton.setMode(mode: .solid)
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @IBAction private func environmentChanged() {
        customDomainTextField.isHidden = backendSegmentedControl.selectedSegmentIndex != 3
    }
    
    private func updateHVVersion() {
        TemporaryHacks.isV3 = hvVersionSegmented.selectedSegmentIndex == 1
    }

    private var getDoh: DoH & ServerConfig {
        let doh: DoH & ServerConfig
        switch backendSegmentedControl.selectedSegmentIndex {
        case 0:
            if clientApp == .vpn {
                doh = ProdDoHVPN.default
            } else {
                doh = ProdDoHMail.default
            }
        case 1:
            doh = BlackDoH.default
        case 2:
            doh = PaymentsBlackDoH.default
        case 3:
            guard let customDomain = customDomainTextField.text else { fatalError("No custom domain") }
            doh = CustomServerConfigDoH(
                signupDomain: customDomain,
                captchaHost: "https://api.\(customDomain)",
                humanVerificationV3Host: "https://verify.\(customDomain)",
                accountHost: "https://account.\(customDomain)",
                defaultHost: "https://\(customDomain)",
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
            doh.status = dohStatus
        default:
            fatalError("Invalid index")
        }
        return doh
    }

    private var getMinimumAccountType: AccountType {
        let minimumAccountType: AccountType
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            minimumAccountType = AccountType.username
        case 1:
            minimumAccountType = AccountType.external
        case 2:
            minimumAccountType = AccountType.internal
        default:
            fatalError("Invalid index")
        }
        if humanVerificationSwitch.isOn {
            LoginHumanVerificationSetup.start(hostUrl: getDoh.getCurrentlyUsedHostUrl())
        } else {
            LoginHumanVerificationSetup.stop()
        }
        return minimumAccountType
    }
    
    private func setMinimumAccountType(accountType: AccountType?) {
        guard let accountType = accountType else { return }
        switch accountType {
        case AccountType.username:
            typeSegmentedControl.selectedSegmentIndex = 0
        case AccountType.external:
            typeSegmentedControl.selectedSegmentIndex = 1
        case AccountType.internal:
            typeSegmentedControl.selectedSegmentIndex = 2
        }
    }

    private var getSignumMode: SignupMode? {
        switch signupSegmentedControl.selectedSegmentIndex {
        case 0: return .both(initial: .internal)
        case 1: return .both(initial: .external)
        case 2: return .internal
        case 3: return .external
        case 4: return nil
        default: return .both(initial: .internal)
        }
    }
    
    private var getSignupAvailability: SignupAvailability {
        let signupAvailability: SignupAvailability
        if let signupMode = getSignumMode {
            signupAvailability = .available(parameters: SignupParameters(mode: signupMode, passwordRestrictions: .default, summaryScreenVariant: signupSummaryScreenVariant))
        } else {
            signupAvailability = .notAvailable
        }
        return signupAvailability
    }

    private var getShowWelcomeScreen: WelcomeScreenVariant? {
        switch welcomeSegmentedControl.selectedSegmentIndex {
        case 0: return nil
        case 1: return .mail(.init(headline: "Protect your privacy with ProtonMail",
                                   body: "Please Mister Postman, look and see! Is there's a letter in your bag for me? Why's it takin' such a long time for me to hear from that boy of mine?"))
        case 2: return .vpn(.init(headline: "Protect yourself online",
                                  body: "I know you've been hurt by someone else. I can tell by the way you carry yourself. But if you let me, here's what I'll do: I'll take care of you"))
        case 3: return .drive(.init(headline: "Let's go for a Drive",
                                    body: "Drive me to the moon and let me play among the stars. Let me see what spring is like on Jupiter and Mars"))
        case 4: return .calendar(.init(headline: "Time flies, and with Calendar so will you",
                                       body: "I don't care if Monday's blue. Tuesday's grey and Wednesday too. Thursday, I don't care about you. It's Friday, I'm in love"))
        default: return nil
        }
    }

    private var getAdditionalWork: WorkBeforeFlow? {
        switch additionalWork.selectedSegmentIndex {
        case 0: return nil
        case 1: return WorkBeforeFlow(stepName: "Additional work creation...") { loginData, flowCompletion in
            print("\(Date()) Making additional work at the end of the flow")
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(10)
                print("\(Date()) Making additional work at the end of the flow")
                flowCompletion(.success(()))
            }
        }
        case 2: return WorkBeforeFlow(stepName: "Additional work creation...") { loginData, flowCompletion in
            print("\(Date()) Making additional work at the end of the flow")
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(10)
                print("\(Date()) Making additional work at the end of the flow")
                flowCompletion(.failure(CocoaError(.userCancelled)))
            }
        }
        default: fatalError("no more clients expected")
        }
    }
    
    private var getCustomErrorPresenter: LoginErrorPresenter? {
        guard alternativeErrorPresenterSwitch.isOn else { return nil }
        return AlternativeLoginErrorPresenter()
    }

    @IBAction private func signupModeChanged() {
        if getSignumMode == nil {
            signupButton.isHidden = true
        } else {
            signupButton.isHidden = false
        }
    }
}

// MARK: - Human verification delegate

extension LoginViewController: HumanVerifyResponseDelegate {
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

// MARK: - Force upgrade delegate

extension LoginViewController: ForceUpgradeResponseDelegate {
    func onQuitButtonPressed() {
        // on quit button pressed
    }

    func onUpdateButtonPressed() {
        // on update button pressed
    }
}

extension LoginViewController: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print(#function)
        guard !queue.transactions.isEmpty else {
            print("There are no transactions to be cleared")
            return
        }
        queue.transactions.forEach {
            print("Clearing transaction for \($0.payment.productIdentifier)")
            queue.finishTransaction($0)
        }
        removePaymentsObserver()
        clearTransactionsButton.setTitle("Unfinished transactions cleared, tap to check more", for: .normal)
    }
}

final class AlternativeLoginErrorPresenter: LoginErrorPresenter {
    
    func showAlert(message: String, over: UIViewController) {
        let alert = UIAlertController(title: "The magnificent alternative error presenter proudly presents", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Well, that's a shame", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        }))
        over.present(alert, animated: true, completion: nil)
    }
    
    func willPresentError(error: LoginError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: SignupError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: AvailabilityError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: SetUsernameError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: CreateAddressError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: CreateAddressKeysError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: StoreKitManagerErrors, from viewController: UIViewController) -> Bool {
        showAlert(message: error.userFacingMessageInPayments, over: viewController)
        return true
    }
    
    func willPresentError(error: ResponseError, from viewController: UIViewController) -> Bool {
        showAlert(message: error.networkResponseMessageForTheUser, over: viewController)
        return true
    }
    
    func willPresentError(error: Error, from viewController: UIViewController) -> Bool {
        showAlert(message: error.messageForTheUser, over: viewController)
        return true
    }
}
