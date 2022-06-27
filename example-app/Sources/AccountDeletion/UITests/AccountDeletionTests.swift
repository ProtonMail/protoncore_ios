//
//  Example_AccountDeletion_UITests.swift
//  Example-AccountDeletion-UITests - Created on 20/12/2021.
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

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_QuarkCommands
import ProtonCore_ObfuscatedConstants

final class AccountDeletionTests: AccountDeletionBaseTestCase {
    
    let defaultTestOwnerID = ObfuscatedConstants.orgAdminUserId
    let defaultTestOwnerPassword = ObfuscatedConstants.orgAdminUserPassword
    
    // MARK: - Deletion flow is available
    
    func testAccountDeletionCanBeClosed() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionWebViewRobot.self)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .tapCancelButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsDisplayed(type: .button)
    }
    
    func testAccountDeletionNeedsConfirmation() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionWebViewRobot.self)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            // no confirmation
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    
    func testAccountDeletionNeedsReason() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionWebViewRobot.self)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            // no reason
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    func testAccountDeletionNeedsExplaination() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionWebViewRobot.self)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            // no explaination
            .fillInDeletionEmail()
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    func testAccountDeletionNeedsEmail() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionWebViewRobot.self)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            // no email
            .fillInDeletionPassword(password)
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    func testAccountDeletionNeedsPassword() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionWebViewRobot.self)
            .verify.accountDeletionWebViewIsOpened()
            .verify.accountDeletionWebViewIsLoaded()
            .setDeletionReason()
            .fillInDeletionExplaination()
            .fillInDeletionEmail()
            // no password
            .confirmBeingAwareAccountDeletionIsPermanent()
            .tapDeleteAccountButton(to: AccountDeletionButtonRobot.self)
            .verify.accountDeletionButtonIsNotShown(type: .button)
    }
    
    // MARK: - Deletion works when it should work
    
    //    public static func freeNoAddressNoKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(username: username ?? .random,
    //              password: password ?? .random,
    //              description: "Free account with no address nor keys")
    //    }
    
    func testAccountIsDeleted_FreeNoAddressNoKeys() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeNoAddressNoKeys())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func freeWithAddressButWithoutKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressButNoKeys,
    //              description: "Free with address but without keys")
    //    }
    
    func testAccountIsDeleted_FreeWithAddressButWithoutKeys() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeWithAddressButWithoutKeys())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func freeWithAddressAndKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Free with address and keys")
    //    }
    
    func testAccountIsDeleted_FreeWithAddressAndKeys() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeWithAddressAndKeys())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func freeWithAddressAndMailboxPassword(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              mailboxPassword: .random,
    //              description: "Free account with mailbox password")
    //    }
    
    func testAccountIsDeleted_FreeWithAddressAndMailboxPassword() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.freeWithAddressAndMailboxPassword())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
//    public static func externalNoKeys(
//        email: String? = nil, password: String? = nil
//    ) -> AccountAvailableForCreation {
//        .init(type: .external,
//              username: email ?? .randomEmail,
//              password: password ?? .random,
//              description: "External account with no keys")
//    }
    
    func testAccountIsDeleted_External() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.external())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func paid(
    //        plan: String, username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .plan(named: plan, status: .active),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              description: "Paid with plan \(plan)")
    //    }
    
    func testAccountIsDeleted_Paid_Plus() throws {
        let password = randomPassword
        appRobot
            .switchPickerToAccount(.paid(plan: ""))
            .fillInCustomCredentials(password: password, plan: "plus")
            .createPaidAccount()
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    func testAccountIsDeleted_Paid_VPNBasic() throws {
        let password = randomPassword
        appRobot
            .switchPickerToAccount(.paid(plan: ""))
            .fillInCustomCredentials(password: password, plan: "vpnbasic")
            .createPaidAccount()
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    func testAccountIsDeleted_Paid_VPNPlus() throws {
        let password = randomPassword
        appRobot
            .switchPickerToAccount(.paid(plan: ""))
            .fillInCustomCredentials(password: password, plan: "vpnplus")
            .createPaidAccount()
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    func testAccountIsDeleted_Paid_Professional() throws {
        let password = randomPassword
        appRobot
            .switchPickerToAccount(.paid(plan: ""))
            .fillInCustomCredentials(password: password, plan: "professional")
            .createPaidAccount()
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    func testAccountIsDeleted_Paid_Visionary() throws {
        let password = randomPassword
        appRobot
            .switchPickerToAccount(.paid(plan: ""))
            .fillInCustomCredentials(password: password, plan: "visionary")
            .createPaidAccount()
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func vpnAdminWithAddressAndKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .free(status: .vpnAdmin),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "VPN admin account with address and keys")
    //    }
    
    func testAccountIsDeleted_VpnAdminWithAddressAndKeys() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.vpnAdminWithAddressAndKeys())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func adminWithAddressAndKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .free(status: .admin),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Admin account with address and keys")
    //    }
    
    func testAccountIsDeleted_AdminWithAddressAndKeys() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.adminWithAddressAndKeys())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    //    public static func superWithAddressAndKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .free(status: .super),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Super account with address and keys")
    //    }
    
    func testAccountIsDeleted_SuperWithAddressAndKeys() throws {
        let (robot, password, _, _) = appRobot
            .switchPickerToAccount(.superWithAddressAndKeys())
            .createAccount()
        robot
            .performAccountDeletion(password: password, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionWasSuccessful()
    }
    
    // MARK: - Deletion doesn't works when it should not work
    
    //    public static func deletedWithAddressAndKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .free(status: .deleted),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Deleted account with address and keys")
    //    }
    
    func testAccountDeletionFails_DeletedWithAddressAndKeys() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.deletedWithAddressAndKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func disabledWithAddressAndKeys(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .free(status: .disabled),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Disabled account with address and keys")
    //    }
    
    func testAccountDeletionFails_DisabledWithAddressAndKeys() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.disabledWithAddressAndKeys())
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func subuserPublic(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: true),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser public account")
    //    }
    
    func testAccountDeletionFails_SubuserPublic() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.subuserPublic(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func subuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser private account")
    //    }
    
    func testAccountDeletionFails_SubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.subuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func deletedSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .deleted),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser deleted private account")
    //    }
    
    func testAccountDeletionFails_DeletedSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.deletedSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func disabledSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .disabled),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser disabled private account")
    //    }
    
    func testAccountDeletionFails_DisabledSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.disabledSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func baseAdminSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .baseAdmin),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser baseAdmin private account")
    //    }
    
    func testAccountDeletionFails_BaseAdminSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.baseAdminSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func adminSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .admin),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser admin private account")
    //    }
    
    func testAccountDeletionFails_AdminSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.adminSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func superSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .super),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser super private account")
    //    }
    
    func testAccountDeletionFails_SuperSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.superSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func abuserSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .abuser),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser abuser private account")
    //    }
    
    func testAccountDeletionFails_AbuserSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.abuserSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func restrictedSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .restricted),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser restricted private account")
    //    }
    
    func testAccountDeletionFails_RestrictedSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.restrictedSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func bulkSenderSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .bulkSender),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser bulkSender private account")
    //    }
    
    func testAccountDeletionFails_BulkSenderSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.bulkSenderSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func ransomwareSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .ransomware),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser ransomware private account")
    //    }
    
    func testAccountDeletionFails_RansomwareSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.ransomwareSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func compromisedSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .compromised),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser compromised private account")
    //    }
    
    func testAccountDeletionFails_CompromisedSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.compromisedSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func bulkSignupSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .bulkSignup),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser bulkSignup private account")
    //    }
    
    func testAccountDeletionFails_BulkSignupSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.bulkSignupSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func bulkDisabledSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .bulkDisabled),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser bulkDisabled private account")
    //    }
    
    func testAccountDeletionFails_BulkDisabledSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.bulkDisabledSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func criminalSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .criminal),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser criminal private account")
    //    }
    
    func testAccountDeletionFails_CriminalSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.criminalSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func chargeBackSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .chargeBack),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser chargeBack private account")
    //    }
    
    func testAccountDeletionFails_ChargeBackSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.chargeBackSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func inactiveSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .inactive),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser inactive private account")
    //    }
    
    func testAccountDeletionFails_InactiveSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.inactiveSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func forcePasswordChangeSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .forcePasswordChange),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser forcePasswordChange private account")
    //    }
    
    func testAccountDeletionFails_ForcePasswordChangeSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.forcePasswordChangeSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func selfDeletedSubuserPrivate(
    //        username: String? = nil, password: String? = nil
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .selfDeleted),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser selfDeleted private account")
    //    }
    
    func testAccountDeletionFails_SelfDeletedSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.selfDeletedSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func csaSubuserPrivate(
    //        username: String?, password: String?
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .csa),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser csa private account")
    //    }
    
    func testAccountDeletionFails_CsaSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.csaSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
    
    //    public static func spammerSubuserPrivate(
    //        username: String?, password: String?
    //    ) -> AccountAvailableForCreation {
    //        .init(type: .subuser(ownerUserId: "787", ownerUserPassword: "a", alsoPublic: false, status: .spammer),
    //              username: username ?? .random,
    //              password: password ?? .random,
    //              address: .addressWithKeys(type: .curve25519),
    //              description: "Subuser spammer private account")
    //    }
    
    func testAccountDeletionFails_SpammerSubuserPrivate() throws {
        let (robot, _, _, _) = appRobot
            .switchPickerToAccount(.spammerSubuserPrivate(ownerUserId: "", ownerUserPassword: ""))
            .fillInCustomCredentials(username: randomName, password: randomPassword,
                                     ownerId: defaultTestOwnerID, ownerPassword: defaultTestOwnerPassword)
            .createAccount()
        robot
            .verify.accountDeletionButtonIsDisplayed(type: .button)
            .openAccountDeletionWebView(type: .button, to: AccountDeletionSampleAppRobot.self)
            .verifyAccountDeletionFailed()
    }
}
