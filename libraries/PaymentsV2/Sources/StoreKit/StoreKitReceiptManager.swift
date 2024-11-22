//
//  StoreKitReceiptManager.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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

enum StoreKitReceiptManagerError: Error {
    case unableToExtractReceiptData
}

public protocol StoreKitReceiptManagerProviding {
    func fetchPurchaseReceipt() throws -> String
}

public final class StoreKitReceiptManager: StoreKitReceiptManagerProviding {

    public init() {}

    public func fetchPurchaseReceipt() throws -> String {
        guard let url = Bundle.main.appStoreReceiptURL, let data = try? Data(contentsOf: url) else {
            debugPrint("Unable to get receipt data")
            throw StoreKitReceiptManagerError.unableToExtractReceiptData
        }

        return data.base64EncodedString()
    }
}
