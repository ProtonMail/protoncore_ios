//
//  TestData.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import Foundation

class TestData {
    
    var onePassUser = User(email: ObfuscatedConstants.onePassUserUsername, password: ObfuscatedConstants.onePassUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var twoPassUser = User(email: ObfuscatedConstants.twoPassUserUsername, password: ObfuscatedConstants.twoPassUserPassword, mailboxPassword: ObfuscatedConstants.twoPassUserMailboxPassword, twoFASecurityKey: "")
    var onePassUserWith2Fa = User(email: ObfuscatedConstants.onePassUserWith2FaUsername, password: ObfuscatedConstants.onePassUserWith2FaPassword, mailboxPassword: "", twoFASecurityKey: ObfuscatedConstants.onePassUserWith2FatwoFASecurityKey)
    var twoPassUserWith2Fa = User(email: ObfuscatedConstants.twoPassUserWith2FaUsername, password: ObfuscatedConstants.twoPassUserWith2FaPassword, mailboxPassword: ObfuscatedConstants.twoPassUserWith2FaMailboxPassword, twoFASecurityKey: ObfuscatedConstants.twoPassUserWith2FatwoFASecurityKey)
    var disabledUser = User(email: ObfuscatedConstants.disabledUserUsername, password: ObfuscatedConstants.disabledUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var vpnFreeUser = User(email: ObfuscatedConstants.vpnFreeUserUsername, password: ObfuscatedConstants.vpnFreeUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var vpnBasicUser = User(email: ObfuscatedConstants.vpnBasicUserUsername, password: ObfuscatedConstants.vpnBasicUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var orgAdminUser = User(email: ObfuscatedConstants.orgAdminUserUsername, password: ObfuscatedConstants.orgAdminUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var orgPrivateUser = User(email: ObfuscatedConstants.orgPrivateUserUsername, password: ObfuscatedConstants.orgPrivateUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var orgPublicUser = User(email: ObfuscatedConstants.orgPublicUserUsername, password: ObfuscatedConstants.orgPublicUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var orgNewPrivateUser = User(email: ObfuscatedConstants.orgNewPrivateUserEmail, password: ObfuscatedConstants.orgNewPrivateUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    var usernameVpnFreeUser = User(email: ObfuscatedConstants.usernameVpnFreeUserEmail, password: ObfuscatedConstants.usernameVpnFreeUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    
    /*let editedPassword = "P@ssw0rd!"
    let editedPasswordHint = "ProtonMail"*/
}

