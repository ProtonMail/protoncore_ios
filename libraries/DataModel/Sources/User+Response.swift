//
//  User+Response.swift
//  ProtonCore-DataModel - Created on 17/03/2020.
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
import ProtonCoreLog

extension UserInfo {
    /// Initializes the UserInfo with the response data
    public convenience init(response: [String: Any]) {
        var uKeys: [Key] = [Key]()
        if let user_keys = response["Keys"] as? [[String: Any]] {
            for key_res in user_keys {
                uKeys.append(Key.init(response: key_res))
            }
        }
        let subscribed = response["Subscribed"] as? UInt64

        self.init(
            maxSpace: response["MaxSpace"] as? Int64,
            maxBaseSpace: response["MaxBaseSpace"] as? Int64,
            maxDriveSpace: response["MaxDriveSpace"] as? Int64,
            usedSpace: response["UsedSpace"] as? Int64,
            usedBaseSpace: response["UsedBaseSpace"] as? Int64,
            usedDriveSpace: response["UsedDriveSpace"] as? Int64,
            language: response["Language"] as? String,
            maxUpload: response["MaxUpload"] as? Int64,
            role: response["Role"] as? Int,
            delinquent: response["Delinquent"] as? Int,
            keys: uKeys,
            userId: response["ID"] as? String,
            linkConfirmation: response["ConfirmLink"] as? Int,
            credit: response["Credit"] as? Int,
            currency: response["Currency"] as? String,
            createTime: response["CreateTime"] as? Int64,
            subscribed: subscribed.map(User.Subscribed.init(rawValue:)),
            accountRecovery: UserInfo.parse(accountRecovery: response["AccountRecovery"] as? [String: Any]),
            lockedFlags: LockedFlags(rawValue: response["LockedFlags"] as? Int ?? 0),
            edmOptOut: DefaultValue.edmOptOut
        )
    }

    // convenience function for parsing from [String: Any]?, needed by some clients
    private static func parse(accountRecovery: [String: Any]?) -> AccountRecovery? {
        guard let accountRecovery else { return nil }

        guard JSONSerialization.isValidJSONObject(accountRecovery as Any) else {
            PMLog.error("Account Recovery state from /users response is not a valid JSON object", sendToExternal: true)
            return nil
        }

        guard let data = try? JSONSerialization.data(withJSONObject: accountRecovery as Any) else {
            PMLog.error("Account Recovery state is not encodable", sendToExternal: true)
            return nil
        }
        let decodedResults = try? JSONDecoder.decapitalisingFirstLetter.decode(AccountRecovery.self, from: data)
        return decodedResults
    }

}
