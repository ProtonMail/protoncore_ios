//
//  ConfirmationPasswordConfigurationRouter.swift
//  ProtonCore-Settings - Created on 04.10.2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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

final class ConfirmationPasswordConfigurationRouter: SecurityPasswordRouter {
    weak var view: UIViewController?
    var onSuccess: (Bool) -> Void

    init(view: UIViewController, onSuccess: @escaping (Bool) -> Void) {
        self.view = view
        self.onSuccess = onSuccess
    }

    func advance() {
        view?.dismiss(animated: true, completion: nil)
    }

    func withdraw() {
        view?.navigationController?.popViewController(animated: true)
    }

    func finishWithSuccess(_ success: Bool) {
        onSuccess(success)
        view?.dismiss(animated: true, completion: nil)
    }
}
