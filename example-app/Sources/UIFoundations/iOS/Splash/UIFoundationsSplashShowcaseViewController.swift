//
//  UIFoundationsSplashShowcaseViewController.swift
//  Showcase
//
//  Created by Krzysztof Siejkowski on 18/06/2021.
//

import UIKit
import ProtonCore_LoginUI
import ProtonCore_UIFoundations

public enum SplashScreenIBVariant: Int {
    case mail = 1
    case calendar = 2
    case drive = 3
    case vpn = 4
}

final class UIFoundationsSplashShowcaseViewController: UIFoundationsAppearanceStyleViewController {

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
            button(title: "VPN splash", action: #selector(UIFoundationsSplashShowcaseViewController.showVPNSplash))
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
        let storyboardName: String
        let selector: Selector
        switch splash {
        case .mail:
            storyboardName = "MailLaunchScreen"
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToMailWelcomeView)
        case .drive:
            storyboardName = "DriveLaunchScreen"
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToDriveWelcomeView)
        case .calendar:
            storyboardName = "CalendarLaunchScreen"
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToCalendarWelcomeView)
        case .vpn:
            storyboardName = "VPNLaunchScreen"
            selector = #selector(UIFoundationsSplashShowcaseViewController.goToVPNWelcomeView)
        }
        let storyboard = UIStoryboard(name: storyboardName, bundle: .main)
        guard let splash = storyboard.instantiateInitialViewController() else {
            assertionFailure("Cannot instantiate launch screen view controller")
            return
        }
        let gesture = UITapGestureRecognizer(target: self, action: selector)
        gesture.numberOfTapsRequired = 1
        splash.view.addGestureRecognizer(gesture)
        splash.modalPresentationStyle = .fullScreen
        present(splash, animated: false)
    }
    
    @objc private func goToMailWelcomeView() {
        presentWelcomeView(variant: WelcomeScreenVariant.mail(WelcomeScreenTexts(
            headline: "Protect your privacy with ProtonMail",
            body: "Please Mister Postman, look and see! Is there's a letter in your bag for me?"
        )))
    }
    
    @objc private func goToDriveWelcomeView() {
        presentWelcomeView(variant: .drive(WelcomeScreenTexts(
            headline: "Let's go for a Drive",
            body: "Drive me to the moon and let me play among the stars. Let me see what spring is like on Jupiter and Mars"
        )))
    }
    
    @objc private func goToCalendarWelcomeView() {
        presentWelcomeView(variant: .calendar(WelcomeScreenTexts(
            headline: "Time flies, and with Calendar so will you",
            body: "I don't care if Monday's blue. Tuesday's grey and Wednesday too. Thursday, I don't care about you. It's Friday, I'm in love"
        )))
    }
    
    @objc private func goToVPNWelcomeView() {
        presentWelcomeView(variant: .vpn(WelcomeScreenTexts(
            headline: "Protect yourself online",
            body: "I know you've been hurt by someone else. I can tell by the way you carry yourself. But if you let me, here's what I'll do: I'll take care of you"
        )))
    }
    
    private func presentWelcomeView(variant: WelcomeScreenVariant) {
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

}

extension UIFoundationsSplashShowcaseViewController: WelcomeViewControllerDelegate {
    
    func userWantsToLogIn(username: String?) {
        back()
    }
    
    func userWantsToSignUp() {
        back()
    }
    
    private func back() {
        navigationController?.presentedViewController?.dismiss(animated: false) { [weak self] in
            self?.navigationController?.presentedViewController?.dismiss(animated: false)
        }
    }
}
