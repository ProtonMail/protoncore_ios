//
//  SettingsViewController.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 10/11/2020.
//

import UIKit
import ProtonCoreFeatureSwitch
import ProtonCoreLog
import ProtonCoreKeymaker
import ProtonCorePayments
import ProtonCorePaymentsUI
import ProtonCoreSettings
import ProtonCoreServices
import ProtonCoreSubscriptions
import ProtonCoreChallenge

final class SettingsViewController: UIViewController, SubscriptionTypePickerViewControllerDelegate {
    @IBOutlet var settings: UIButton!
    @IBOutlet var lock: UIButton!

    let subscriptionPicker = SubscriptionTypePickerViewController()
    static let initialSettings = PMSettingsSectionViewModel.systemSettings
    var systemSettings: PMSettingsSectionViewModel!
    var vc: UIViewController!
    var newSection: PMSettingsSectionViewModel!
    var about: PMSettingsSectionViewModel!
    var appSettings: PMSettingsSectionViewModel!
    var paymentsUI: PaymentsUI?
    var apiService = PMAPIService.createAPIService(environment: .black,
                                                    sessionUID: "testSessionUID",
                                                   challengeParametersProvider: .forAPIService(clientApp: clientApp, challenge: PMChallenge()))

    override func viewDidLoad() {
        let payments = Payments(inAppPurchaseIdentifiers: [], apiService: apiService, localStorage: UserCachedStatus(), reportBugAlertHandler: { receipt in
            PMLog.error("Error from payments")
        })
        paymentsUI = PaymentsUI(payments: payments, clientApp: clientApp, shownPlanNames: [], customization: .empty)
    }

    static let keymaker = Keymaker(
        autolocker: Autolocker(lockTimeProvider: SettingsDemoKeychain()),
        keychain: SettingsDemoKeychain())

    @IBAction func presentSettings(_ sender: Any) {
         appSettings = PMSettingsSectionViewModel.appSettings(with: SettingsViewController.keymaker)

         about = PMSettingsSectionViewModel.about
            .amending()
            .prepend(row: PMAcknowledgementsConfiguration.acknowledgements(url: Self.url))
            .amend()

            /// *
        newSection = PMSettingsSectionBuilder(bundle: Bundle(for: type(of: self)))
            .title("random-section-header")
            .footer("random-section-footer")
            .appendRow(PMHostConfiguration(viewController: SettingsRandomViewController()))
            .appendRow(PMHostConfiguration(viewController: subscriptionPicker))
            .build()
        subscriptionPicker.delegate = self
        systemSettings = settings(for: .none)

        vc = PMSettingsComposer.assemble(sections: [newSection, appSettings, systemSettings, about].compactMap { $0 })
        present(vc, animated: true, completion: nil)
    }

    @IBAction func lockScreen(_ sender: Any) {
        guard SettingsViewController.keymaker.isPinProtected || SettingsViewController.keymaker.isBioProtected else { return }
        PMLog.info("🔒 Screen Locked!!!")
        SettingsViewController.keymaker.lockTheApp()
    }

    static var url: URL {
        Bundle.main.url(forResource: "Acknowledgements", withExtension: "markdown")!
    }

    func typeDidChange(to subType: SubscriptionType) {
        systemSettings = settings(for: subType)
        if let settingsVC = (vc as? UINavigationController)?.viewControllers[0] as? PMSettingsViewController {
            settingsVC.viewModel = PMSettingsViewModel(sections: [newSection, appSettings, systemSettings, about].compactMap { $0 },
                                                       version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
            settingsVC.tableView.reloadData()
        }
    }

    private func settings(for subType: SubscriptionType) -> PMSettingsSectionViewModel {
        let systemSettings: PMSettingsSectionViewModel
        var subscription: CurrentPlan.Subscription

        switch subType {
        case .none:
            subscription = CurrentPlan.Subscription(title: "free", description: "free", external: nil, entitlements: [])
        case .iap:
            subscription = CurrentPlan.Subscription(title: "IAP", description: "IAP Subscription", external: .apple, entitlements: [])
        case .external:
            subscription = CurrentPlan.Subscription(title: "Web purchase", description: "Web purchase", external: .web, entitlements: [])
        }

        let cta = SubscriptionSettingsProvider.appropriateCTA(for: subscription)

        if cta == .cannotManageSubscription {
            systemSettings = Self.initialSettings.amending()
                .footer(KeyInBundle(key: cta.title,
                                    bundle: Bundle(for: SubscriptionSettingsProvider.self)))
                .amend()
        } else {
            systemSettings = Self.initialSettings.amending()
                .append(row: PMSystemSettingConfiguration.from(cta: cta, withPaymentsUI: paymentsUI!))
                .amend()
        }

        return systemSettings
    }
}

extension PMSystemSettingConfiguration {
    static func from(cta: SubscriptionCTA, withPaymentsUI paymentsUI: PaymentsUI) -> Self {
        PMSystemSettingConfiguration(title: cta.title,
                                     description: cta.description,
                                     buttonText: cta.buttonText,
                                     action: .perform({ cta.action(paymentsUI) }),
                                     bundle: PMSettings.bundle)
    }
}
