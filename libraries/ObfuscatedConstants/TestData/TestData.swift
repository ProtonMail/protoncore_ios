//
//  TestData.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import Foundation

public class TestData {
    public init() { }
    
    public var onePassUser = User(email: ObfuscatedConstants.onePassUserUsername, password: ObfuscatedConstants.onePassUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var twoPassUser = User(email: ObfuscatedConstants.twoPassUserUsername, password: ObfuscatedConstants.twoPassUserPassword, mailboxPassword: ObfuscatedConstants.twoPassUserMailboxPassword, twoFASecurityKey: "")
    public var onePassUserWith2Fa = User(email: ObfuscatedConstants.onePassUserWith2FaUsername, password: ObfuscatedConstants.onePassUserWith2FaPassword, mailboxPassword: "", twoFASecurityKey: ObfuscatedConstants.onePassUserWith2FatwoFASecurityKey)
    public var twoPassUserWith2Fa = User(email: ObfuscatedConstants.twoPassUserWith2FaUsername, password: ObfuscatedConstants.twoPassUserWith2FaPassword, mailboxPassword: ObfuscatedConstants.twoPassUserWith2FaMailboxPassword, twoFASecurityKey: ObfuscatedConstants.twoPassUserWith2FatwoFASecurityKey)
    public var disabledUser = User(email: ObfuscatedConstants.disabledUserUsername, password: ObfuscatedConstants.disabledUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var vpnFreeUser = User(email: ObfuscatedConstants.vpnFreeUserUsername, password: ObfuscatedConstants.vpnFreeUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var vpnBasicUser = User(email: ObfuscatedConstants.vpnBasicUserUsername, password: ObfuscatedConstants.vpnBasicUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var orgAdminUser = User(email: ObfuscatedConstants.orgAdminUserUsername, password: ObfuscatedConstants.orgAdminUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var orgPrivateUser = User(email: ObfuscatedConstants.orgPrivateUserUsername, password: ObfuscatedConstants.orgPrivateUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var orgPublicUser = User(email: ObfuscatedConstants.orgPublicUserUsername, password: ObfuscatedConstants.orgPublicUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var orgNewPrivateUser = User(email: ObfuscatedConstants.orgNewPrivateUserEmail, password: ObfuscatedConstants.orgNewPrivateUserPassword, mailboxPassword: "", twoFASecurityKey: "")
    public var usernameVpnFreeUser = User(email: ObfuscatedConstants.usernameVpnFreeUserEmail, password: ObfuscatedConstants.usernameVpnFreeUserPassword, mailboxPassword: "", twoFASecurityKey: "")
}

