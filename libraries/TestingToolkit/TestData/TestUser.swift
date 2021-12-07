//
//  TestUser.swift
//  ProtonCore-TestingToolkig - Created on 23.04.21.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
#if canImport(SwiftOTP)
import SwiftOTP
#endif
import ProtonCore_Log

public class TestUser {
    
    public var email: String
    public var password: String
    public var mailboxPassword: String
    public var twoFASecurityKey: String
    public var username: String
    public var pmMeEmail: String
    
    public init(email: String, password: String, mailboxPassword: String, twoFASecurityKey: String) {
        self.email = email
        self.password = password
        self.mailboxPassword = mailboxPassword
        self.twoFASecurityKey = twoFASecurityKey
        self.username = String(email.split(separator: "@")[0])
        self.pmMeEmail = "\(username)@pm.me"
    }
    
    public init(user: String) {
        let userData = user.split(separator: ",")
        self.email = String(userData[0])
        self.password = String(userData[1])
        self.mailboxPassword = String(userData[2])
        self.twoFASecurityKey = String(userData[3])
        self.username = String(String(userData[0]).split(separator: "@")[0])
        self.pmMeEmail = "\(username)@pm.me"
    }
    
    #if canImport(SwiftOTP)
    public func generateCode() -> String {
        let totp = TOTP(secret: base32DecodeToData(twoFASecurityKey)!)
        
        if let res = totp?.generate(time: Date()) {
            return res
        }
        return ""
    }
    #endif
}

// TODO to optimize user cretaion function if there will be more spec. users

public func createVPNUser(host: String, username: String, password: String) -> (username: String, password: String) {
    let urlString = "\(host)/api/internal/quark/user:create?-N=\(username)&-p=\(password)"
    let url = URL(string: urlString)!
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        PMLog.debug("""
                    url: \(urlString)
                    data: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? "<none>")
                    error: \(error.flatMap { String(describing: $0) } ?? "<none>")
                    response: \(response.flatMap { String(describing: $0) } ?? "<none>")
                    """)
    }
    task.resume()
    
    return (username, password)
}

public func createUserWithAddressNoKeys(host: String, username: String, password: String) -> (username: String, password: String) {
    let urlString = "\(host)/api/internal/quark/user:create?-N=\(username)&-p=\(password)&--create-address=null"
    let url = URL(string: urlString)!
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        PMLog.debug("""
                    url: \(urlString)
                    data: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? "<none>")
                    error: \(error.flatMap { String(describing: $0) } ?? "<none>")
                    response: \(response.flatMap { String(describing: $0) } ?? "<none>")
                    """)
    }
    task.resume()
    
    return (username, password)
}

public func createOrgUser(host: String, username: String, password: String, createPrivateUser: Bool) -> (username: String, password: String) {
    let privateUser = createPrivateUser ? 1 : 0
    let urlString = "\(host)/api/internal/quark/user:create:subuser?-N=\(username)&-p=\(password)&--private=\(privateUser)&-k=Curve25519&ownerUserID=787&ownerPassword=a"
    let url = URL(string: urlString)!
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        PMLog.debug("""
                    url: \(urlString)
                    data: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? "<none>")
                    error: \(error.flatMap { String(describing: $0) } ?? "<none>")
                    response: \(response.flatMap { String(describing: $0) } ?? "<none>")
                    """)
    }
    task.resume()
    
    return (username, password)
}
