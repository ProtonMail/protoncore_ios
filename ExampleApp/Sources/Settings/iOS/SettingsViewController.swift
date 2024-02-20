//
//  SettingsViewController.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 10/11/2020.
//

import UIKit
import ProtonCoreLog
import ProtonCoreKeymaker
import ProtonCorePayments
import ProtonCorePaymentsUI
import ProtonCoreSettings
import ProtonCoreServices
import ProtonCoreChallenge

final class SettingsViewController: UIViewController {
    @IBOutlet var settings: UIButton!
    @IBOutlet var lock: UIButton!

    static let initialSettings = PMSettingsSectionViewModel.systemSettings
    var vc: UIViewController!
    var newSection: PMSettingsSectionViewModel!
    var about: PMSettingsSectionViewModel!
    var appSettings: PMSettingsSectionViewModel!
    var paymentsUI: PaymentsUI?
    var apiService = PMAPIService.createAPIService(environment: .black,
                                                    sessionUID: "testSessionUID",
                                                   challengeParametersProvider: .forAPIService(clientApp: clientApp, challenge: PMChallenge()))

    override func viewDidLoad() {
        super.viewDidLoad()
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
            .build()

        vc = PMSettingsComposer.assemble(sections: [newSection, appSettings, about].compactMap { $0 })
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
}
