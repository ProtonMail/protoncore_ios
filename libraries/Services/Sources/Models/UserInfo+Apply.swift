//
//  UserInfo+Apply.swift
//  ProtonCore-Services - Created on 21/05/2026.
//
//  Copyright (c) 2026 Proton Technologies AG
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
import ProtonCoreDataModel

public extension UserInfo {
    /// Patch semantics: only fields present in `userSettings` overwrite existing values.
    func apply(_ userSettings: UserSettings) {
        if let value = userSettings.email?.value {
            self.notificationEmail = value
        }
        if let notify = userSettings.email?.notify {
            self.notify = notify
        }
        self.passwordMode = userSettings.password.mode.rawValue
        self.twoFactor = userSettings._2FA.enabled.rawValue
        if let weekStart = userSettings.weekStart {
            self.weekStart = weekStart
        }
        if let telemetry = userSettings.telemetry {
            self.telemetry = telemetry
        }
        if let crashReports = userSettings.crashReports {
            self.crashReports = crashReports
        }
        if let referral = userSettings.referral {
            self.referralProgram = .init(link: referral.link, eligible: referral.eligible)
        }
        if let edmOptOut = userSettings.flags?.edmOptOut {
            self.edmOptOut = edmOptOut
        }
    }

    /// Overwrite semantics: every field is written, with defaults matching the legacy `parse(mailSettings:)`.
    func apply(_ mailSettings: MailSettings) {
        self.displayName = mailSettings.displayName ?? "'"
        self.defaultSignature = mailSettings.signature ?? ""
        self.hideEmbeddedImages = mailSettings.hideEmbeddedImages ?? UserInfo.DefaultValue.hideEmbeddedImages
        self.hideRemoteImages = mailSettings.hideRemoteImages ?? UserInfo.DefaultValue.hideRemoteImages
        self.imageProxy = ImageProxy(rawValue: mailSettings.imageProxy ?? UserInfo.DefaultValue.imageProxy.rawValue)
        self.autoSaveContact = mailSettings.autoSaveContacts ?? 0
        self.swipeLeft = mailSettings.swipeLeft ?? 3
        self.swipeRight = mailSettings.swipeRight ?? 0
        self.linkConfirmation = (mailSettings.confirmLink ?? 0) == 0 ? .openAtWill : .confirmationAlert
        self.attachPublicKey = mailSettings.attachPublicKey ?? 0
        self.sign = mailSettings.sign ?? 0
        self.enableFolderColor = mailSettings.enableFolderColor ?? 0
        self.inheritParentFolderColor = mailSettings.inheritParentFolderColor ?? 0
        self.groupingMode = mailSettings.viewMode ?? 0
        self.delaySendSeconds = mailSettings.delaySendSeconds ?? 10

        if let mobile = mailSettings.mobileSettings {
            if let toolbar = mobile.conversationToolbar {
                self.conversationToolbarActions = toolbar
            }
            if let toolbar = mobile.messageToolbar {
                self.messageToolbarActions = toolbar
            }
            if let toolbar = mobile.listToolbar {
                self.listToolbarActions = toolbar
            }
        }
    }
}
