//
//  UIFoundationsSplashShowcaseViewController.swift
//  Showcase
//
//  Created by Krzysztof Siejkowski on 18/06/2021.
//

import UIKit
import ProtonCoreLoginUI
import ProtonCoreUIFoundations

final class UIFoundationsSplashShowcaseViewController: UIFoundationsAppearanceStyleViewController {
    
    var splashViewController: UIViewController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { darkModeAwarePreferredStatusBarStyle() }

    private func button(title: String, action: Selector) -> UIButton {
        let button = UIButton(frame: .zero)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor(ColorProvider.TextNorm, for: .normal)
        return button
    }

    override func loadView() {
        let buttons = [
            button(title: "Mail splash", action: #selector(UIFoundationsSplashShowcaseViewController.showMailSplash)),
            button(title: "Drive splash", action: #selector(UIFoundationsSplashShowcaseViewController.showDriveSplash)),
            button(title: "Calendar splash", action: #selector(UIFoundationsSplashShowcaseViewController.showCalendarSplash)),
            button(title: "VPN splash", action: #selector(UIFoundationsSplashShowcaseViewController.showVPNSplash)),
            button(title: "Pass splash", action: #selector(UIFoundationsSplashShowcaseViewController.showPassSplash))
        ]
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.backgroundColor = ColorProvider.BackgroundNorm
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 64
        let container = UIView()
        container.addSubview(stack)
        container.backgroundColor = ColorProvider.BackgroundNorm
        view = container
        stack.centerInSuperview()
    }

    fileprivate func present(splash: SplashScreenIBVariant) {
        let selector: Selector
        switch splash {
        case .mail:
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToMailWelcomeView)
        case .drive:
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToDriveWelcomeView)
        case .calendar:
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToCalendarWelcomeView)
        case .vpn:
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToVPNWelcomeView)
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        case .pass:
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToPassWelcomeView)
        }
        let splash = SplashScreenViewControllerFactory.instantiate(for: splash, inAppTheme: { .default })
        let gesture = UITapGestureRecognizer(target: self, action: selector)
        gesture.numberOfTapsRequired = 1
        splash.view.addGestureRecognizer(gesture)
        splash.modalPresentationStyle = .fullScreen
        self.splashViewController = splash
        present(splash, animated: false)
    }
    
    @objc private func goToMailWelcomeView() {
        presentViewControllers(variant: WelcomeScreenVariant.mail(WelcomeScreenTexts(body: "Please Mister Postman, look and see! Is there's a letter in your bag for me?")))
    }
    
    @objc private func goToDriveWelcomeView() {
        presentViewControllers(variant: WelcomeScreenVariant.drive(WelcomeScreenTexts(body: "Drive me to the moon and let me play among the stars. Let me see what spring is like on Jupiter and Mars")))
    }
    
    @objc private func goToCalendarWelcomeView() {
        presentViewControllers(variant: WelcomeScreenVariant.calendar(WelcomeScreenTexts(body: "I don't care if Monday's blue. Tuesday's grey and Wednesday too. Thursday, I don't care about you. It's Friday, I'm in love")))
    }
    
    @objc private func goToVPNWelcomeView() {
        presentViewControllers(variant: WelcomeScreenVariant.vpn(WelcomeScreenTexts(body: "I know you've been hurt by someone else. I can tell by the way you carry yourself. But if you let me, here's what I'll do: I'll take care of you")))
    }

    @objc private func goToPassWelcomeView() {
        presentViewControllers(variant: WelcomeScreenVariant.pass(WelcomeScreenTexts(body: "Heaven smiles above me. What a gift here below. But no one knows. A gift that you give to me. No one knows")))
    }
    
    var welcomeViewCoordinator: WelcomeViewCoordinator?
    
    private func presentViewControllers(variant: WelcomeScreenVariant) {
        let vc = WelcomeViewController(
            variant: variant, delegate: self, username: nil, signupAvailable: true
        )
        vc.modalPresentationStyle = .fullScreen
        navigationController?.presentedViewController?.present(vc, animated: false)
    }
    
    @objc private func showMailSplash() {
        present(splash: .mail)
    }

    @objc private func showDriveSplash() {
        present(splash: .drive)
    }

    @objc private func showCalendarSplash() {
        present(splash: .calendar)
    }

    @objc private func showVPNSplash() {
        present(splash: .vpn)
    }

    @objc private func showPassSplash() {
        present(splash: .pass)
    }
}

extension UIFoundationsSplashShowcaseViewController: WelcomeViewCoordinatorDelegate, WelcomeViewControllerDelegate {
    func userWantsToLogIn(username: String?) {
        dismiss()
    }
    
    func userWantsToSignUp() {
        dismiss()
    }
    
    private func dismiss() {
        dismissWelcomeViewController()
    }

    private func dismissWelcomeViewController() {
        navigationController?.presentedViewController?.dismiss(animated: false) { [weak self] in
            self?.navigationController?.presentedViewController?.dismiss(animated: false)
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
}
