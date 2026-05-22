//
//  MailSettings.swift
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

public struct MailSettings: Codable {
    public let displayName: String?
    public let signature: String?
    public let hideEmbeddedImages: Int?
    public let hideRemoteImages: Int?
    public let imageProxy: Int?
    public let autoSaveContacts: Int?
    public let swipeLeft: Int?
    public let swipeRight: Int?
    public let confirmLink: Int?
    public let attachPublicKey: Int?
    public let sign: Int?
    public let enableFolderColor: Int?
    public let inheritParentFolderColor: Int?
    public let viewMode: Int?
    public let delaySendSeconds: Int?
    public let mobileSettings: MobileSettings?

    public init(displayName: String? = nil,
                signature: String? = nil,
                hideEmbeddedImages: Int? = nil,
                hideRemoteImages: Int? = nil,
                imageProxy: Int? = nil,
                autoSaveContacts: Int? = nil,
                swipeLeft: Int? = nil,
                swipeRight: Int? = nil,
                confirmLink: Int? = nil,
                attachPublicKey: Int? = nil,
                sign: Int? = nil,
                enableFolderColor: Int? = nil,
                inheritParentFolderColor: Int? = nil,
                viewMode: Int? = nil,
                delaySendSeconds: Int? = nil,
                mobileSettings: MobileSettings? = nil) {
        self.displayName = displayName
        self.signature = signature
        self.hideEmbeddedImages = hideEmbeddedImages
        self.hideRemoteImages = hideRemoteImages
        self.imageProxy = imageProxy
        self.autoSaveContacts = autoSaveContacts
        self.swipeLeft = swipeLeft
        self.swipeRight = swipeRight
        self.confirmLink = confirmLink
        self.attachPublicKey = attachPublicKey
        self.sign = sign
        self.enableFolderColor = enableFolderColor
        self.inheritParentFolderColor = inheritParentFolderColor
        self.viewMode = viewMode
        self.delaySendSeconds = delaySendSeconds
        self.mobileSettings = mobileSettings
    }

    public struct MobileSettings: Codable {
        public let conversationToolbar: ToolbarActions?
        public let messageToolbar: ToolbarActions?
        public let listToolbar: ToolbarActions?

        public init(conversationToolbar: ToolbarActions? = nil,
                    messageToolbar: ToolbarActions? = nil,
                    listToolbar: ToolbarActions? = nil) {
            self.conversationToolbar = conversationToolbar
            self.messageToolbar = messageToolbar
            self.listToolbar = listToolbar
        }
    }
}
