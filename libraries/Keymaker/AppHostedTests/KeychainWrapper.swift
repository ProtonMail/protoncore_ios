//
//  KeychainWrapper.swift
//  ProtonCore-Keymaker-Tests - Created on 4/11/2022.
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

import Foundation

@testable import ProtonCoreKeymaker

internal class KeychainWrapper: Keychain {

    var dict: [String: Any] = [String: Any]()

    override init(service: String, accessGroup: String, secItemMethodsProvider: SecItemMethodsProvider? = nil) {
        super.init(service: service, accessGroup: accessGroup, secItemMethodsProvider: secItemMethodsProvider)
    }

    override func set(_ data: Data, forKey key: String, attributes: [CFString: Any]? = nil) {
        dict[key] = data
    }

    override func set(_ string: String, forKey key: String, attributes: [CFString: Any]? = nil) {
        dict[key] = string
    }

    override func data(forKey key: String, attributes: [CFString: Any]? = nil) -> Data? {
        return dict[key] as? Data
    }

    override func string(forKey key: String, attributes: [CFString: Any]? = nil) -> String? {
        return dict[key] as? String
    }

    override func remove(forKey key: String) {
        dict.removeValue(forKey: key)
    }

    override func removeEverything() -> Bool {
        dict.removeAll()
        return true
    }

}
