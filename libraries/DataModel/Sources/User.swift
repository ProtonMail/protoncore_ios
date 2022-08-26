//
//  User.swift
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

public struct User: Codable, Equatable {
    
    public let ID: String
    public let name: String?
    public let usedSpace: Double
    public let currency: String
    public let credit: Int
    public let maxSpace: Double
    public let maxUpload: Double
    public let role: Int
    public let `private`: Int
    public let subscribed: Int
    public let services: Int
    public let delinquent: Int
    public let orgPrivateKey: String?
    public let email: String?
    public let displayName: String?
    public let keys: [Key]
    // public let driveEarlyAccess: Int
    // public let mailSettings: MailSetting
    // public let addresses: [Address]

    public init(ID: String,
                name: String?,
                usedSpace: Double,
                currency: String,
                credit: Int,
                maxSpace: Double,
                maxUpload: Double,
                role: Int,
                private: Int,
                subscribed: Int,
                services: Int,
                delinquent: Int,
                orgPrivateKey: String?,
                email: String?,
                displayName: String?,
                keys: [Key]) {
        self.ID = ID
        self.name = name
        self.usedSpace = usedSpace
        self.currency = currency
        self.credit = credit
        self.maxSpace = maxSpace
        self.maxUpload = maxUpload
        self.role = role
        self.private = `private`
        self.subscribed = subscribed
        self.services = services
        self.delinquent = delinquent
        self.orgPrivateKey = orgPrivateKey
        self.email = email
        self.displayName = displayName
        self.keys = keys
    }
}

@objc(UserInfo)
public final class UserInfo: NSObject {
    public var attachPublicKey: Int
    public var autoSaveContact: Int
    public var crashReports: Int
    public var credit: Int
    public var currency: String
    public var defaultSignature: String
    public var delaySendSeconds: Int
    public var delinquent: Int
    public var displayName: String
    public var enableFolderColor: Int
    /// 0 - threading, 1 - single message
    public var groupingMode: Int
    public var inheritParentFolderColor: Int
    public var language: String
    public var linkConfirmation: LinkOpeningMode
    public var maxSpace: Int64
    public var maxUpload: Int64
    public var notificationEmail: String
    public var notify: Int
    public var passwordMode: Int
    public var role: Int
    public var showImages: ShowImages
    public var sign: Int
    /// 0: free user, > 0: paid user
    public var subscribed: Int
    public var swipeLeft: Int
    public var swipeRight: Int
    public var telemetry: Int
    public var twoFactor: Int
    public var usedSpace: Int64
    public var userAddresses: [Address]
    public var userId: String
    public var userKeys: [Key]
    public var weekStart: Int

    
    public static func getDefault() -> UserInfo {
        return .init(maxSpace: 0, usedSpace: 0, language: "",
                     maxUpload: 0, role: 0, delinquent: 0,
                     keys: nil, userId: "", linkConfirmation: 0,
                     credit: 0, currency: "", subscribed: 0)
    }
    
    // init from cache
    public required init(
        displayName: String?,
        maxSpace: Int64?,
        notificationEmail: String?,
        signature: String?,
        usedSpace: Int64?,
        userAddresses: [Address]?,
        autoSC: Int?,
        language: String?,
        maxUpload: Int64?,
        notify: Int?,
        showImage: Int?,
        swipeLeft: Int?,
        swipeRight: Int?,
        role: Int?,
        delinquent: Int?,
        keys: [Key]?,
        userId: String?,
        sign: Int?,
        attachPublicKey: Int?,
        linkConfirmation: String?,
        credit: Int?,
        currency: String?,
        pwdMode: Int?,
        twoFA: Int?,
        enableFolderColor: Int?,
        inheritParentFolderColor: Int?,
        subscribed: Int?,
        groupingMode: Int?,
        weekStart: Int?,
        delaySendSeconds: Int?,
        telemetry: Int?,
        crashReports: Int?)
    {
        self.maxSpace = maxSpace ?? 0
        self.usedSpace = usedSpace ?? 0
        self.language = language ?? "en_US"
        self.maxUpload = maxUpload ?? 0
        self.role = role ?? 0
        self.delinquent = delinquent ?? 0
        self.userKeys = keys ?? [Key]()
        self.userId = userId ?? ""
        
        // get from user settings
        self.crashReports = crashReports ?? DefaultValue.crashReports
        self.credit = credit ?? 0
        self.currency = currency ?? "USD"
        self.enableFolderColor = enableFolderColor ?? 0
        self.inheritParentFolderColor = inheritParentFolderColor ?? 0
        self.notificationEmail = notificationEmail ?? ""
        self.notify = notify ?? 0
        self.passwordMode = pwdMode ?? 1
        self.subscribed = subscribed ?? 0
        self.telemetry = telemetry ?? DefaultValue.telemetry
        self.twoFactor = twoFA ?? 0
        self.userAddresses = userAddresses ?? [Address]()
        self.weekStart = weekStart ?? 0

        // get from mail settings
        self.attachPublicKey = attachPublicKey ?? 0
        self.autoSaveContact  = autoSC ?? 0
        self.defaultSignature = signature ?? ""
        self.delaySendSeconds = delaySendSeconds ?? 10
        self.displayName = displayName ?? ""
        self.groupingMode = groupingMode ?? 1
        self.showImages = ShowImages(rawValue: showImage ?? 0)
        self.sign = sign ?? 0
        self.swipeLeft = swipeLeft ?? 3
        self.swipeRight = swipeRight ?? 0
        if let value = linkConfirmation, let mode = LinkOpeningMode(rawValue: value) {
            self.linkConfirmation = mode
        } else {
            self.linkConfirmation = .confirmationAlert
        }
    }
    
    // init from api
    public required init(maxSpace: Int64?,
                         usedSpace: Int64?,
                         language:
                         String?,
                         maxUpload: Int64?,
                         role: Int?,
                         delinquent: Int?,
                         keys: [Key]?,
                         userId: String?,
                         linkConfirmation: Int?,
                         credit: Int?,
                         currency: String?,
                         subscribed: Int?) {
        self.attachPublicKey = 0
        self.autoSaveContact = 0
        self.crashReports = DefaultValue.crashReports
        self.credit = credit ?? 0
        self.currency = currency ?? "USD"
        self.defaultSignature = ""
        self.delaySendSeconds = 10
        self.delinquent = delinquent ?? 0
        self.displayName = ""
        self.enableFolderColor = 0
        self.groupingMode = 0
        self.inheritParentFolderColor = 0
        self.language = language ?? "en_US"
        self.linkConfirmation = linkConfirmation == 0 ? .openAtWill : .confirmationAlert
        self.maxSpace = maxSpace ?? 0
        self.maxUpload = maxUpload ?? 0
        self.notificationEmail = ""
        self.notify = 0
        self.passwordMode = 1
        self.role = role ?? 0
        self.showImages = .none
        self.sign = 0
        self.subscribed = subscribed ?? 0
        self.swipeLeft = 3
        self.swipeRight = 0
        self.telemetry = DefaultValue.telemetry
        self.twoFactor = 0
        self.usedSpace = usedSpace ?? 0
        self.userAddresses = []
        self.userId = userId ?? ""
        self.userKeys = keys ?? [Key]()
        self.weekStart = 0
    }
    
    /// Update user addresses
    ///
    /// - Parameter addresses: new addresses
    public func set(addresses: [Address]) {
        self.userAddresses = addresses
    }
    
    /// set User, copy the data from input user object
    ///
    /// - Parameter userinfo: New user info
    public func set(userinfo: UserInfo) {
        self.delinquent = userinfo.delinquent
        self.language = userinfo.language
        self.linkConfirmation = userinfo.linkConfirmation
        self.maxSpace = userinfo.maxSpace
        self.maxUpload = userinfo.maxUpload
        self.role = userinfo.role
        self.subscribed = userinfo.subscribed
        self.usedSpace = userinfo.usedSpace
        self.userId = userinfo.userId
        self.userKeys = userinfo.userKeys
    }
}

// exposed interfaces
extension UserInfo {

    public var autoShowRemote: Bool {
        showImages.contains(.remote)
    }
    
    public var isPaid: Bool {
        return self.role > 0 ? true : false
    }
    
    public func firstUserKey() -> Key? {
        if self.userKeys.count > 0 {
            return self.userKeys[0]
        }
        return nil
    }
    
    public func getPrivateKey(by keyID: String?) -> String? {
        if let keyID = keyID {
            for userkey in self.userKeys where userkey.keyID == keyID {
                return userkey.privateKey
            }
        }
        return firstUserKey()?.privateKey
    }
    
    @available(*, deprecated, renamed: "isKeyV2")
    internal var newSchema: Bool {
        for key in addressKeys where key.newSchema {
            return true
        }
        return false
    }
    
    public var isKeyV2: Bool {
        return addressKeys.isKeyV2
    }
    
    /// TODO:: fix me - Key stuff
    public var addressKeys: [Key] {
        var out = [Key]()
        for addr in userAddresses {
            for key in addr.keys {
                out.append(key)
            }
        }
        return out
    }

    public func getAddressPrivKey(address_id: String) -> String {
        let addr = userAddresses.address(byID: address_id) ?? userAddresses.defaultSendAddress()
        return addr?.keys.first?.privateKey ?? ""
    }
    
    public func getAddressKey(address_id: String) -> Key? {
        let addr = userAddresses.address(byID: address_id) ?? userAddresses.defaultSendAddress()
        return addr?.keys.first
    }
    
    /// Get all keys that belong to the given address id
    /// - Parameter address_id: Address id
    /// - Returns: Keys of the given address id. nil means can't find the address
    public func getAllAddressKey(address_id: String) -> [Key]? {
        guard let addr = userAddresses.address(byID: address_id) else {
            return nil
        }
        return addr.keys
    }
}

// MARK: Deafult values

extension UserInfo {
    struct DefaultValue {
        static let telemetry: Int = 1
        static let crashReports: Int = 1
    }
}
