//
//  TroubleShootingHelper.swift
//  ProtonCore-TroubleShooting - Created on 08/20/2020
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.
//

import ProtonCore_Doh

public typealias OnStatusChanged = (_ newStatus: DoHStatus) -> Void

class DohStatusHelper: DohStatusProtocol {
    var doh: DoH
    init(doh: DoH) {
        self.doh = doh
    }
    
    var onChanged: OnStatusChanged = { newStatus in }
    
    var status: DoHStatus {
        get {
            return doh.status
        }
        set {
            self.doh.status = newValue
            self.onChanged(newValue)
        }
    }
}

extension UIViewController {
    
    public func present(doh: DoH,
                        dohStatusChanged: @escaping OnStatusChanged,
                        onDismiss: @escaping OnDismissComplete) {
        let statusHelper = DohStatusHelper(doh: doh)
        statusHelper.onChanged = dohStatusChanged
        let viewModel = TroubleShootingViewModel(doh: statusHelper)
        let troubleShootView = TroubleShootingViewController(viewModel: viewModel)
        troubleShootView.onDismiss = onDismiss
        let nav = UINavigationController(rootViewController: troubleShootView)
        self.present(nav, animated: true)
    }   
}
