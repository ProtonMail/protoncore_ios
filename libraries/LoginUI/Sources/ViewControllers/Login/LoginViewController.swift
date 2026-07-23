//
//  LoginViewController.swift
//  ProtonCore-Login - Created on 03/11/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
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

#if os(iOS)

import UIKit
import AuthenticationServices

import ProtonCoreFeatureFlags
import ProtonCoreFoundations
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreObservability
import ProtonCoreServices
import ProtonCoreTelemetry
import ProtonCoreUIFoundations

// Notify delegate of next steps to present to the user
protocol LoginStepsDelegate: AnyObject {
    /// informs delegate that it should present UI to request a TOTP code from the user
    func requestTOTPCode(username: String, password: String, providerDelegate: TwoFAProviderDelegate?)
    @available(iOS 15.0, *)
    /// informs delegate that it should present UI to request a Security Key from the user
    func requestKeySignature(authenticationOptions: AuthenticationOptions, providerDelegate: TwoFAProviderDelegate?)
    @available(iOS 15.0, *)
    /// informs delegate that it should present UI to request either a TOTP code or a Security Key from the user
    func requestTOTPOrKeySignature(username: String, password: String, authenticationOptions: AuthenticationOptions, providerDelegate: TwoFAProviderDelegate?)
    func mailboxPasswordNeeded()
    func createAddressNeeded(data: CreateAddressData, defaultUsername: String?)
    func userAccountSetupNeeded()
    func firstPasswordChangeNeeded()
    func learnMoreAboutExternalAccountsNotSupported()

    /// SSO
    func ssoAccountSetupNeeded(data: LoginData)
}

/// Notify delegate of Login related events
protocol LoginViewControllerDelegate: LoginStepsDelegate {
    func userDidDismissLoginViewController()
    func userDidRequestSignup()
    func userDidRequestHelp()
    /// informs the caller the login process has concluded and provides it with the UserData corresponding to the logged-in user
    func loginViewControllerDidFinish(endLoading: @escaping () -> Void, data: LoginData)
}

final class LoginViewController: UIViewController, AccessibleView, Focusable, ProductMetricsMeasurable {
    var productMetrics: ProductMetrics = .init(
        group: TelemetryMeasurementGroup.signUp.rawValue,
        flow: TelemetryFlow.signUpFull.rawValue,
        screen: .signin
    )

    enum MeasureConstants {
        static let resultFailure = "failure"
        static let resultSuccess = "success"
        static let hostAlternative = "alternative"
        static let hostStandard = "standard"
    }

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var loginTextField: PMTextField!
    @IBOutlet private weak var passwordTextField: PMTextField!
    @IBOutlet private weak var signInButton: ProtonButton!
    @IBOutlet private weak var signUpButton: ProtonButton!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var brandImage: UIImageView!
    @IBOutlet weak var signInWithSSOButton: ProtonButton!

    // MARK: - Properties

    weak var delegate: LoginViewControllerDelegate?
    var initialError: LoginError?
    /// Evaluated when the screen appears so the banner reflects the current state
    var loginScreenBannerProvider: (() -> LoginScreenBanner?)?
    /// The banner currently displayed, used to drive the blocking-alert interception.
    private var loginScreenBanner: LoginScreenBanner?
    var showCloseButton = true
    var isSignupAvailable = true

    var viewModel: LoginViewModel!
    var customErrorPresenter: LoginErrorPresenter?
    var initialUsername: String?
    var onDohTroubleshooting: () -> Void = { }

    var focusNoMore: Bool = false
    private let navigationBarAdjuster = NavigationBarAdjustingScrollViewDelegate()
    private var authSession: ASWebAuthenticationSession?
    private var isSSOEnabled: Bool {
        FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.externalSSO, reloadValue: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { darkModeAwarePreferredStatusBarStyle() }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
        setupDelegates()
        setupNotifications()
        setupGestures()
        setUpHelpButton(action: #selector(needHelpPressed))
        requestDomain()
        if let error = initialError {
            if self.customErrorPresenter?.willPresentError(error: error, from: self) == true { } else { showError(error: error) }
        }

        if let banner = loginScreenBannerProvider?() {
            renderLoginScreenBanner(banner)
        }

        focusOnce(view: loginTextField, delay: .milliseconds(750))

        setUpCloseButton(showCloseButton: showCloseButton, action: #selector(closePressed))

        generateAccessibilityIdentifiers()
    }

    /// Renders an opt-in ``LoginScreenBanner`` pinned to the top of the login screen. Tapping the action
    /// (if any) runs the client's handler and shows the follow-up banner it returns, if any.
    private func renderLoginScreenBanner(_ banner: LoginScreenBanner) {
        loginScreenBanner = banner
        let style: PMBannerNewStyle = banner.style == .error ? .error : .success
        if let actionTitle = banner.actionTitle, let action = banner.action {
            // Banners should not be dismissable if interacting with them is essential to getting back online.
            showBanner(message: banner.message, style: style, button: actionTitle, position: .top, dismissable: banner.blockingAlert == nil) { [weak self] in
                Task { @MainActor in
                    let nextBanner = await action()
                    self?.loginScreenBanner = nextBanner
                    if let nextBanner { self?.renderLoginScreenBanner(nextBanner) }
                }
            }
        } else {
            showBannerWithoutButton(message: banner.message, style: style, position: .top)
        }
    }

    /// If the login-screen banner is currently blocking, presents its confirmation (e.g. "turn off kill
    /// switch") instead of letting a primary action proceed. Returns `true` when it intercepted the action.
    private func presentLoginScreenBlockingAlertIfNeeded() -> Bool {
        guard let banner = loginScreenBanner, let blockingAlert = banner.blockingAlert else { return false }
        let alert = UIAlertController(title: blockingAlert.title, message: blockingAlert.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: blockingAlert.cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: blockingAlert.confirmTitle, style: .default) { [weak self] _ in
            Task { @MainActor in
                let nextBanner = await banner.action?() ?? nil
                self?.loginScreenBanner = nextBanner
                if let nextBanner { self?.renderLoginScreenBanner(nextBanner) }
            }
        })
        present(alert, animated: true)
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarAdjuster.setUp(for: scrollView, shouldAdjustNavigationBar: showCloseButton, parent: parent)
        scrollView.adjust(forKeyboardVisibilityNotification: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        measureOnViewDisplayed()
    }

    // MARK: - Setup

    private func setupUI() {
        brandImage.image = IconProvider.masterBrandGlyph
        brandImage.isHidden = false
        titleLabel.text = viewModel.titleLabel
        titleLabel.textColor = ColorProvider.TextNorm
        subtitleLabel.text = viewModel.subtitleLabel
        subtitleLabel.textColor = ColorProvider.TextWeak
        titleLabel.font = .adjustedFont(forTextStyle: .title2, weight: .bold)
        subtitleLabel.font = .adjustedFont(forTextStyle: .subheadline)
        loginTextField.title = viewModel.loginTextFieldTitle
        passwordTextField.title = viewModel.passwordTextFieldTitle

        view.backgroundColor = ColorProvider.BackgroundNorm

        signInButton.setTitle(viewModel.signInButtonTitle, for: .normal)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)

        signUpButton.setMode(mode: .text)
        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        signUpButton.isHidden = !isSignupAvailable
        signUpButton.setTitle(viewModel.signUpButtonTitle, for: .normal)

        loginTextField.autocorrectionType = .no
        loginTextField.autocapitalizationType = .none
        loginTextField.textContentType = .username
        loginTextField.keyboardType = .emailAddress
        loginTextField.returnKeyType = .next

        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.textContentType = .password

        loginTextField.value = initialUsername ?? ""

        signInWithSSOButton.isHidden = !isSSOEnabled
        signInWithSSOButton.setTitle(viewModel.signInWithSSOButtonTitle, for: .normal)
        signInWithSSOButton.setMode(mode: .text)
        signInWithSSOButton.addTarget(self, action: #selector(signInWithSSO), for: .touchUpInside)
    }

    private func requestDomain() {
        viewModel.updateAvailableDomain()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    func setUpHelpButton(action: Selector) {
        let helpButton = UIBarButtonItem(title: LUITranslation._core_help_button.l10n, style: .plain, target: self, action: action)
        helpButton.tintColor = ColorProvider.InteractionNorm
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.setRightBarButton(helpButton, animated: true)
        navigationItem.assignNavItemIndentifiers()
    }

    private func setupDelegates() {
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }

    /// Starts listening to the viewModel publishers and launches actions to handle the values sent
    private func setupBinding() {
        viewModel.error.bind { [weak self] error in
            guard let self else { return }
            switch error {
            case .invalidCredentials:
                self.setError(textField: self.passwordTextField, error: nil)
                self.setError(textField: self.loginTextField, error: nil)
                if self.customErrorPresenter?.willPresentError(error: error, from: self) == true { } else { self.showError(error: error) }
            default:
                if self.customErrorPresenter?.willPresentError(error: error, from: self) == true { } else { self.showError(error: error) }
            }
            self.measureLoginFailure(httpCode: error.codeInLogin)
        }
        viewModel.finished.bind { [weak self] result in
            switch result {
            case let .done(data):
                self?.delegate?.loginViewControllerDidFinish(endLoading: { [weak self] in self?.viewModel.isLoading.value = false }, data: data)
                self?.measureLoginSuccess()
            case let .ssoAuthorized(data):
                self?.viewModel.isLoading.value = false
                self?.delegate?.ssoAccountSetupNeeded(data: data)
            case .totpCodeNeeded:
                guard
                    let username = self?.loginTextField.value,
                    let password = self?.passwordTextField.value
                else { return }
                // Clean username and password before leaving this page
                // To eliminate KeyChain auto remember prompt
                self?.clearAccount()
                self?.delegate?.requestTOTPCode(username: username, password: password, providerDelegate: self?.viewModel)
                self?.measureLoginSuccess()
            case let .fido2KeyNeeded(authenticationOptions):
                self?.clearAccount()
                guard #available(iOS 15.0, *) else {
                    self?.showBanner(message: "FIDO2 security keys are not supported in iOS versions prior to 15.0", style: .error)
                    self?.measureLoginFailure(httpCode: 426)
                    return
                }

                self?.delegate?.requestKeySignature(authenticationOptions: authenticationOptions,
                                                    providerDelegate: self?.viewModel)
            case let .anyOfFido2TotpNeeded(authenticationOptions):
                self?.clearAccount()
                guard #available(iOS 15.0, *) else {
                    if let username = self?.loginTextField.value,
                       let password = self?.passwordTextField.value {
                        self?.delegate?.requestTOTPCode(username: username, password: password, providerDelegate: self?.viewModel)
                        self?.measureLoginSuccess()
                    }
                    return
                }

                guard let username = self?.loginTextField.value,
                      let password = self?.passwordTextField.value
                else {
                    self?.delegate?.requestKeySignature(authenticationOptions: authenticationOptions,
                                                        providerDelegate: self?.viewModel)
                    return
                }

                self?.delegate?.requestTOTPOrKeySignature(username: username,
                                                          password: password,
                                                          authenticationOptions: authenticationOptions,
                                                          providerDelegate: self?.viewModel)
            case .mailboxPasswordNeeded:
                self?.delegate?.mailboxPasswordNeeded()
                self?.measureLoginSuccess()
            case let .createAddressNeeded(data, defaultUsername):
                self?.delegate?.createAddressNeeded(data: data, defaultUsername: defaultUsername)
                self?.measureLoginSuccess()
            case .ssoChallenge(let ssoChallengeResponse):
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    let ssoURLResult = await self.viewModel.getSSOURL(challenge: ssoChallengeResponse)
                    if let error = ssoURLResult.error {
                        self.showBanner(message: error)
                        return
                    }
                    guard let ssoURL = ssoURLResult.url,
                          let callbackScheme = self.viewModel.ssoCallbackScheme else {
                        self.showBanner(message: LUITranslation.sso_configuration_error.l10n)
                        return
                    }
                    self.startSSOAuthSession(url: ssoURL, callbackScheme: callbackScheme)
                }
                self?.measureLoginSuccess()
            case .switchToSSOLogin(let info):
                self?.showBanner(message: info, style: .info)
                self?.signInWithSSO()
                self?.measureLoginFailure(httpCode: APIErrorCode.switchToSSOError)
            }
        }
        viewModel.isLoading.bind { [weak self] isLoading in
            self?.view.isUserInteractionEnabled = !isLoading
            self?.signInButton.isSelected = isLoading
        }
        viewModel.challenge.reset()
        try? self.loginTextField.setUpChallenge(viewModel.challenge, type: .username)

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(preferredContentSizeChanged(_:)),
                         name: UIContentSizeCategory.didChangeNotification,
                         object: nil)
    }

    // MARK: - Actions

    @objc private func signInWithSSO() {
        guard !presentLoginScreenBlockingAlertIfNeeded() else { return }
        viewModel.isSsoUIEnabled = true
        passwordTextField.isHidden = viewModel.isSsoUIEnabled
        loginTextField.title = viewModel.loginTextFieldTitle
        titleLabel.text = viewModel.titleLabel
        signInWithSSOButton.setTitle(viewModel.signInWithSSOButtonTitle, for: .normal)
        signInWithSSOButton.removeTarget(self, action: #selector(signInWithSSO), for: .touchUpInside)
        signInWithSSOButton.addTarget(self, action: #selector(signInWithEmail), for: .touchUpInside)
    }

    @objc private func signInWithEmail() {
        guard !presentLoginScreenBlockingAlertIfNeeded() else { return }
        viewModel.isSsoUIEnabled = false
        passwordTextField.isHidden = viewModel.isSsoUIEnabled
        loginTextField.title = viewModel.loginTextFieldTitle
        titleLabel.text = viewModel.titleLabel
        signInWithSSOButton.setTitle(viewModel.signInWithSSOButtonTitle, for: .normal)
        signInWithSSOButton.removeTarget(self, action: #selector(signInWithEmail), for: .touchUpInside)
        signInWithSSOButton.addTarget(self, action: #selector(signInWithSSO), for: .touchUpInside)
    }

    @objc private func signInPressed(_ sender: Any) {
        guard !presentLoginScreenBlockingAlertIfNeeded() else { return }
        cancelFocus()
        dismissKeyboard()

        let usernameValid = setAddressTextFieldError()
        let passwordValid = validatePassword()

        guard usernameValid else {
            return
        }

        guard (passwordTextField.isHidden == false && passwordValid) || isSSOEnabled else {
            return
        }

        PMBanner.dismissAll(on: self)
        viewModel.login(username: loginTextField.value, password: passwordTextField.value)
    }

    @objc private func signUpPressed(_ sender: ProtonButton) {
        guard !presentLoginScreenBlockingAlertIfNeeded() else { return }
        cancelFocus()
        clearAccount()
        delegate?.userDidRequestSignup()
        measureOnViewClicked(item: "sign_up")
    }

    @objc private func needHelpPressed() {
        cancelFocus()
        delegate?.userDidRequestHelp()
        measureOnViewClicked(item: "help")
    }

    @objc private func closePressed(_ sender: Any) {
        cancelFocus()
        delegate?.userDidDismissLoginViewController()
        measureOnViewClosed()
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        if loginTextField.isFirstResponder {
            _ = loginTextField.resignFirstResponder()
        }

        if passwordTextField.isFirstResponder {
            _ = passwordTextField.resignFirstResponder()
        }
    }

    private func clearAccount() {
        passwordTextField.value = ""
        loginTextField.value = ""
    }

    @objc
    private func preferredContentSizeChanged(_ notification: Notification) {
        guard DFSSetting.enableDFS else { return }
        titleLabel.font = .adjustedFont(forTextStyle: .title2, weight: .bold)
        subtitleLabel.font = .adjustedFont(forTextStyle: .subheadline)
    }

    // MARK: - Keyboard

    private func setupNotifications() {
        NotificationCenter.default
            .setupKeyboardNotifications(target: self, show: #selector(keyboardWillShow), hide: #selector(keyboardWillHide))
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        adjust(scrollView, notification: notification,
               topView: topView(of: loginTextField, passwordTextField),
               bottomView: signUpButton)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        adjust(scrollView, notification: notification, topView: titleLabel, bottomView: signUpButton)
    }

    // MARK: - Validation

    @discardableResult
    private func setAddressTextFieldError() -> Bool {
        var addressFieldIsValid: Result<(), LoginValidationError>
        if viewModel.isSsoUIEnabled {
            addressFieldIsValid = viewModel.validate(email: loginTextField.value)
        } else {
            addressFieldIsValid = viewModel.validate(username: loginTextField.value)
        }
        switch addressFieldIsValid {
        case let .failure(error):
            setError(textField: loginTextField, error: error)
            return false
        case .success:
            clearError(textField: loginTextField)
            return true
        }
    }

    @discardableResult
    private func validatePassword() -> Bool {
        let passwordValid = viewModel.validate(password: passwordTextField.value)
        switch passwordValid {
        case let .failure(error):
            setError(textField: passwordTextField, error: error)
            return false
        case .success:
            clearError(textField: passwordTextField)
            return true
        }
    }
}

// MARK: - Text field delegate

extension LoginViewController: PMTextFieldDelegate {

    func didChangeValue(_ textField: PMTextField, value: String) {}

    func textFieldShouldReturn(_ textField: PMTextField) -> Bool {
        if textField == loginTextField {
            _ = passwordTextField.becomeFirstResponder()
        } else {
            _ = textField.resignFirstResponder()
        }
        return true
    }

    func didBeginEditing(textField: PMTextField) {
        switch textField {
        case loginTextField:
            measureOnViewFocused(item: "username")
        case passwordTextField:
            measureOnViewFocused(item: "password")
        default:
            break
        }
    }

    func didEndEditing(textField: PMTextField) {
        switch textField {
        case loginTextField:
            setAddressTextFieldError()
        case passwordTextField:
            validatePassword()
        default:
            break
        }
    }
}

// MARK: - ASWebAuthenticationSession SSO

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window ?? ASPresentationAnchor()
    }
}

extension LoginViewController {
    fileprivate func startSSOAuthSession(url: URL, callbackScheme: String) {
        authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
            self?.handleSSOAuthSessionCompletion(callbackURL: callbackURL, error: error)
        }
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = true
        authSession?.start()
    }

    func handleSSOAuthSessionCompletion(callbackURL: URL?, error: Error?) {
        defer { authSession = nil }

        // Handle cancelation
        if let error = error as? ASWebAuthenticationSessionError,
           error.code == .canceledLogin {
            ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .canceled))
            return
        }

        // Handle other errors
        if let error {
            ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
            PMLog.error(error.localizedDescription, sendToExternal: true)
            showBanner(message: error.localizedDescription)
            return
        }

        // Handle missing callback URL or token
        guard let callbackURL,
              let responseToken = viewModel.getSSOTokenFromURL(url: callbackURL) else {
            ObservabilityEnv.report(.ssoIdentityProviderLoginResult(status: .failed))
            PMLog.error(LUITranslation.sso_response_token_error.l10n, sendToExternal: true)
            showBanner(message: LUITranslation.sso_response_token_error.l10n)
            return
        }

        viewModel.processResponseTokenV2(idpEmail: loginTextField.value, responseToken: responseToken)
    }
}

// MARK: - Additional errors handling

extension LoginViewController: LoginErrorCapable {

    func onUserAccountSetupNeeded() {
        delegate?.userAccountSetupNeeded()
    }

    func onFirstPasswordChangeNeeded() {
        delegate?.firstPasswordChangeNeeded()
    }

    func onLearnMoreAboutExternalAccountsNotSupported() {
        delegate?.learnMoreAboutExternalAccountsNotSupported()
    }

    var bannerPosition: PMBannerPosition { .top }
}

// MARK: - Product Metrics

extension LoginViewController {
    private func measureLoginSuccess() {
        measureAPIResult(
            action: .auth,
            additionalDimensions: [
                .result(MeasureConstants.resultSuccess),
                .hostType(viewModel.isCurrentlyUsingProxyDomain ? MeasureConstants.hostAlternative : MeasureConstants.hostStandard)
            ]
        )
    }

    private func measureLoginFailure(httpCode: Int) {
        measureAPIResult(
            action: .auth,
            additionalValues: [.httpCode(httpCode)],
            additionalDimensions: [
                .result(MeasureConstants.resultFailure),
                .hostType(viewModel.isCurrentlyUsingProxyDomain ? MeasureConstants.hostAlternative : MeasureConstants.hostStandard)
            ]
        )
    }
}
#endif
