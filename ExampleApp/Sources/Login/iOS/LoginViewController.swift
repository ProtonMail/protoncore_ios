//
//  LoginViewController.swift
//  ProtonCore-ExampleApp - Created on 03/11/2020.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import UIKit

import StoreKit
import ProtonCoreCryptoGoInterface
#if DEBUG
import OHHTTPStubs
#endif
import ProtonCoreAuthentication
import ProtonCoreAccountDeletion
import ProtonCoreFoundations
import ProtonCoreNetworking
import ProtonCoreUIFoundations
import ProtonCoreForceUpgrade
import ProtonCoreHumanVerification
import ProtonCoreServices
import ProtonCoreAPIClient
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreLoginUI
import ProtonCorePayments
import ProtonCorePaymentsUI
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands
import ProtonCoreFeatureSwitch
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreTroubleShooting
import ProtonCoreEnvironment
import ProtonCoreChallenge
import ProtonCoreMissingScopes
import Foundation
import OHHTTPStubs

final class LoginViewController: UIViewController, AccessibleView {

    // MARK: - Outlets
    @IBOutlet private weak var additionalWork: UISegmentedControl!
    @IBOutlet private weak var alternativeErrorPresenterSwitch: UISwitch!
    @IBOutlet private weak var appNameTextField: UITextField!
    @IBOutlet private weak var clearTransactionsButton: ProtonButton!
    @IBOutlet private weak var closeButtonSwitch: UISwitch!
    @IBOutlet private weak var deleteAccountButton: ProtonButton!
    @IBOutlet private weak var environmentSelector: EnvironmentSelector!
    @IBOutlet private weak var headline: UILabel!
    @IBOutlet private weak var humanVerificationSwitch: UISwitch!
    @IBOutlet private weak var initialErrorSwitch: UISwitch!
    @IBOutlet private weak var loginButton: ProtonButton!
    @IBOutlet private weak var logoutButton: ProtonButton!
    @IBOutlet private weak var mailboxButton: ProtonButton!
    @IBOutlet private weak var planSelectorSwitch: UISwitch!
    @IBOutlet private weak var separateDomainsButton: UISwitch!
    @IBOutlet private weak var separateDomainsButtonView: UIStackView!
    @IBOutlet private weak var showSignupSummaryScreenSwitch: UISwitch!
    @IBOutlet private weak var signupButton: ProtonButton!
    @IBOutlet private weak var simulateIAPFailure: UISwitch!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var verificationEndpointSegmented: UISegmentedControl!
    @IBOutlet private weak var veryStrangeHelpScreenSwitch: UISwitch!
    @IBOutlet private weak var welcomeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var keyMigrationVersionSeg: UISegmentedControl!
    @IBOutlet private weak var inAppThemeSegmentedControl: UISegmentedControl!
    
    private var getInAppTheme: () -> InAppTheme {
        switch inAppThemeSegmentedControl.selectedSegmentIndex {
        case 0: return { .light }
        case 1: return { .dark }
        case 2: return { .matchSystem }
        default: return { .default }
        }
    }
    
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
    private var apiService: PMAPIService?
    private var login: LoginAndSignup?
    private var humanVerificationDelegate: HumanVerifyDelegate?
    private var missingScopesDelegate: MissingScopesDelegate?
    var authManager: AuthHelper?
    var selectedVerificationEndpoint: ProductionVerificationHost {
        get {
            ProductionVerificationHost(rawValue: verificationEndpointSegmented.selectedSegmentIndex) ?? .protonMe
        }
        set {
            verificationEndpointSegmented.selectedSegmentIndex = newValue.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dynamicDomain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"] {
            environmentSelector.switchToCustomDomain(value: dynamicDomain)
            PMLog.info("Filled customDomainTextField with dynamic domain: \(dynamicDomain)")
        } else {
            PMLog.info("Dynamic domain not found, customDomainTextField left unfilled")
        }
        headline.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        logoutButton.setMode(mode: .outlined)
        appNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setMinimumAccountType(accountType: predefinedAccountType)
        deleteAccountButton.setTitle(AccountDeletionService.defaultButtonName, for: .normal)
        populateEndpointSegments()
        verificationEndpointSegmented.apportionsSegmentWidthsByContent = true
        environmentSelector.delegate = self
        generateAccessibilityIdentifiers()
        separateDomainsButtonView.isHidden = false
        setupDefaultValues()
        
        // pre enable features for testing.
        FeatureFactory.shared.loadEnv()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG_CORE_INTERNALS
        simulateIAPFailure.isOn = ProtonCorePayments.TemporaryHacks.simulateBackendPlanPurchaseFailure
        #endif
    }
    
    private func setupDefaultValues() {
        keyMigrationVersionSeg.selectedSegmentIndex = 1
    }

    private func populateEndpointSegments() {
        verificationEndpointSegmented.removeAllSegments()

        ProductionVerificationHost.allCases.forEach {
            verificationEndpointSegmented.insertSegment(withTitle: $0.hostName, at: ProductionVerificationHost.allCases.count, animated: false)
        }
        verificationEndpointSegmented.selectedSegmentIndex = 0
        updateVerificationEndpointEnabledness(with: environmentSelector.currentEnvironment)
    }

    private func updateVerificationEndpointEnabledness(with env: Environment) {
        verificationEndpointSegmented.isEnabled = env == .mailProd || env == .vpnProd
    }
    
    // MARK: - Actions

    @IBAction func ssoAction(_ sender: Any) {
        guard let switcher = sender as? UISwitch else {
            return
        }
        
        if switcher.isOn {
            FeatureFactory.shared.enable(&.ssoSignIn)
        } else {
            FeatureFactory.shared.disable(&.ssoSignIn)
        }
    }
    
    @IBAction func dynamicPlansAction(_ sender: Any) {
        guard let switcher = sender as? UISwitch else {
            return
        }
        
        if switcher.isOn {
            FeatureFactory.shared.enable(&.dynamicPlans)
        } else {
            FeatureFactory.shared.disable(&.dynamicPlans)
        }
    }

    @IBAction private func showLogin(_ sender: Any) {
        removePaymentsObserver()
        let env: Environment = clientApp == .vpn ? .vpnProd : .mailProd
        var prodDoH: DoH & VerificationModifiable = env.dohModifiable
        prodDoH = prodDoH.replacingHumanVerificationV3Host(with: selectedVerificationEndpoint.urlString)

        guard prodDoH.getSignUpString() != prodDoH.signupDomain else {
            showLogin()
            return
        }
        let quarkCommands = QuarkCommands(env: environmentSelector.currentEnvironment)
        quarkCommands.unban { result in
            switch result {
            case .success:
                quarkCommands.disableJail { result in
                    switch result {
                    case .success:
                        self.showLogin()
                    case .failure(let error):
                        PMLog.info("Disable jail error: \(error)")
                    }
                }
            case .failure(let error):
                PMLog.info("Unban error: \(error)")
                self.showLogin()
            }
        }
    }

    private func showLogin() {
        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }
        
        self.setupKeyPhase()
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environmentSelector.currentEnvironment,
                                                                     challengeParametersProvider: ChallengeParametersProvider.forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        self.apiService = apiService
        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(apiService: apiService, inAppTheme: getInAppTheme, clientApp: clientApp)
        apiService.authDelegate = authManager
        apiService.serviceDelegate = serviceDelegate
        apiService.forceUpgradeDelegate = forceUpgradeServiceDelegate
        apiService.humanDelegate = humanVerificationDelegate
        login = LoginAndSignup(
            appName: appName,
            clientApp: clientApp,
            apiService: apiService,
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
                customization: LoginCustomizationOptions(
                    performBeforeFlow: getAdditionalWork,
                    customErrorPresenter: getCustomErrorPresenter,
                    initialError: initialLoginError(),
                    helpDecorator: getHelpDecorator,
                    inAppTheme: getInAppTheme
                ),
                updateBlock: processLoginResult(_:)
            )
        } else {
            login?.presentLoginFlow(
                over: self,
                customization: LoginCustomizationOptions(
                    performBeforeFlow: getAdditionalWork,
                    customErrorPresenter: getCustomErrorPresenter,
                    initialError: initialLoginError(),
                    helpDecorator: getHelpDecorator,
                    inAppTheme: getInAppTheme
                ),
                updateBlock: processLoginResult(_:)
            )
        }
    }

    private func processLoginResult(_ result: LoginAndSignupResult) {
        switch result {
        case .loginStateChanged(.loginFinished):
            login = nil
            PMLog.info("Login OK")
        case .signupStateChanged(.signupFinished):
            login = nil
            PMLog.info("Signup OK")
        case .loginStateChanged(.dataIsAvailable(let loginData)), .signupStateChanged(.dataIsAvailable(let loginData)):
            data = loginData
            authManager?.onSessionObtaining(credential: loginData.getCredential)
            PMLog.info("Login data: \(loginData)")
        case .dismissed:
            data = nil
            login = nil
            PMLog.info("Dismissed by user")
        }
    }

    @IBAction private func showSignup(_ sender: Any) {

        removePaymentsObserver()
        
        let env: Environment = clientApp == .vpn ? .vpnProd : .mailProd
        
        var prodDoH: DoH & VerificationModifiable = env.dohModifiable
        prodDoH = prodDoH.replacingHumanVerificationV3Host(with: selectedVerificationEndpoint.urlString)

        guard prodDoH.getSignUpString() != prodDoH.signupDomain else {
            showSignup()
            return
        }
        let quarkCommands = QuarkCommands(env: environmentSelector.currentEnvironment)
        quarkCommands.unban { result in
            switch result {
            case .success:
                quarkCommands.disableJail { result in
                    switch result {
                    case .success:
                        self.showSignup()
                    case .failure(let error):
                        PMLog.info("Disable jail error: \(error)")
                    }
                }
            case .failure(let error):
                PMLog.info("Unban error: \(error)")
                self.showSignup()
            }
        }
    }
    
    private func showSignup() {
        self.data = nil
        guard let appName = appNameTextField.text, !appName.isEmpty else {
            return
        }
    
        self.setupKeyPhase()
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environmentSelector.currentEnvironment,
                                                                     challengeParametersProvider: ChallengeParametersProvider.forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        self.apiService = apiService
        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(apiService: apiService, inAppTheme: getInAppTheme, clientApp: clientApp)
        self.missingScopesDelegate = MissingScopesHandler(apiService: apiService, inAppTheme: getInAppTheme)
        apiService.authDelegate = authManager
        apiService.serviceDelegate = serviceDelegate
        apiService.forceUpgradeDelegate = forceUpgradeServiceDelegate
        apiService.humanDelegate = humanVerificationDelegate
        apiService.missingScopesDelegate = missingScopesDelegate
        login = LoginAndSignup(
            appName: appName,
            clientApp: clientApp,
            apiService: apiService,
            minimumAccountType: getMinimumAccountType,
            isCloseButtonAvailable: closeButtonSwitch.isOn,
            paymentsAvailability: planSelectorSwitch.isOn
            ? .available(parameters: .init(listOfIAPIdentifiers: listOfIAPIdentifiers, listOfShownPlanNames: listOfShownPlanNames, reportBugAlertHandler: reportBugAlertHandler))
                : .notAvailable,
            signupAvailability: getSignupAvailability
        )
        
        login?.presentSignupFlow(
            over: self,
            customization: LoginCustomizationOptions(performBeforeFlow: getAdditionalWork,
                                                     customErrorPresenter: getCustomErrorPresenter,
                                                     initialError: initialLoginError(),
                                                     helpDecorator: getHelpDecorator,
                                                     inAppTheme: getInAppTheme)
        ) { (result: LoginAndSignupResult) in
            switch result {
            case .loginStateChanged(.loginFinished):
                self.login = nil
                PMLog.info("Login OK")
            case .signupStateChanged(.signupFinished):
                self.login = nil
                PMLog.info("Signup OK")
            case .loginStateChanged(.dataIsAvailable(let loginData)), .signupStateChanged(.dataIsAvailable(let loginData)):
                self.data = loginData
                PMLog.info("Login data: \(loginData)")
            case .dismissed:
                self.data = nil
                self.login = nil
                PMLog.info("Dismissed by user")
            }
        }
    }
    
    private func reportBugAlertHandler(_ receipt: String?) {
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

    private var windowScene: UIWindowScene? {
        UIApplication.getInstance()?.connectedScenes.first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }

    private lazy var alertWindow: UIWindow? = {
        let alertWindow: UIWindow?
        if let windowScene = windowScene {
            alertWindow = UIWindow(windowScene: windowScene)
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
        data?.credential
    }

    @IBAction private func logout(_ sender: Any) {
        guard let authCredential = currentAuthCredential else { return }
        guard let appName = appNameTextField.text, !appName.isEmpty else { return }
        
        self.setupKeyPhase()
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environmentSelector.currentEnvironment,
                                                                     challengeParametersProvider: ChallengeParametersProvider.forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        self.apiService = apiService
        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(apiService: apiService, inAppTheme: getInAppTheme, clientApp: clientApp)
        apiService.authDelegate = authManager
        apiService.serviceDelegate = serviceDelegate
        apiService.forceUpgradeDelegate = forceUpgradeServiceDelegate
        apiService.humanDelegate = humanVerificationDelegate
        login = LoginAndSignup(
            appName: appName,
            clientApp: clientApp,
            apiService: apiService,
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
                let alert: UIAlertController
                var message = "Failed with \(error.localizedDescription)"
                if case AuthErrors.networkingError(let err) = error, err.httpCode == 401 {
                    // Invalid access token
                    self.data = nil
                    message = "Invalid access token logout"
                    alert = UIAlertController(title: "Logout", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                } else if case AuthErrors.apiMightBeBlocked(let errorMessage, _) = error {
                    // Invalid access token
                    message = errorMessage
                    alert = UIAlertController(title: "Logout", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: LUITranslation._core_api_might_be_blocked_button.l10n, style: .default, handler: { _ in
                        self.serviceDelegate.onDohTroubleshot()
                        // option #1
                        let helper = TroubleShootingHelper(doh: self.environmentSelector.currentEnvironment.doh)
                        helper.showTroubleShooting(over: self)
                        // option #2
                        // self.present(doh: self.environmentSelector.currentDoh)
                        
                    }))
                } else {
                    alert = UIAlertController(title: "Logout", message: error.localizedDescription
                                              , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction private func deleteAccount(_ sender: Any) {
        guard let credential = data?.getCredential else { return }
        let api = PMAPIService.createAPIService(environment: environmentSelector.currentEnvironment,
                                                sessionUID: credential.UID,
                                                challengeParametersProvider: .forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        self.humanVerificationDelegate = HumanCheckHelper(apiService: api, inAppTheme: getInAppTheme, clientApp: clientApp)
        authManager?.onUpdate(credential: credential, sessionUID: api.sessionUID)
        api.authDelegate = authManager
        api.serviceDelegate = serviceDelegate
        api.forceUpgradeDelegate = forceUpgradeServiceDelegate
        api.humanDelegate = humanVerificationDelegate
        let accountDeletion = AccountDeletionService(api: api)
        accountDeletion.initiateAccountDeletionProcess(over: self) { [weak self] result in
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
        
        self.setupKeyPhase()
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environmentSelector.currentEnvironment,
                                                                     challengeParametersProvider: ChallengeParametersProvider.forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        self.apiService = apiService
        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(apiService: apiService, inAppTheme: getInAppTheme, clientApp: clientApp)
        apiService.authDelegate = authManager
        apiService.serviceDelegate = serviceDelegate
        apiService.forceUpgradeDelegate = forceUpgradeServiceDelegate
        apiService.humanDelegate = humanVerificationDelegate
        login = LoginAndSignup(appName: appName,
                               clientApp: clientApp,
                               apiService: apiService,
                               minimumAccountType: getMinimumAccountType,
                               isCloseButtonAvailable: closeButtonSwitch.isOn,
                               paymentsAvailability: .notAvailable,
                               signupAvailability: .notAvailable)

        login?.presentMailboxPasswordFlow(over: self, inAppTheme: getInAppTheme()) { password in
            self.login = nil
            let alert = UIAlertController(title: "Mailbox password", message: password, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction private func clearCookies(_ sender: Any) {
        let cookieStorage = HTTPCookieStorage.shared
        if let allCookies = cookieStorage.cookies {
            for cookie in allCookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
        cookieStorage.removeCookies(since: .distantPast)
        let alert = UIAlertController(title: "Cookies cleared", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Good", style: .default, handler: nil))
        DispatchQueue.main.async { self.present(alert, animated: true) }
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

    private func initialLoginError() -> String? {
        initialErrorSwitch.isOn ? "Error Message" : nil
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
    
    private func setupKeyPhase() {
        let isKeyPhaseV2on = keyMigrationVersionSeg.selectedSegmentIndex == 1
        FeatureFactory.shared.setEnabled(&.useKeymigrationPhaseV2, isEnable: isKeyPhaseV2on)
    }
    
    private var getMinimumAccountType: AccountType {
        let minimumAccountType: AccountType
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            minimumAccountType = .username
        case 1:
            minimumAccountType = .external
        case 2:
            minimumAccountType = .internal
        default:
            fatalError("Invalid index")
        }
        LoginMockingSetup.start(hostUrl: environmentSelector.currentEnvironment.doh.getCurrentlyUsedHostUrl(),
                                shouldMockHumanVerification: humanVerificationSwitch.isOn)
        return minimumAccountType
    }
    
    private func setMinimumAccountType(accountType: AccountType?) {
        guard let accountType = accountType else { return }
        switch accountType {
        case .username:
            typeSegmentedControl.selectedSegmentIndex = 0
        case .external:
            typeSegmentedControl.selectedSegmentIndex = 1
        case .internal:
            typeSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    private var getSignupAvailability: SignupAvailability {
        let signupAvailability: SignupAvailability
        let summaryScreenVariant: SummaryScreenVariant = showSignupSummaryScreenSwitch.isOn ? signupSummaryScreenVariant : .noSummaryScreen
        signupAvailability = .available(parameters: SignupParameters(separateDomainsButton: separateDomainsButton.isOn,
                                                                     passwordRestrictions: .default,
                                                                     summaryScreenVariant: summaryScreenVariant))
        return signupAvailability
    }

    private var getShowWelcomeScreen: WelcomeScreenVariant? {
        switch welcomeSegmentedControl.selectedSegmentIndex {
        case 0: return nil
        case 1: return .mail(.init(body: "Please Mister Postman, look and see! Is there's a letter in your bag for me?"))
        case 2: return .vpn(.init(body: "I know you've been hurt by someone else. I can tell by the way you carry yourself. But if you let me, here's what I'll do: I'll take care of you"))
        case 3: return .drive(.init(body: "Drive me to the moon and let me play among the stars. Let me see what spring is like on Jupiter and Mars"))
        case 4: return .calendar(.init(body: "I don't care if Monday's blue. Tuesday's grey and Wednesday too. Thursday, I don't care about you. It's Friday, I'm in love"))
        default: return nil
        }
    }

    private var getAdditionalWork: WorkBeforeFlow? {
        switch additionalWork.selectedSegmentIndex {
        case 0: return nil
        case 1: return WorkBeforeFlow(stepName: "Additional work creation...") { loginData, flowCompletion in
            PMLog.info("\(Date()) Making additional work at the end of the flow")
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(10)
                PMLog.info("\(Date()) Making additional work at the end of the flow")
                flowCompletion(.success(()))
            }
        }
        case 2: return WorkBeforeFlow(stepName: "Additional work creation...") { loginData, flowCompletion in
            PMLog.info("\(Date()) Making additional work at the end of the flow")
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(10)
                PMLog.info("\(Date()) Making additional work at the end of the flow")
                flowCompletion(.failure(SomeVeryObscureInternalError()))
            }
        }
        default: fatalError("no more clients expected")
        }
    }
    
    private var getCustomErrorPresenter: LoginErrorPresenter? {
        guard alternativeErrorPresenterSwitch.isOn else { return nil }
        return AlternativeLoginErrorPresenter()
    }
    
    private var getHelpDecorator: ([[HelpItem]]) -> [[HelpItem]] {
        guard veryStrangeHelpScreenSwitch.isOn else { return { $0 } }
        return { [weak self] _ in
            [
                [
                    HelpItem.staticText(text: "🍌🍌🍌 Bananas 🍌🍌🍌"),
                    HelpItem.custom(icon: IconProvider.eyeSlash,
                                    title: "Look ma, I'm a pirate! 🏴‍☠️",
                                    behaviour: { _ in
                                        UIApplication.openURLIfPossible(URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/8c/Treasure-Island-map.jpg")!) }),
                    HelpItem.otherIssues
                ],
                [
                    HelpItem.support,
                    HelpItem.staticText(text: "Have you ever seen a living dinosaur? I have"),
                    HelpItem.custom(icon: IconProvider.mobile,
                                    title: "Hello?",
                                    behaviour: { [weak self] vc in
                                        self?.showAlert(title: "Hello?",
                                                       message: "Is it me you're looking for?",
                                                       actionTitle: "Nope",
                                                       actionBlock: {
                                            UIApplication.openURLIfPossible(URL(string: "https://www.youtube.com/watch?v=bfBu2rV-aYs")!)
                                        },
                                                       over: vc)
                                    })
                ]
            ]
        }
    }
    
    func showAlert(
        title: String,
        message: String,
        actionTitle: String,
        actionBlock: @escaping () -> Void = {},
        over: UIViewController
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: { action in
            actionBlock()
            alert.dismiss(animated: true, completion: nil)
        }))
        over.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func simulateBackendPlanPurchaseFailureSwitchValueChanged(_ sender: UISwitch) {
        #if !SPM && DEBUG_CORE_INTERNALS
        ProtonCorePayments.TemporaryHacks.simulateBackendPlanPurchaseFailure = sender.isOn
        #endif
    }
}

enum ProductionVerificationHost: Int, CaseIterable {
    case protonMe
    case protonMail
    case protonVPN

    var hostName: String {
        switch self {
        case .protonMe: return "proton.me"
        case .protonMail: return "protonmail.com"
        case .protonVPN: return "protonvpn.com"
        }
    }

    var urlString: String {
        "https://verify." + hostName
    }
}

// MARK: - Human verification delegate

extension LoginViewController: HumanVerifyResponseDelegate {
    func onHumanVerifyStart() {
        PMLog.info("Human verify start")
    }

    func onHumanVerifyEnd(result: HumanVerifyEndResult) {
        switch result {
        case .success:
            PMLog.info("Human verify success")
        case .cancel:
            PMLog.info("Human verify cancel")
        }
    }
    
    func humanVerifyToken(token: String?, tokenType: String?) {
        PMLog.info("Human verify token: \(String(describing: token)), type: \(String(describing: tokenType))")
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
        PMLog.info(#function)
        guard !queue.transactions.isEmpty else {
            PMLog.info("There are no transactions to be cleared")
            return
        }
        queue.transactions.forEach {
            PMLog.info("Clearing transaction for \($0.payment.productIdentifier)")
            queue.finishTransaction($0)
        }
        removePaymentsObserver()
        clearTransactionsButton.setTitle("Unfinished transactions cleared, tap to check more", for: .normal)
    }
}

extension LoginViewController: EnvironmentSelectorDelegate {
    func environmentChanged(to env: Environment) {
        updateVerificationEndpointEnabledness(with: env)
    }
}

struct SomeVeryObscureInternalError: Error {}

final class AlternativeLoginErrorPresenter: LoginErrorPresenter {
    
    func showAlert(message: String, over: UIViewController) {
        let alert = UIAlertController(title: "The magnificent alternative error presenter proudly presents", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Well, that's a shame", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        over.present(alert, animated: true, completion: nil)
    }
    
    func willPresentError(error: LoginError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: SignupError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: AvailabilityError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.localizedDescription, over: viewController)
        return true
    }
    
    func willPresentError(error: SetUsernameError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: CreateAddressError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: CreateAddressKeysError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: StoreKitManagerErrors, from viewController: UIViewController) -> Bool {
        if case .unknown(_, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInPayments, over: viewController)
        return true
    }
    
    func willPresentError(error: ResponseError, from viewController: UIViewController) -> Bool {
        if error.underlyingError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.localizedDescription, over: viewController)
        return true
    }
    
    func willPresentError(error: Error, from viewController: UIViewController) -> Bool {
        if error is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.localizedDescription, over: viewController)
        return true
    }
}
