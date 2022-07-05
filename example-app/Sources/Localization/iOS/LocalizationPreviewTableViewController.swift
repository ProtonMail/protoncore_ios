//
//  LocalizationPreviewTableViewController.swift
//  ExampleApp-V5 - Created on 5/26/22.
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

#if canImport(ProtonCore_CoreTranslation_V5)
import ProtonCore_CoreTranslation_V5
#endif

class LocalizationPreviewTableViewController: UITableViewController {

    private var translationDict: [String] = []
    private var transPluralsDict: [String: String] = [:]
    
    var languageButton: UIBarButtonItem?
    
    // tried to use refection-Mirror. but the swift refection doesnt work well with lazy var.
    //  for saving time. manaually add string value first. improve in the future.
    func buildV5String() {
        self.translationDict.removeAll()
        self.title = "LocalizationV4"
#if canImport(ProtonCore_CoreTranslation_V5)
        self.title = "LocalizationV5"
        self.translationDict.append(CoreString_V5._ls_welcome_footer)

        self.translationDict.append(CoreString_V5._new_plans_select_plan_description)
        
        self.translationDict.append(CoreString_V5._new_plans_plan_details_free_description)
        
        self.translationDict.append(CoreString_V5._new_plans_plan_details_plus_description)
        
        self.translationDict.append(CoreString_V5._new_plans_plan_details_vpn_plus_description)
        
        self.translationDict.append(CoreString_V5._new_plans_plan_details_bundle_description)
    
        self.translationDict.append(CoreString_V5._new_plans_plan_footer_desc)
        
        self.translationDict.append(CoreString_V5._new_plans_details_unlimited_folders_labels_filters)
        
        self.translationDict.append(CoreString_V5._new_plans_details_up_to_storage)
        
        self.translationDict.append(CoreString_V5._new_plans_details_vpn_on_single_device)
        
        self.translationDict.append(CoreString_V5._new_plans_details_highest_VPN_speed)
        
        self.translationDict.append(CoreString_V5._new_plans_details_ad_blocker)
        
        self.translationDict.append(CoreString_V5._new_plans_details_access_streaming_services)
        
        self.translationDict.append(CoreString_V5._new_plans_details_secure_core_servers)
        
        self.translationDict.append(CoreString_V5._new_plans_details_tor_over_vpn)
        
        self.translationDict.append(CoreString_V5._new_plans_details_p2p)
        
        self.translationDict.append(CoreString_V5._new_plans_get_plan_button)
        
        self.translationDict.append(CoreString_V5._new_plans_get_free_plan_button)
        
        self.translationDict.append(CoreString_V5._new_plans_details_used_storage_space)
        
        self.translationDict.append(CoreString_V5._new_plans_connection_error_title)
        
        self.translationDict.append(CoreString_V5._new_plans_connection_error_description)
        
        self.translationDict.append(CoreString_V5._new_plans_details_no_logs_policy)
        
        self.translationDict.append(CoreString_V5._new_plans_plan_successfully_upgraded)
        
        self.translationDict.append(CoreString_V5._new_plans_extend_subscription_button)
        
        let stringSize = Mirror(reflecting: CoreString_V5).children.count

        let dictSize = self.translationDict.count
        
        //
        assert(stringSize == dictSize, "translation size dones't match with preview size")
#endif
    }
    
    private func inAppLanguage() {
#if canImport(ProtonCore_CoreTranslation_V5)
        let languages: [ELanguage] = ELanguage.allItems()
        let current_language = LanguageManager.currentLanguageEnum()
        let title = "Current Language is: " + current_language.nativeDescription
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        for l in languages {
            if l != current_language {
                alertController.addAction(UIAlertAction(title: l.nativeDescription, style: .default) { _ in
                    LanguageManager.saveLanguage(byCode: l.code, passin: Common_V5.bundle)
                    LocalizedString_V5.reset()
                    self.buildV5String()
                    self.tableView.reloadData()
                })
            }
        }
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.frame
        present(alertController, animated: true, completion: nil)
#endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LanguageManager.setupCurrentLanguage()
        
        languageButton = UIBarButtonItem(title: "Language", style: .plain, target: self, action: #selector(brandAction))

        navigationItem.rightBarButtonItem = languageButton
        
        //by default build v5 string because it only has a few
        self.buildV5String()
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
