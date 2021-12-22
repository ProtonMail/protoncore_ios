//
//  AccountsAvailableForCreation.swift
//  ExampleApp - Created on 10/12/2021.
//  
//  Copyright (c) 2021 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation

public struct AccountAvailableForCreation {
    
    public enum AccountTypes {
        case free
        case subuser(alsoPublic: Bool)
        case plan(named: String)
    }
    
    public enum KeyTypes: String {
        case none = "None"
        case rsa2048 = "RSA2048"
        case rsa4096 = "RSA4096"
        case curve25519 = "Curve25519"
    }
    
    public enum AddressTypes {
        case noAddress
        case addressButNoKeys
        case addressWithKeys(type: KeyTypes)
    }
    
    public let type: AccountTypes
    public let username: String
    public let password: String
    public let mailboxPassword: String?
    public let address: AddressTypes
    public let description: String
    
    public init(type: AccountTypes = .free,
                username: String,
                password: String,
                mailboxPassword: String? = nil,
                address: AddressTypes = .noAddress,
                description: String) {
        self.type = type
        self.username = username
        self.password = password
        self.mailboxPassword = mailboxPassword
        self.address = address
        self.description = description
    }
    
    public static var freeNoAddressNoKeys: AccountAvailableForCreation {
        .init(username: .random,
              password: .random,
              description: "Free account with no address nor keys")
    }
    
    public static var freeWithAddressButWithoutKeys: AccountAvailableForCreation {
        .init(username: .random,
              password: .random,
              address: .addressButNoKeys,
              description: "Free with address but without keys")
    }
    
    public static var freeWithAddressAndKeys: AccountAvailableForCreation {
        .init(username: .random,
              password: .random,
              address: .addressWithKeys(type: .curve25519),
              description: "Free with address and keys")
    }
    
    public static var freeWithMailboxPassword: AccountAvailableForCreation {
        .init(username: .random,
              password: .random,
              mailboxPassword: .random,
              description: "Free account with mailbox password")
    }
    
    public static var subuserPublic: AccountAvailableForCreation {
        .init(type: .subuser(alsoPublic: true),
              username: .random,
              password: .random,
              mailboxPassword: .random,
              address: .addressWithKeys(type: .curve25519),
              description: "Subuser public account")
    }
    
    public static var subuserPrivate: AccountAvailableForCreation {
        .init(type: .subuser(alsoPublic: false),
              username: .random,
              password: .random,
              mailboxPassword: .random,
              address: .addressWithKeys(type: .curve25519),
              description: "Subuser private account")
    }
}

extension String {
    static var random: String {
        var result: String = ""
        for _ in 1...Int.random(in: 8...20) {
            let randomCharacter: Character = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".randomElement() ?? "p"
            result.append(randomCharacter)
        }
        return result
    }
}
