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

struct AccountAvailableForCreation {
    let username: String
    let password: String
    let mailboxPassword: String?
    let description: String
    
    private init(username: String,
                 password: String,
                 mailboxPassword: String?,
                 description: String) {
        self.username = username
        self.password = password
        self.mailboxPassword = mailboxPassword
        self.description = description
    }
    
    static var basicFree: AccountAvailableForCreation {
        .init(username: .random,
              password: .random,
              mailboxPassword: nil,
              description: "Basic free account")
    }
    
    static var freeWithMailboxPassword: AccountAvailableForCreation {
        .init(username: .random,
              password: .random,
              mailboxPassword: .random,
              description: "Free account with mailbox password")
    }
}

let accountsAvailableForCreation: [AccountAvailableForCreation] = [
    .basicFree,
    .freeWithMailboxPassword
]

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
