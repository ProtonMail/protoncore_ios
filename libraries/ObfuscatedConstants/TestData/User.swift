//
//  User.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import Foundation
import SwiftOTP

public class User {
    
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
    
    public func generateCode() -> String {
        let totp = TOTP(secret: base32DecodeToData(twoFASecurityKey)!)
        
        if let res = totp?.generate(time: Date()) {
            return res
        }
        return ""
    }
}

//TODO to optimize user cretaion function if there will be more spec. users

public func createVPNUser(host: String, username: String, password: String) -> (username: String, password: String) {
    let url = URL(string: "\(host)/api/internal/quark/user:create?-N=\(username)&-p=\(password)")!
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
    
    return (username, password)
}

public func createUserWithAddressNoKeys(host: String, username: String, password: String) -> (username: String, password: String) {
    let url = URL(string: "\(host)/api/internal/quark/user:create?-N=\(username)&-p=\(password)&--create-address=null")!
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
    
    return (username, password)
}

public func createOrgUser(host: String, username: String, password: String, createPrivateUser: Bool) -> (username: String, password: String) {
    let privateUser = createPrivateUser ? 1 : 0
    let url = URL(string: "\(host)/api/internal/quark/user:create:subuser?-N=\(username)&-p=\(password)&--private=\(privateUser)&-k=Curve25519&ownerUserID=787&ownerPassword=a")!
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
    
    return (username, password)
}
