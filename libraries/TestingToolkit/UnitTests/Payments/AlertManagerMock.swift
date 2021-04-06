//
//  AlertManagerMock.swift
//  ProtonCore-TestingToolkit - Created on 23/12/2020.
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

#if os(iOS)
import UIKit

import ProtonCore_Payments

class AlertManagerMock: AlertManagerProtocol {
    enum ConfirmButton {
        case ok
        case cancel
    }
    
    var confirmActionClosure: (() -> Void)?
    var cancelActionClosure: (() -> Void)?
    var confirmButton: ConfirmButton = .ok
    var answerDelay = 0.1
    
    var title: String?
    var message: String?
    var confirmButtonTitle: String?
    var cancelButtonTitle: String?
    var confirmButtonStyle: UIAlertAction.Style = .default
    var cancelButtonStyle: UIAlertAction.Style = .default
    
    func showAlert(confirmAction: ActionCallback, cancelAction: ActionCallback) {
        Thread.sleep(forTimeInterval: answerDelay)
        if self.confirmButton == .ok {
            self.confirmActionClosure?()
            confirmAction?(UIAlertAction())
        } else if self.confirmButton == .cancel {
            self.cancelActionClosure?()
            cancelAction?(UIAlertAction())
        }
    }
}

#endif
