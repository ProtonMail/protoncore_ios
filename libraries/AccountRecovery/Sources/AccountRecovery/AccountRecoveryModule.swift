//
//  Created on 3/7/23.
//
//  Copyright (c) 2023 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import ProtonCoreFeatureSwitch
import ProtonCoreServices
import SwiftUI

public typealias AccountRecoveryViewController = UIHostingController<AccountRecoveryView>

/// Usefult parameters to have handy
public enum AccountRecoveryModule {
    /// Feature switch that governs whether Account Recovery code is active
    public static let feature = Feature.accountRecovery
    /// Resource bundle for the Account Recovery module
    public static let resourceBundle = Bundle(path: Bundle(for: AccountRecoveryHandler.self).path(forResource: "Resources-AccountRecovery", ofType: "bundle")!)!
    /// Localized name of the settings item for Account Recovery
    public static let settingsItem = LocalizedStrings.settingsItem
    /// `APIService`-accepting closure to obtain the Account Recovery View Controller in Settings
    public static let settingsViewController: (APIService) -> AccountRecoveryViewController = { apiService in
        let accountRepository = AccountRecoveryRepository(apiService: apiService)
        let viewModel = AccountRecoveryView.ViewModel(accountRepository: accountRepository)
        return UIHostingController(rootView: AccountRecoveryView(viewModel: viewModel))
    }
}

extension Feature {
    /// Feature switch that governs whether **Account Recovery** code is active
    public static var accountRecovery = Feature(name: "accountRecovery", isEnable: false)
}

