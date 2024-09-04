//
//  Transaction.swift
//  ProtonCore-Payments - Created on 04/09/24.
//
//  Copyright (c) 2024 Proton Technologies AG
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

import Foundation
import StoreKit

public extension SKPaymentTransaction {

    var isRenewal: Bool {
        self.original != nil &&
        (self.transactionState == .purchased || self.transactionState == .restored)
    }

#if DEBUG
    open override var debugDescription: String {
        "[Date: \(self.transactionDate) - State: \(String(describing:self.transactionState))\n Identifier: \(self.transactionIdentifier). Original: \(self.original?.debugDescription ?? "self") ]"
    }
#endif
}
