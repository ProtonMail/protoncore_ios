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
import ProtonCorePayments

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

final class UserCachedStatus: ServicePlanDataStorage {
    var updateSubscriptionBlock: ((Subscription?) -> Void)?
    var updateUserInfoBlock: ((Credits?) -> Void)?

    init(updateSubscriptionBlock: ((Subscription?) -> Void)? = nil, updateUserInfoBlock: ((Credits?) -> Void)? = nil) {
        self.updateSubscriptionBlock = updateSubscriptionBlock
        self.updateUserInfoBlock = updateUserInfoBlock
    }

    var servicePlansDetails: [Plan]? {
        get {
            guard let data = PaymentsStorage.userDefaults().data(forKey: "servicePlansDetails") else {
                return nil
            }
            return try? PropertyListDecoder().decode(Array<Plan>.self, from: data)
        }
        set {
            let data = try? PropertyListEncoder().encode(newValue)
            PaymentsStorage.setValue(data, forKey: "servicePlansDetails")
        }
    }

    var defaultPlanDetails: Plan? {
        get {
            guard let data = PaymentsStorage.userDefaults().data(forKey: "defaultPlanDetails") else {
                return nil
            }
            return try? PropertyListDecoder().decode(Plan.self, from: data)
        }
        set {
            let data = try? PropertyListEncoder().encode(newValue)
            PaymentsStorage.setValue(data, forKey: "defaultPlanDetails")
        }
    }

    var currentSubscription: Subscription? {
        get {
            guard let data = PaymentsStorage.userDefaults().data(forKey: "currentSubscription") else {
                return nil
            }
            return try? PropertyListDecoder().decode(Subscription.self, from: data)
        }
        set {
            let data = try? PropertyListEncoder().encode(newValue)
            PaymentsStorage.setValue(data, forKey: "currentSubscription")
            self.updateSubscriptionBlock?(newValue)
        }
    }

    var paymentsBackendStatusAcceptsIAP: Bool {
        get {
            return PaymentsStorage.userDefaults().bool(forKey: "paymentsBackendStatusAcceptsIAP")
        }
        set {
            PaymentsStorage.setValue(newValue, forKey: "paymentsBackendStatusAcceptsIAP")
        }
    }

    var credits: Credits? {
        didSet {
            self.updateUserInfoBlock?(credits)
        }
    }

    var paymentMethods: [PaymentMethod]? {
        get {
            guard let data = PaymentsStorage.userDefaults().data(forKey: "paymentMethods") else { return nil }
            return try? PropertyListDecoder().decode([PaymentMethod].self, from: data)
        }
        set {
            let data = try? PropertyListEncoder().encode(newValue)
            PaymentsStorage.setValue(data, forKey: "paymentMethods")
        }
    }
}
