//
//  ViewController.swift
//  SampleApp
//
//  Created by Igor Kulman on 03/11/2020.
//

import UIKit

import StoreKit
import ProtonCore_Foundations
import ProtonCore_Networking
import ProtonCore_UIFoundations
import ProtonCore_ForceUpgrade
import ProtonCore_HumanVerification
import ProtonCore_Services
import ProtonCore_APIClient
import ProtonCore_Doh
import ProtonCore_Login
import ProtonCore_Payments
import ProtonCore_PaymentsUI
import OHHTTPStubs

final class ViewController: UIViewController, AccessibleView {

    // MARK: - Outlets

    @IBOutlet private weak var logoutButton: ProtonButton!
    @IBOutlet private weak var mailboxButton: ProtonButton!
    @IBOutlet private weak var clearTransactionsButton: ProtonButton!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var closeButtonSwitch: UISwitch!
    @IBOutlet weak var planSelectorSwitch: UISwitch!
    @IBOutlet weak var welcomeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var loginButton: ProtonButton!
    @IBOutlet private weak var signupButton: ProtonButton!
    @IBOutlet private weak var humanVerificationSwitch: UISwitch!
    @IBOutlet private weak var appNameTextField: UITextField!
    @IBOutlet private weak var backendSegmentedControl: UISegmentedControl!

    // MARK: - Properties

    private var data: LoginData? {
        didSet {
            logoutButton.isHidden = data == nil
        }
    }

    private let serviceDelegate = AnonymousServiceManager()
    private var forceUpgradeServiceDelegate: ForceUpgradeDelegate {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id979659905")!
        return ForceUpgradeHelper(config: .mobile(url), responseDelegate: self)
    }
    private var login: LoginAndSignup?
    private var humanVerificationDelegate: HumanVerifyDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColorManager.BackgroundNorm
        logoutButton.setMode(mode: .outlined)
        appNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        PMAPIService.noTrustKit = true
        generateAccessibilityIdentifiers()
    }

    // MARK: - Actions

    @IBAction private func showLogin(_ sender: Any) {

        removePaymentsObserver()
        executeQuarkUnban()

        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }

        if humanVerificationSwitch.isOn {
            HumanVerificationSetup.start(hostUrl: getDoh.getHostUrl())
        } else {
            HumanVerificationSetup.stop()
        }

        login = LoginAndSignup(appName: appName, doh: getDoh, apiServiceDelegate: serviceDelegate, forceUpgradeDelegate: forceUpgradeServiceDelegate, minimumAccountType: getMinimumAccountType, signupMode: getSignumMode, isCloseButtonAvailable: closeButtonSwitch.isOn, planTypes: planSelectorSwitch.isOn ? .mail : nil)

        if let welcomeScreen = getShowWelcomeScreen {
            login?.presentFlowFromWelcomeScreen(
                over: self,
                welcomeScreen: welcomeScreen,
                username: nil,
                performBeforeFlowCompletion: {
                    print("Making additional work at the end of the login flow")
                },
                completion: processLoginResult(_:)
            )
        } else {
            login?.presentLoginFlow(
                over: self,
                performBeforeFlowCompletion: {
                    print("Making additional work at the end of the login flow")
                },
                completion: processLoginResult(_:)
            )
        }
    }

    private func processLoginResult(_ result: LoginResult) {
        switch result {
        case let .loggedIn(data):
            self.data = data
            print("Login OK with data: \(data)")
        case .dismissed:
            self.data = nil
            print("Dismissed by user")
        }
    }

    @IBAction private func showSignup(_ sender: Any) {

        removePaymentsObserver()
        executeQuarkUnban()

        self.data = nil
        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }

        login = LoginAndSignup(appName: appName, doh: getDoh, apiServiceDelegate: serviceDelegate, forceUpgradeDelegate: forceUpgradeServiceDelegate, minimumAccountType: getMinimumAccountType, signupMode: getSignumMode, isCloseButtonAvailable: closeButtonSwitch.isOn, planTypes: planSelectorSwitch.isOn ? .mail : nil)

        login?.presentSignupFlow(
            over: self, performBeforeFlowCompletion: {
                print("Making additional work at the end of the signup flow")
            }
        ) { result in
            switch result {
            case let .loggedIn(data):
                self.data = data
                print("Signup OK with data: \(data)")
            case .dismissed:
                self.data = nil
                print("Dismissed by user")
            }
        }
    }

    @IBAction private func logout(_ sender: Any) {
        guard let data = data else {
            return
        }

        let authCredential: AuthCredential
        switch data {
        case .userData(let userData):
            authCredential = userData.credential
        case .credential(let credential):
            authCredential = AuthCredential(credential)
        }
        login?.logout(credential: authCredential) { result in
            switch result {
            case .success:
                self.data = nil
                let alert = UIAlertController(title: "Logout", message: "Everything OK", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            case let .failure(error):
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

    @IBAction private func mailbox(_ sender: Any) {
        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }

        login = LoginAndSignup(appName: appName,
                        doh: getDoh,
                        apiServiceDelegate: serviceDelegate,
                        forceUpgradeDelegate: forceUpgradeServiceDelegate,
                        minimumAccountType: getMinimumAccountType,
                        signupMode: getSignumMode,
                        isCloseButtonAvailable: closeButtonSwitch.isOn)

        login?.presentMailboxPasswordFlow(over: self) { password in
            let alert = UIAlertController(title: "Mailbox password", message: password, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }

    @IBAction private func clearTransactions(_ sender: Any) {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.add(self)
        clearTransactionsButton.setTitle("Ready to clear any unfinished payments...", for: .normal)
        clearTransactionsButton.setMode(mode: .outlined)
    }

    private func removePaymentsObserver() {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.remove(self)
        clearTransactionsButton.setTitle("Clear unfinished payments", for: .normal)
        clearTransactionsButton.setMode(mode: .solid)
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }

    private var getDoh: DoH & ServerConfig {
        let doh: DoH & ServerConfig
        switch backendSegmentedControl.selectedSegmentIndex {
        case 0:
            doh = LiveDoHMail.default
        case 1:
            doh = BlackDoHMail.default
        case 2:
            doh = ChargaffBlackDevDoHMail.default
        case 3:
            doh = PaymentsBlackDevDoHMail.default
        case 4:
            doh = MauryBlackDevDoHMail.default
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
            HumanVerificationSetup.start(hostUrl: getDoh.getHostUrl())
        } else {
            HumanVerificationSetup.stop()
        }
        return minimumAccountType
    }

    private var getSignumMode: SignupMode {
        switch signupSegmentedControl.selectedSegmentIndex {
        case 0: return .both(initial: .internal)
        case 1: return .both(initial: .external)
        case 2: return .internal
        case 3: return .external
        case 4: return .notAvailable
        default: return .both(initial: .internal)
        }
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

    @IBAction private func signupModeChanged() {
        if getSignumMode == .notAvailable {
            signupButton.isHidden = true
        } else {
            signupButton.isHidden = false
        }
    }

    func executeQuarkUnban() {
        if getDoh.getSignUpString() == LiveDoHMail.default.signupDomain {
            // prevent running on live environment
            return
        }

        let apiService = PMAPIService(doh: getDoh, sessionUID: "SampleAppSessionId")
        apiService.serviceDelegate = serviceDelegate
        let route = QuarkUnbanRequest()
        apiService.exec(route: route) { _, response in
            if response.httpCode == 200 {
                print("Quark Unban request SUCCESS")
            } else {
                print("Quark Unban request error: \(response.httpCode ?? 0)")
            }
        }

        class QuarkUnbanRequest: Request {
            var path: String { return "/internal/quark/jail:unban" }
            var isAuth: Bool { return false }
        }
    }
}

// MARK: - Human verification delegate

extension ViewController: HumanVerifyResponseDelegate {
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

extension ViewController: ForceUpgradeResponseDelegate {
    func onQuitButtonPressed() {
        // on quit button pressed
    }

    func onUpdateButtonPressed() {
        // on update button pressed
    }
}

extension ViewController: SKPaymentTransactionObserver {

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
    }
}
