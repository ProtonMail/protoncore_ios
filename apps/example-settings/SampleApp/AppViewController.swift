//
//  AppViewController.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 10/11/2020.
//

import UIKit
import ProtonCore_Settings

final class AppViewController: UIViewController {
    @IBOutlet var settings: UIButton!
    @IBOutlet var lock: UIButton!

    @IBAction func presentSettings(_ sender: Any) {
        let appSettings  = PMSettingsSectionViewModel.appSettings(with: AppDelegate.keymaker)

        let systemSettings = PMSettingsSectionViewModel.systemSettings
        
        let about = PMSettingsSectionViewModel.about
            .amending()
            .prepend(row: PMAcknowledgementsConfiguration.acknowledgements(url: Self.url))
            .amend()

            ///*
        let newSection = PMSettingsSectionBuilder(bundle: Bundle(for: type(of: self)))
            .title("random-section-header")
            .footer("random-section-footer")
            .appendRow(PMHostConfiguration(viewController: RandomViewController()))
            .build()

         let vc = PMSettingsComposer.assemble(sections: [newSection, appSettings, systemSettings, about])
//         */
//
//        let vc = PMSettingsComposer.assemble(sections: [appSettings, systemSettings, about])

        present(vc, animated: true, completion: nil)
    }

    @IBAction func lockScreen(_ sender: Any) {
        guard AppDelegate.keymaker.isPinProtected || AppDelegate.keymaker.isBioProtected else { return }
        print("🔒 Screen Locked!!!")
        AppDelegate.keymaker.lockTheApp()
    }

    static var url: URL {
        Bundle.main.url(forResource: "Acknowledgements", withExtension: "markdown")!
    }
}
