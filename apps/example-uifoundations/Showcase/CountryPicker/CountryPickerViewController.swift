//
//  CountryPickerViewController.swift
//  ProtonMail - Created on 12.03.21.
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import ProtonCore_UIFoundations

class CountryPickerViewController: AppearanceStyleViewController {
    
    let countryPicker = PMCountryPicker(searchBarPlaceholderText: "Search country")

    @IBOutlet weak var countryLabel: UILabel!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: "CountryPickerViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        countryLabel.text = "Country: ???, code: +\(countryPicker.getInitialCode())"
    }

    @IBAction func onShowCountryPickerButtonTap(_ sender: PMButton) {
        let viewController = countryPicker.getCountryPickerViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
}

extension CountryPickerViewController: CountryPickerViewControllerDelegate {
    func didCountryPickerClose() {
        countryLabel.text = "Country:"
    }
    
    func didSelectCountryCode(countryCode: CountryCode) {
        countryLabel.text = "Country: \(countryCode.country_en), code: +\(countryCode.phone_code)"
    }
    
    
}
