//
//  SettingsViewController.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 10/11/2020.
//

import UIKit
import ProtonCore_Log
import ProtonCore_Keymaker
import ProtonCore_Settings

final class SettingsViewController: UIViewController {
    @IBOutlet var settings: UIButton!
    @IBOutlet var lock: UIButton!
    
    static let keymaker = Keymaker(
        autolocker: Autolocker(lockTimeProvider: SettingsDemoKeychain()),
        keychain: SettingsDemoKeychain())

    @IBAction func presentSettings(_ sender: Any) {
        let appSettings  = PMSettingsSectionViewModel.appSettings(with: SettingsViewController.keymaker)

        let systemSettings = PMSettingsSectionViewModel.systemSettings
        
        let about = PMSettingsSectionViewModel.about
            .amending()
            .prepend(row: PMAcknowledgementsConfiguration.acknowledgements(url: Self.url))
            .amend()

            ///*
        let newSection = PMSettingsSectionBuilder(bundle: Bundle(for: type(of: self)))
            .title("random-section-header")
            .footer("random-section-footer")
            .appendRow(PMHostConfiguration(viewController: SettingsRandomViewController()))
            .build()

         let vc = PMSettingsComposer.assemble(sections: [newSection, appSettings, systemSettings, about])
//         */
//
//        let vc = PMSettingsComposer.assemble(sections: [appSettings, systemSettings, about])

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
