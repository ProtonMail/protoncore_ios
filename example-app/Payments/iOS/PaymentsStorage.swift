//
//  PaymentsStorage.swift
//  Example-Payments - Created on 10/12/2020.
//
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

import Foundation

public class PaymentsStorage {
    
    private static let migrationKey = "migratedTo"
    
    private static let standardDefaults = UserDefaults.standard
    private static var specifiedDefaults: UserDefaults?
    
    public static func setSpecificDefaults(defaults: UserDefaults) {
        if !defaults.bool(forKey: PaymentsStorage.migrationKey) {
            // Move any compatible data from old defaults to the new one
            PaymentsStorage.standardDefaults.dictionaryRepresentation().forEach { (key, value) in
                defaults.set(value, forKey: key)
            }
            
            defaults.setValue(true, forKey: PaymentsStorage.migrationKey)
            defaults.synchronize()
        }
        
        PaymentsStorage.specifiedDefaults = defaults
    }
    
    public static func userDefaults() -> UserDefaults {
        if let specifiedDefaults = specifiedDefaults {
            return specifiedDefaults
        } else {
            return PaymentsStorage.standardDefaults
        }
    }
    
    public static func setValue(_ value: Any?, forKey key: String) {
        PaymentsStorage.userDefaults().setValue(value, forKey: key)
    }
    
    public static func contains(_ key: String) -> Bool {
        return PaymentsStorage.userDefaults().object(forKey: key) != nil
    }
}
