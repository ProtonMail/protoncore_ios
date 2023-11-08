//
//  PaymentsTestUserPickerData.swift
//  Example-Payments - Created on 05/08/2021.
//
//  Copyright (c) 2020 Proton Technologies AG
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

import UIKit
import ProtonCoreObfuscatedConstants

final class PaymentsTestUserPickerData: NSObject {

    enum Variant {
    case black
    case payments
    }

    let variant: Variant

    init(variant: Variant) {
        self.variant = variant
    }

    let blackData: [(name: String, user: String, password: String)] = [
        (
            "free user",
            ObfuscatedConstants.freeUserOnBlack,
            ObfuscatedConstants.plansPassword
        ),
        (
            "disabled user",
            ObfuscatedConstants.disabledUserUsername,
            ObfuscatedConstants.disabledUserPassword
        ),
        (
            "vpn free user",
            ObfuscatedConstants.vpnFreeUserUsername,
            ObfuscatedConstants.vpnFreeUserPassword
        ),
        (
            "vpn basic user",
            ObfuscatedConstants.vpnBasicUserUsername,
            ObfuscatedConstants.vpnBasicUserPassword
        ),
        (
            "org admin",
            ObfuscatedConstants.orgAdminUserUsername,
            ObfuscatedConstants.orgAdminUserPassword
        ),
        (
            "org private",
            ObfuscatedConstants.orgPrivateUserUsername,
            ObfuscatedConstants.orgPrivateUserPassword
        ),
        (
            "org public",
            ObfuscatedConstants.orgPublicUserUsername,
            ObfuscatedConstants.orgPublicUserPassword
        ),
        (
            "org new private",
            ObfuscatedConstants.orgNewPrivateUserEmail,
            ObfuscatedConstants.orgNewPrivateUserPassword
        )
    ]

    let plansDataRaw: [(String, String)] = [
        (ObfuscatedConstants.plans1Description, ObfuscatedConstants.plans1Username),
        (ObfuscatedConstants.plans2Description, ObfuscatedConstants.plans2Username),
        (ObfuscatedConstants.plans3Description, ObfuscatedConstants.plans3Username),
        (ObfuscatedConstants.plans4Description, ObfuscatedConstants.plans4Username),
        (ObfuscatedConstants.plans5Description, ObfuscatedConstants.plans5Username),
        (ObfuscatedConstants.plans6Description, ObfuscatedConstants.plans6Username),
        (ObfuscatedConstants.plans7Description, ObfuscatedConstants.plans7Username),
        (ObfuscatedConstants.plans8Description, ObfuscatedConstants.plans8Username),
        (ObfuscatedConstants.plans9Description, ObfuscatedConstants.plans9Username),
        (ObfuscatedConstants.plansADescription, ObfuscatedConstants.plansAUsername),
        (ObfuscatedConstants.plansBDescription, ObfuscatedConstants.plansBUsername),
        (ObfuscatedConstants.plansCDescription, ObfuscatedConstants.plansCUsername),
        (ObfuscatedConstants.plansDDescription, ObfuscatedConstants.plansDUsername),
        (ObfuscatedConstants.plansEDescription, ObfuscatedConstants.plansEUsername),
        (ObfuscatedConstants.plansFDescription, ObfuscatedConstants.plansFUsername),
        (ObfuscatedConstants.plansGDescription, ObfuscatedConstants.plansGUsername),
        (ObfuscatedConstants.plansHDescription, ObfuscatedConstants.plansHUsername),
        (ObfuscatedConstants.plansIDescription, ObfuscatedConstants.plansIUsername),
        (ObfuscatedConstants.plansJDescription, ObfuscatedConstants.plansJUsername),
        (ObfuscatedConstants.plansKDescription, ObfuscatedConstants.plansKUsername),
        (ObfuscatedConstants.plansLDescription, ObfuscatedConstants.plansLUsername),
        (ObfuscatedConstants.plansMDescription, ObfuscatedConstants.plansMUsername),
        (ObfuscatedConstants.plansNDescription, ObfuscatedConstants.plansNUsername),
        (ObfuscatedConstants.plansODescription, ObfuscatedConstants.plansOUsername),
        (ObfuscatedConstants.plansPDescription, ObfuscatedConstants.plansPUsername),
        (ObfuscatedConstants.plansRDescription, ObfuscatedConstants.plansRUsername),
        (ObfuscatedConstants.plansSDescription, ObfuscatedConstants.plansSUsername),
        (ObfuscatedConstants.plansTDescription, ObfuscatedConstants.plansTUsername),
        (ObfuscatedConstants.plansUDescription, ObfuscatedConstants.plansUUsername),
        (ObfuscatedConstants.plansWDescription, ObfuscatedConstants.plansWUsername),
        (ObfuscatedConstants.plansYDescription, ObfuscatedConstants.plansYUsername),

        (ObfuscatedConstants.plansT1Description, ObfuscatedConstants.plansT1Username),
        (ObfuscatedConstants.plansT2Description, ObfuscatedConstants.plansT2Username),
        (ObfuscatedConstants.plansT3Description, ObfuscatedConstants.plansT3Username),
        (ObfuscatedConstants.plansT4Description, ObfuscatedConstants.plansT4Username),
        (ObfuscatedConstants.plansT5Description, ObfuscatedConstants.plansT5Username),
        (ObfuscatedConstants.plansT6Description, ObfuscatedConstants.plansT6Username),
        (ObfuscatedConstants.plansT7Description, ObfuscatedConstants.plansT7Username),
        (ObfuscatedConstants.plansT8Description, ObfuscatedConstants.plansT8Username),
        (ObfuscatedConstants.plansT9Description, ObfuscatedConstants.plansT9Username),
        (ObfuscatedConstants.plansTADescription, ObfuscatedConstants.plansTAUsername),
        (ObfuscatedConstants.plansTBDescription, ObfuscatedConstants.plansTBUsername),
        (ObfuscatedConstants.plansTCDescription, ObfuscatedConstants.plansTCUsername),
        (ObfuscatedConstants.plansTDDescription, ObfuscatedConstants.plansTDUsername),
        (ObfuscatedConstants.plansTEDescription, ObfuscatedConstants.plansTEUsername),
        (ObfuscatedConstants.plansTFDescription, ObfuscatedConstants.plansTFUsername),
        (ObfuscatedConstants.plansTGDescription, ObfuscatedConstants.plansTGUsername),
        (ObfuscatedConstants.plansTHDescription, ObfuscatedConstants.plansTHUsername),
        (ObfuscatedConstants.plansTIDescription, ObfuscatedConstants.plansTIUsername)
    ]

    lazy var plansData: [(name: String, user: String, password: String)] = plansDataRaw
        .map { (name: $0, user: $1, password: ObfuscatedConstants.plansPassword) }

    var data: [(name: String, user: String, password: String)] {
        switch variant {
        case .black: return blackData
        case .payments: return plansData
        }
    }

    private var onSelect: ((String, String)?) -> Void = { _ in }

    func setup(picker: UIPickerView, onSelect: @escaping ((String, String)?) -> Void) {
        self.onSelect = onSelect
        picker.dataSource = self
        picker.delegate = self
        picker.reloadAllComponents()
    }
}

extension PaymentsTestUserPickerData: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { data.count + 1 }
}

extension PaymentsTestUserPickerData: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?
    ) -> UIView {
        let text: String
        if row == 0 {
            text = "No prefilling"
        } else {
            text = data[row - 1].name
        }
        let textColor = UIColor.label
        let label = UILabel(text,
                            font: UIFont.preferredFont(forTextStyle: .body),
                            textColor: textColor,
                            alignment: .center)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            onSelect(nil)
        } else {
            onSelect((data[row - 1].user, data[row - 1].password))
        }
    }
}
