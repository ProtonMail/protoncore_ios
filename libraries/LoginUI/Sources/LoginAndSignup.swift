//
//  LoginAndSignup.swift
//  ProtonCore-Login - Created on 12/11/2020.
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
import enum ProtonCoreDataModel.ClientApp
import ProtonCoreLogin
import ProtonCoreNetworking
import ProtonCoreServices
import enum ProtonCorePayments.StoreKitManagerErrors
import ProtonCoreUIFoundations

public enum ScreenVariant<SpecificScreenData, CustomScreenData> {
    case mail(SpecificScreenData)
    case calendar(SpecificScreenData)
    case drive(SpecificScreenData)
    case vpn(SpecificScreenData)
    case vpnV2(SpecificScreenData) // Screen variant containing Guest mode
    case pass(SpecificScreenData)
    case wallet(SpecificScreenData)
    case meet(SpecificScreenData)
    case custom(CustomScreenData)
}

public struct WorkBeforeFlow {
    let stepName: String
    let completion: FlowCompletion

    public init(stepName: String, completion: @escaping FlowCompletion) {
        self.stepName = stepName
        self.completion = completion
    }
}

public protocol LoginErrorPresenter {
    func willPresentError(error: LoginError, from: UIViewController) -> Bool
    func willPresentError(error: SignupError, from: UIViewController) -> Bool
    func willPresentError(error: AvailabilityError, from: UIViewController) -> Bool
    func willPresentError(error: SetUsernameError, from: UIViewController) -> Bool
    func willPresentError(error: CreateAddressError, from: UIViewController) -> Bool
    func willPresentError(error: CreateAddressKeysError, from: UIViewController) -> Bool
    func willPresentError(error: StoreKitManagerErrors, from: UIViewController) -> Bool
    func willPresentError(error: ResponseError, from: UIViewController) -> Bool
    func willPresentError(error: Error, from: UIViewController) -> Bool
}

public typealias FlowCompletion = (LoginData, @escaping (Result<Void, Error>) -> Void) -> Void

public struct CloseSignupFlowAlertConfirmation {
    let title: String
    let cancelButtonTitle: String
    let continueButtonTitle: String

    public init(title: String, cancelButtonTitle: String, continueButtonTitle: String) {
        self.title = title
        self.cancelButtonTitle = cancelButtonTitle
        self.continueButtonTitle = continueButtonTitle
    }
}

/// An opt-in banner pinned to the top of the login screen.
///
/// Used by clients that need to show a persistent, actionable message above the sign-in form.
/// When `loginScreenBanner` is `nil`, no banner is shown and behaviour is unchanged.
public struct LoginScreenBanner {
    public enum Style {
        case error
        case success
    }

    public let style: Style
    public let message: String
    public let actionTitle: String?
    /// Invoked when the action is tapped. Return a follow-up banner to display in place of this one
    /// (e.g. a success confirmation), or `nil` to simply dismiss.
    public let action: (() -> LoginScreenBanner?)?

    public init(style: Style,
                message: String,
                actionTitle: String? = nil,
                action: (() -> LoginScreenBanner?)? = nil) {
        self.style = style
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
}

public struct LoginCustomizationOptions {

    public static let empty: LoginCustomizationOptions = .init()

    let username: String?
    let performBeforeFlow: WorkBeforeFlow?
    let customErrorPresenter: LoginErrorPresenter?
    let initialError: String?
    let helpDecorator: ([[HelpItem]]) -> [[HelpItem]]
    let inAppTheme: () -> InAppTheme
    let closeSignupFlowAlertConfirmation: CloseSignupFlowAlertConfirmation?
    let loginScreenBanner: LoginScreenBanner?

    public init(username: String? = nil,
                performBeforeFlow: WorkBeforeFlow? = nil,
                customErrorPresenter: LoginErrorPresenter? = nil,
                initialError: String? = nil,
                helpDecorator: @escaping ([[HelpItem]]) -> [[HelpItem]] = { $0 },
                inAppTheme: @escaping () -> InAppTheme = { .default },
                closeSignupFlowAlertConfirmation: CloseSignupFlowAlertConfirmation? = nil,
                loginScreenBanner: LoginScreenBanner? = nil) {
        self.username = username
        self.performBeforeFlow = performBeforeFlow
        self.customErrorPresenter = customErrorPresenter
        self.initialError = initialError
        self.helpDecorator = helpDecorator
        self.inAppTheme = inAppTheme
        self.closeSignupFlowAlertConfirmation = closeSignupFlowAlertConfirmation
        self.loginScreenBanner = loginScreenBanner
    }
}

public protocol LoginAndSignupInterface {

    // older API

    func presentLoginFlow(over viewController: UIViewController,
                          customization: LoginCustomizationOptions,
                          completion: @escaping (LoginResult) -> Void)

    func presentSignupFlow(over viewController: UIViewController,
                           customization: LoginCustomizationOptions,
                           completion: @escaping (LoginResult) -> Void)

    func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                      welcomeScreen: WelcomeScreenVariant,
                                      customization: LoginCustomizationOptions,
                                      completion: @escaping (LoginResult) -> Void)

    func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                        customization: LoginCustomizationOptions,
                                        completion: @escaping (LoginResult) -> Void) -> UIViewController

    // newer API

    func presentLoginFlow(over viewController: UIViewController,
                          customization: LoginCustomizationOptions,
                          updateBlock: @escaping (LoginAndSignupResult) -> Void)

    func presentSignupFlow(over viewController: UIViewController,
                           customization: LoginCustomizationOptions,
                           updateBlock: @escaping (LoginAndSignupResult) -> Void)

    func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                      welcomeScreen: WelcomeScreenVariant,
                                      customization: LoginCustomizationOptions,
                                      updateBlock: @escaping (LoginAndSignupResult) -> Void)

    func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                        customization: LoginCustomizationOptions,
                                        updateBlock: @escaping (LoginAndSignupResult) -> Void) -> UIViewController

    // helper API

    func presentMailboxPasswordFlow(over viewController: UIViewController,
                                    inAppTheme: InAppTheme,
                                    completion: @escaping (String) -> Void)

    func logout(credential: AuthCredential, completion: @escaping (Result<Void, Error>) -> Void)
}

extension LoginAndSignupInterface {

    public func presentLoginFlow(over viewController: UIViewController,
                                 completion: @escaping (LoginResult) -> Void) {
        presentLoginFlow(over: viewController, customization: .empty, completion: completion)
    }

    public func presentSignupFlow(over viewController: UIViewController, completion: @escaping (LoginResult) -> Void) {
        presentSignupFlow(over: viewController, customization: .empty, completion: completion)
    }

    public func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                             welcomeScreen: WelcomeScreenVariant,
                                             completion: @escaping (LoginResult) -> Void) {
        presentFlowFromWelcomeScreen(over: viewController,
                                     welcomeScreen: welcomeScreen,
                                     customization: .empty,
                                     completion: completion)
    }

    public func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                               completion: @escaping (LoginResult) -> Void) -> UIViewController {
        welcomeScreenForPresentingFlow(variant: welcomeScreen, customization: .empty, completion: completion)
    }

    public func presentMailboxPasswordFlow(over viewController: UIViewController,
                                           completion: @escaping (String) -> Void) {
        presentMailboxPasswordFlow(over: viewController, inAppTheme: .matchSystem, completion: completion)
    }
}

public final class LoginAndSignup {

    let container: Container
    private let isCloseButtonAvailable: Bool
    private let minimumAccountTypes: AccountTypes
    private(set) var loginCoordinator: LoginCoordinator?
    private(set) var signupCoordinator: SignupCoordinator?
    private var mailboxPasswordCoordinator: MailboxPasswordCoordinator?
    private var viewController: UIViewController?
    private var paymentsAvailability: PaymentsAvailability
    private var signupAvailability: SignupAvailability
    private var customization: LoginCustomizationOptions = .empty
    private var loginAndSignupCompletion: (LoginAndSignupResult) -> Void = { _ in }
    private var loginDataTemporarilyCachedForOlderAPI: LoginData?
    private var mailboxPasswordCompletion: ((String) -> Void)?
    private var welcomeScreenVariant: WelcomeScreenVariant?

    public init(appName: String,
                clientApp: ClientApp,
                apiService: APIService,
                minimumAccountTypes: AccountTypes,
                isCloseButtonAvailable: Bool = true,
                paymentsAvailability: PaymentsAvailability,
                signupAvailability: SignupAvailability = .notAvailable,
                ssoCallbackScheme: String? = nil) {
        container = Container(appName: appName,
                              clientApp: clientApp,
                              apiService: apiService,
                              initialMinimumAccountTypeForLogin: minimumAccountTypes.login,
                              ssoCallbackScheme: ssoCallbackScheme)
        self.isCloseButtonAvailable = isCloseButtonAvailable
        self.paymentsAvailability = paymentsAvailability
        self.signupAvailability = signupAvailability
        self.minimumAccountTypes = minimumAccountTypes
    }

    public convenience init(appName: String,
                            clientApp: ClientApp,
                            apiService: APIService,
                            minimumAccountType: AccountType,
                            isCloseButtonAvailable: Bool = true,
                            paymentsAvailability: PaymentsAvailability,
                            signupAvailability: SignupAvailability = .notAvailable,
                            ssoCallbackScheme: String? = nil) {
        self.init(
            appName: appName,
            clientApp: clientApp,
            apiService: apiService,
            minimumAccountTypes: .init(login: minimumAccountType, signup: minimumAccountType),
            isCloseButtonAvailable: isCloseButtonAvailable,
            paymentsAvailability: paymentsAvailability,
            signupAvailability: signupAvailability,
            ssoCallbackScheme: ssoCallbackScheme
        )
    }

    @discardableResult
    private func presentLogin(over viewController: UIViewController?,
                              welcomeScreen: WelcomeScreenVariant?,
                              customization: LoginCustomizationOptions,
                              completion: @escaping (LoginAndSignupResult) -> Void) -> UINavigationController {
        self.viewController = viewController
        self.customization = customization
        self.welcomeScreenVariant = welcomeScreen

        container.registerHumanVerificationDelegates()
        self.loginAndSignupCompletion = { [weak self] result in
            self?.container.unregisterHumanVerificationDelegates()
            completion(result)
        }

        let loginCoordinator = LoginCoordinator(container: container,
                                                isCloseButtonAvailable: isCloseButtonAvailable,
                                                isSignupAvailable: signupAvailability.isAvailable,
                                                customization: customization)
        self.loginCoordinator = loginCoordinator
        loginCoordinator.delegate = self
        if let welcomeScreen = welcomeScreen {
            if let viewController = viewController {
                return loginCoordinator.startFromWelcomeScreen(
                    viewController: viewController, variant: welcomeScreen, username: customization.username
                )
            } else {
                return loginCoordinator.startWithUnmanagedWelcomeScreen(
                    variant: welcomeScreen, username: customization.username
                )
            }
        } else {
            if let viewController = viewController {
                return loginCoordinator.start(.over(viewController, .coverVertical), username: customization.username)
            } else {
                return loginCoordinator.start(.unmanaged, username: customization.username)
            }
        }
    }

    private func presentSignup(_ start: FlowStartKind, customization: LoginCustomizationOptions, completion: @escaping (LoginAndSignupResult) -> Void) {
        signupCoordinator = SignupCoordinator(container: container,
                                              minimumAccountType: minimumAccountTypes.signup,
                                              isCloseButton: isCloseButtonAvailable,
                                              paymentsAvailability: paymentsAvailability,
                                              signupAvailability: signupAvailability,
                                              customization: customization)
        signupCoordinator?.delegate = self
        signupCoordinator?.start(kind: start)
    }
}

extension LoginAndSignup: LoginAndSignupInterface {

    public func presentLoginFlow(over viewController: UIViewController,
                                 customization: LoginCustomizationOptions,
                                 updateBlock: @escaping (LoginAndSignupResult) -> Void) {
        presentLogin(over: viewController, welcomeScreen: nil, customization: customization, completion: updateBlock)
    }

    public func presentSignupFlow(over viewController: UIViewController,
                                  customization: LoginCustomizationOptions,
                                  updateBlock: @escaping (LoginAndSignupResult) -> Void) {
        self.viewController = viewController
        self.customization = customization
        container.registerHumanVerificationDelegates()
        self.loginAndSignupCompletion = { [weak self] in
            self?.container.unregisterHumanVerificationDelegates()
            updateBlock($0)
        }
        presentSignup(.over(viewController, .coverVertical), customization: customization, completion: updateBlock)
    }

    public func presentMailboxPasswordFlow(over viewController: UIViewController,
                                           inAppTheme: InAppTheme = .matchSystem,
                                           completion: @escaping (String) -> Void) {
        self.viewController = viewController
        self.mailboxPasswordCompletion = completion
        mailboxPasswordCoordinator = MailboxPasswordCoordinator(container: container, delegate: self, inAppTheme: inAppTheme)
        mailboxPasswordCoordinator?.start(viewController: viewController)
    }

    public func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                             welcomeScreen: WelcomeScreenVariant,
                                             customization: LoginCustomizationOptions,
                                             updateBlock: @escaping (LoginAndSignupResult) -> Void) {
        self.welcomeScreenVariant = welcomeScreen
        presentLogin(over: viewController, welcomeScreen: welcomeScreen, customization: customization, completion: updateBlock)
    }

    public func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                               customization: LoginCustomizationOptions,
                                               updateBlock: @escaping (LoginAndSignupResult) -> Void) -> UIViewController {
        presentLogin(over: nil, welcomeScreen: welcomeScreen, customization: customization, completion: updateBlock)
    }

    public func logout(credential: AuthCredential, completion: @escaping (Result<Void, Error>) -> Void) {
        container.login.logout(credential: credential, completion: completion)
    }

    // backwards compatibility

    public func presentLoginFlow(over viewController: UIViewController,
                                 customization: LoginCustomizationOptions,
                                 completion: @escaping (LoginResult) -> Void) {
        presentLoginFlow(over: viewController, customization: customization, updateBlock: transformedCompletion(completion))
    }

    public func presentSignupFlow(over viewController: UIViewController,
                                  customization: LoginCustomizationOptions,
                                  completion: @escaping (LoginResult) -> Void) {
        presentSignupFlow(over: viewController, customization: customization, updateBlock: transformedCompletion(completion))
    }

    public func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                             welcomeScreen: WelcomeScreenVariant,
                                             customization: LoginCustomizationOptions,
                                             completion: @escaping (LoginResult) -> Void) {
        self.welcomeScreenVariant = welcomeScreen
        presentFlowFromWelcomeScreen(over: viewController, welcomeScreen: welcomeScreen, customization: customization, updateBlock: transformedCompletion(completion))
    }

    public func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                               customization: LoginCustomizationOptions,
                                               completion: @escaping (LoginResult) -> Void) -> UIViewController {
        welcomeScreenForPresentingFlow(variant: welcomeScreen, customization: customization, updateBlock: transformedCompletion(completion))
    }

    private func transformedCompletion(_ completion: @escaping (LoginResult) -> Void) -> (LoginAndSignupResult) -> Void {
        return { [unowned self] (result: LoginAndSignupResult) in
            switch result {
            case .dismissed: completion(.dismissed)
            case .loginStateChanged(.dataIsAvailable(let data)), .signupStateChanged(.dataIsAvailable(let data)):
                self.loginDataTemporarilyCachedForOlderAPI = data
            case .loginStateChanged(.loginFinished):
                guard let loginData = self.loginDataTemporarilyCachedForOlderAPI else {
                    preconditionFailure("Login data must be available at the point of login finish")
                }
                completion(.loggedIn(loginData))
            case .signupStateChanged(.signupFinished):
                guard let loginData = self.loginDataTemporarilyCachedForOlderAPI else {
                    preconditionFailure("Login data must be available at the point of signup finish")
                }
                completion(.signedUp(loginData))
            }
        }
    }

    private func loadWelcomeScreen(navigationViewController: LoginNavigationViewController?) {
        guard let navigationViewController else { return }
        loginCoordinator = LoginCoordinator(container: container,
                                            isCloseButtonAvailable: isCloseButtonAvailable,
                                            isSignupAvailable: signupAvailability.isAvailable,
                                            customization: customization)
        loginCoordinator?.delegate = self
        loginCoordinator?.welcomeScreenVariant = welcomeScreenVariant
        loginCoordinator?.backToWelcomeScreen(using: navigationViewController)
    }
}

extension LoginAndSignup: LoginCoordinatorDelegate {
    func userDidDismissLoginCoordinator(loginCoordinator: LoginCoordinator) {
        if welcomeScreenVariant == nil {
            loginAndSignupCompletion(.dismissed)
        } else {
            loadWelcomeScreen(navigationViewController: loginCoordinator.navigationController)
        }
    }

    func loginCoordinatorDidFinish(loginCoordinator: LoginCoordinator, data: LoginData) {
        loginAndSignupCompletion(.loginStateChanged(.dataIsAvailable(data)))
        loginAndSignupCompletion(.loginStateChanged(.loginFinished))
    }

    func userSelectedSignup(navigationController: LoginNavigationViewController) {
        presentSignup(.inside(navigationController), customization: customization, completion: loginAndSignupCompletion)
    }
}

extension LoginAndSignup: SignupCoordinatorDelegate {
    func userDidDismissSignupCoordinator(signupCoordinator: SignupCoordinator) {
        if welcomeScreenVariant == nil {
            loginAndSignupCompletion(.dismissed)
        } else {
            loadWelcomeScreen(navigationViewController: signupCoordinator.navigationController)
        }

    }

    func signupCoordinatorDidFinish(signupCoordinator: SignupCoordinator, signupState: SignupState) {
        loginAndSignupCompletion(.signupStateChanged(signupState))
    }

    func userSelectedSignin(email: String?, navigationViewController: LoginNavigationViewController) {
        loginCoordinator = LoginCoordinator(container: container,
                                            isCloseButtonAvailable: isCloseButtonAvailable,
                                            isSignupAvailable: signupAvailability.isAvailable,
                                            customization: customization)
        loginCoordinator?.delegate = self
        if email != nil {
            loginCoordinator?.initialError = LoginError.emailAddressAlreadyUsed
        }
        loginCoordinator?.start(.inside(navigationViewController), username: email)
        container.login.updateAccountType(accountType: minimumAccountTypes.login)
    }
}

extension LoginAndSignup: MailboxPasswordCoordinatorDelegate {
    func mailboxPasswordCoordinatorDidFinish(mailboxPasswordCoordinator: MailboxPasswordCoordinator, mailboxPassword: String) {
        mailboxPasswordCompletion?(mailboxPassword)
    }
}

// MARK: - Deprecations

@available(*, deprecated, renamed: "LoginAndSignupInterface")
public typealias LoginInterface = LoginAndSignupInterface

extension LoginAndSignupInterface {

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    public func presentLoginFlow(over viewController: UIViewController,
                                 username: String?,
                                 completion: @escaping (LoginResult) -> Void) {
        presentLoginFlow(over: viewController,
                         customization: LoginCustomizationOptions(username: username),
                         completion: completion)
    }

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    func presentLoginFlow(over viewController: UIViewController,
                          username: String?,
                          performBeforeFlow: WorkBeforeFlow?,
                          customErrorPresenter: LoginErrorPresenter?,
                          completion: @escaping (LoginResult) -> Void) {
        presentLoginFlow(over: viewController,
                         customization: LoginCustomizationOptions(
                            username: username,
                            performBeforeFlow: performBeforeFlow,
                            customErrorPresenter: customErrorPresenter
                         ),
                         completion: completion)
    }

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    func presentSignupFlow(over viewController: UIViewController,
                           performBeforeFlow: WorkBeforeFlow?,
                           customErrorPresenter: LoginErrorPresenter?,
                           completion: @escaping (LoginResult) -> Void) {
        presentSignupFlow(over: viewController,
                          customization: LoginCustomizationOptions(
                            performBeforeFlow: performBeforeFlow,
                            customErrorPresenter: customErrorPresenter
                          ),
                          completion: completion)
    }

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    public func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                             welcomeScreen: WelcomeScreenVariant,
                                             username: String?,
                                             completion: @escaping (LoginResult) -> Void) {
        presentFlowFromWelcomeScreen(over: viewController,
                                     welcomeScreen: welcomeScreen,
                                     customization: LoginCustomizationOptions(username: username),
                                     completion: completion)
    }

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    func presentFlowFromWelcomeScreen(over viewController: UIViewController,
                                      welcomeScreen: WelcomeScreenVariant,
                                      username: String?,
                                      performBeforeFlow: WorkBeforeFlow?,
                                      customErrorPresenter: LoginErrorPresenter?,
                                      completion: @escaping (LoginResult) -> Void) {
        presentFlowFromWelcomeScreen(over: viewController,
                                     welcomeScreen: welcomeScreen,
                                     customization: LoginCustomizationOptions(
                                        username: username,
                                        performBeforeFlow: performBeforeFlow,
                                        customErrorPresenter: customErrorPresenter
                                     ),
                                     completion: completion)
    }

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                        username: String?,
                                        performBeforeFlow: WorkBeforeFlow?,
                                        customErrorPresenter: LoginErrorPresenter?,
                                        completion: @escaping (LoginResult) -> Void) -> UIViewController {
        welcomeScreenForPresentingFlow(variant: welcomeScreen,
                                       customization: LoginCustomizationOptions(
                                        username: username,
                                        performBeforeFlow: performBeforeFlow,
                                        customErrorPresenter: customErrorPresenter
                                       ),
                                       completion: completion)
    }

    @available(*, deprecated, message: "Please switch to variant taking LoginCustomizationOptions parameter")
    public func welcomeScreenForPresentingFlow(variant welcomeScreen: WelcomeScreenVariant,
                                               username: String?,
                                               completion: @escaping (LoginResult) -> Void) -> UIViewController {
        welcomeScreenForPresentingFlow(variant: welcomeScreen,
                                       customization: LoginCustomizationOptions(username: username),
                                       completion: completion)
    }
}

@available(*, deprecated, renamed: "LoginAndSignup")
public typealias PMLogin = LoginAndSignup

#endif
