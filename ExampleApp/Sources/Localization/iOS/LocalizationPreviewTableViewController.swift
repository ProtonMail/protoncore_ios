//
//  LocalizationPreviewTableViewController.swift
//  ExampleApp - Created on 5/26/22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import UIKit
import ProtonCoreLoginUI
import ProtonCorePaymentsUI

class LocalizationPreviewTableViewController: UITableViewController {

    private var translationDict: [String] = []
    private var transPluralsDict: [String: String] = [:]
    
    var languageButton: UIBarButtonItem?
    
    // tried to use refection-Mirror. but the swift refection doesnt work well with lazy var.
    //  for saving time. manaually add string value first. improve in the future.
    func buildString() {
        self.translationDict.removeAll()
        self.title = "Localization"
        self.translationDict.append(LUITranslation._ls_welcome_footer.l10n)

        self.translationDict.append(PUITranslations._select_plan_description.l10n)
        
        self.translationDict.append(PUITranslations._plan_details_free_description.l10n)
        
        self.translationDict.append(PUITranslations._plan_details_plus_description.l10n)
        
        self.translationDict.append(PUITranslations._plan_details_vpn_plus_description.l10n)
        
        self.translationDict.append(PUITranslations._plan_details_bundle_description.l10n)
    
        self.translationDict.append(PUITranslations._plan_footer_desc.l10n)
        
        self.translationDict.append(PUITranslations._details_unlimited_folders_labels_filters.l10n)
        
        self.translationDict.append(PUITranslations._details_up_to_storage.l10n)
        
        self.translationDict.append(PUITranslations._details_vpn_on_single_device.l10n)
        
        self.translationDict.append(PUITranslations._details_highest_VPN_speed.l10n)
        
        self.translationDict.append(PUITranslations._detailsblocker.l10n)
        
        self.translationDict.append(PUITranslations._details_access_streaming_services.l10n)
        
        self.translationDict.append(PUITranslations._details_secure_core_servers.l10n)
        
        self.translationDict.append(PUITranslations._details_tor_over_vpn.l10n)
        
        self.translationDict.append(PUITranslations._details_p2p.l10n)
        
        self.translationDict.append(PUITranslations._get_plan_button.l10n)
        
        self.translationDict.append(PUITranslations._get_free_plan_button.l10n)
        
        self.translationDict.append(PUITranslations._details_used_storage_space.l10n)
        
        self.translationDict.append(PUITranslations._connection_error_title.l10n)
        
        self.translationDict.append(PUITranslations._connection_error_description.l10n)
        
        self.translationDict.append(PUITranslations._details_no_logs_policy.l10n)
        
        self.translationDict.append(PUITranslations._plan_successfully_upgraded.l10n)
        
        self.translationDict.append(PUITranslations._extend_subscription_button.l10n)
    }
    
    private func inAppLanguage() {
        let languages: [ELanguage] = ELanguage.allItems()
        let current_language = LanguageManager.currentLanguageEnum()
        let title = "Current Language is: " + current_language.nativeDescription
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        for l in languages {
            if l != current_language {
                alertController.addAction(UIAlertAction(title: l.nativeDescription, style: .default) { _ in
                    self.buildString()
                    self.tableView.reloadData()
                })
            }
        }
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.frame
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LanguageManager.setupCurrentLanguage()
        
        languageButton = UIBarButtonItem(title: "Language", style: .plain, target: self, action: #selector(brandAction))

        navigationItem.rightBarButtonItem = languageButton
        
        self.buildString()
    }
    
    @objc func brandAction(sender: UIBarButtonItem!) {
        inAppLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.translationDict.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localization_table_cell", for: indexPath)
        cell.textLabel?.text = self.translationDict[indexPath.row]
        return cell
    }
}
