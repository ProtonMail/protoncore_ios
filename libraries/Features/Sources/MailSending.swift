//
//  MailSending.swift
//  ProtonCore-Features - Created on 08.03.2021.
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
import ProtonCoreAuthentication
import ProtonCoreCrypto
import ProtonCoreCryptoGoInterface
import ProtonCoreDataModel
import ProtonCoreKeyManager
import ProtonCoreNetworking
import ProtonCoreServices

protocol CustomErrorVar {
    var code: Int { get }
    var desc: String { get }
    var reason: String { get }
}

/// Attachment content
public class AttachmentContent {
    public var fileName: String
    public var mimeType: String
    public var keyPacket: String
    public var dataPacket: Data

    /// based 64
    public var fileData: String

    public init(fileName: String, mimeType: String, keyPacket: String, dataPacket: Data, fileData: String) {
        self.fileName = fileName
        self.mimeType = mimeType
        self.keyPacket = keyPacket
        self.dataPacket = dataPacket
        self.fileData = fileData
    }
}

public enum RecipientType: Int {
    case `internal` = 1
    case external = 2
}

public struct Recipient: Equatable {
    public let email: String
    public let type: RecipientType
    public let activePublicKeys: [ActivePublicKey]

    var publicKeyForEncryption: String? {
        activePublicKeys
            .first { $0.flags.contains(.encryptNewData) }?
            .publicKey
    }

    public init(email: String, type: RecipientType, activePublicKeys: [ActivePublicKey]) {
        self.email = email
        self.type = type
        self.activePublicKeys = activePublicKeys
    }
}

public struct ActivePublicKey: Equatable {
    public let flags: KeyFlags
    public let publicKey: String

    public init(flags: KeyFlags, publicKey: String) {
        self.flags = flags
        self.publicKey = publicKey
    }
}

/// Message content need to be send
public class MessageContent {
    /// recipints internal & external
    var recipients: [Recipient]

    /// encrypted message body. encrypted by self key
    var body: String = ""

    var subject: String

    var sign: Int = 0

    /// attachments need to be sent
    var attachments: [AttachmentContent]

    /// initial
    /// - Parameters:
    ///   - emails: email addresses
    ///   - body: event body
    ///   - attachments: attachments
    public init(recipients: [Recipient], subject: String, body: String, attachments: [AttachmentContent]) {
        self.recipients = recipients
        self.subject = subject
        self.body = body
        self.attachments = attachments
    }
}

public typealias MailFeatureCompletion = (_ task: URLSessionDataTask?, _ response: [String: Any]?, _ error: ResponseError?) -> Void

/// shared features
public class MailFeature {
    enum RuntimeError: String, Error, CustomErrorVar {
        case cant_decrypt = "can't decrypt message body"
        case bad_draft
        var code: Int { -1002000 }
        var desc: String { self.rawValue }
        var reason: String { self.rawValue }
    }

    let apiService: APIService

    /// api service
    /// - Parameter apiService
    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public func send(
        content: MessageContent,
        userKeys: [Key],
        addressKeys: [Key],
        senderName: String,
        senderAddr: String,
        password: Passphrase,
        contacts: [PreContact],
        auth: AuthCredential? = nil,
        completion: MailFeatureCompletion?
    ) {
        send(
            content: content,
            userPrivKeys: userKeys,
            addrPrivKeys: addressKeys,
            senderName: senderName,
            senderAddr: senderAddr,
            password: password,
            contacts: contacts,
            auth: auth,
            completion: completion
        )
    }

    public static func messageRequest(
        content: MessageContent,
        userKeys: [Key],
        addressKeys: [Key],
        senderName: String,
        senderAddr: String,
        password: Passphrase,
        contacts: [PreContact],
        auth: AuthCredential? = nil
    ) throws -> SendCalEvent {
        let newKeys = newKeys(oldUserKeys: userKeys, oldAddressKeys: addressKeys)

        return try message(
            content: content,
            userPrivKeys: newKeys.userKeys,
            addrPrivKeys: newKeys.addressKeys,
            senderName: senderName,
            senderAddr: senderAddr,
            password: password,
            contacts: contacts,
            auth: auth
        )
    }

    private let sendQueue = DispatchQueue(label: "ch.protonmail.ios.protoncore.features.send", attributes: [])

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    internal static func message(
        content: MessageContent,
        userPrivKeys: [Key],
        addrPrivKeys: [Key],
        senderName: String,
        senderAddr: String,
        password: Passphrase,
        contacts: [PreContact],
        auth: AuthCredential? = nil
    ) throws -> SendCalEvent {
        let userPrivKeysArray = userPrivKeys.binPrivKeysArray
        let newSchema = addrPrivKeys.isKeyV2
        let authCredential = auth
        let passphrase = password
        let sign = content.sign
        let addressKey = addrPrivKeys.first!
        let isEO = false
        let attachments = content.attachments
        var sendBuilder = SendBuilder()
        let body = content.body

        guard let splited = try body.split(),
              let bodyData = splited.dataPacket,
              let keyData = splited.keyPacket,
              let session = newSchema ? try? keyData.getSessionFromPubKeyPackageNonOptional(
                userKeys: userPrivKeysArray,
                passphrase: passphrase.value,
                keys: addrPrivKeys
              ) : try? keyData.getSessionFromPubKeyPackageNonOptional(
                passphrase.value,
                privKeys: addrPrivKeys.binPrivKeysArray
              ) else { throw RuntimeError.cant_decrypt }
        guard let key = session.key else {
            throw RuntimeError.cant_decrypt
        }

        sendBuilder.update(bodyData: bodyData, bodySession: key, algo: session.algo)

        content.recipients.forEach { recipient in
            if let contact = contacts.find(email: recipient.email) {
                if recipient.type == .internal {
                    sendBuilder.addPreAddress(
                        recipient: recipient,
                        pubKey: recipient.publicKeyForEncryption,
                        pgpKey: contact.firstPgpKey,
                        isEO: isEO,
                        hasMime: false,
                        isSigned: true,
                        isPgpEncrypted: false,
                        isPlainText: true
                    )
                } else {
                    let areKeysEmpty = recipient.activePublicKeys.isEmpty
                    sendBuilder.addPreAddress(
                        recipient: recipient,
                        pubKey: nil,
                        pgpKey: areKeysEmpty ? nil : contact.firstPgpKey,
                        isEO: isEO,
                        hasMime: areKeysEmpty ? false : contact.hasMime,
                        isSigned: contact.isSigned,
                        isPgpEncrypted: contact.isEncrypted,
                        isPlainText: true
                    )
                }
            } else {
                if sign == 1 {
                    sendBuilder.addPreAddress(
                        recipient: recipient,
                        pubKey: recipient.publicKeyForEncryption,
                        pgpKey: nil,
                        isEO: isEO,
                        hasMime: true,
                        isSigned: true,
                        isPgpEncrypted: false,
                        isPlainText: true
                    )
                } else {
                    sendBuilder.addPreAddress(
                        recipient: recipient,
                        pubKey: recipient.publicKeyForEncryption,
                        pgpKey: nil,
                        isEO: isEO,
                        hasMime: false,
                        isSigned: false,
                        isPgpEncrypted: false,
                        isPlainText: true
                    )
                }
            }
        }

        if sendBuilder.hasMime || sendBuilder.hasPlainText {
            guard let clearbody = newSchema ? try body.decryptBody(
                keys: addrPrivKeys,
                userKeys: userPrivKeysArray,
                passphrase: passphrase
            ) : try body.decryptBody(
                keys: addrPrivKeys,
                passphrase: passphrase
            ) else { throw RuntimeError.cant_decrypt }
            sendBuilder.set(clear: clearbody)
        }

        for att in attachments {
            if let sessionPack = newSchema ? try self.getSession(
                    keyPacket: att.keyPacket, userKey: userPrivKeysArray,
                    keys: addrPrivKeys,
                    mailboxPassword: passphrase.value
            ) : try self.getSession(
                keyPacket: att.keyPacket, keys: addrPrivKeys.binPrivKeysArray,
                mailboxPassword: passphrase.value
            ) {
                guard let key = sessionPack.key else {
                    continue
                }
                sendBuilder.add(
                    att: PreAttachment(
                        id: "",
                        session: key,
                        algo: sessionPack.algo,
                        att: att
                    )
                )
            }
        }

        if sendBuilder.hasMime {
            sendBuilder = try sendBuilder.buildMime(
                senderKey: addressKey,
                passphrase: passphrase.value,
                userKeys: userPrivKeysArray,
                keys: addrPrivKeys,
                newSchema: newSchema
            )
        }

        if sendBuilder.hasPlainText {
            sendBuilder = try sendBuilder.buildPlainText(
                senderKey: addressKey,
                passphrase: passphrase.value,
                userKeys: userPrivKeysArray,
                keys: addrPrivKeys,
                newSchema: newSchema
            )
        }

        let addressPackages: [Result<AddressPackageBase, Error>] = sendBuilder.buildAddressPackages()
        let encodedBody = sendBuilder.bodyDataPacket.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        var msgs = [AddressPackageBase]()
        for res in addressPackages {
            switch res {
            case .success(let value):
                msgs.append(value)
            case .failure(let error):
                throw error
            }
        }

        return SendCalEvent.init(
            subject: content.subject,
            body: body,
            bodyData: encodedBody,
            senderName: senderName, senderAddr: senderAddr,
            recipients: content.recipients.map(\.email),
            atts: content.attachments,
            messagePackage: msgs,
            clearBody: sendBuilder.clearBodyPackage,
            clearAtts: sendBuilder.clearAtts,
            mimeDataPacket: sendBuilder.mimeBody,
            clearMimeBody: sendBuilder.clearMimeBodyPackage,
            plainTextDataPacket: sendBuilder.plainBody,
            clearPlainTextBody: sendBuilder.clearPlainBodyPackage,
            authCredential: authCredential
        )
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    internal func send(
        content: MessageContent,
        userPrivKeys: [Key],
        addrPrivKeys: [Key],
        senderName: String,
        senderAddr: String,
        password: Passphrase,
        contacts: [PreContact],
        auth: AuthCredential? = nil,
        completion: MailFeatureCompletion?
    ) {
        do {
            let messageRequest = try MailFeature.messageRequest(
                content: content,
                userKeys: userPrivKeys,
                addressKeys: addrPrivKeys,
                senderName: senderName,
                senderAddr: senderAddr,
                password: password,
                contacts: contacts
            )

            sendQueue.async {
                self.apiService.perform(request: messageRequest, response: SendResponse()) { _, response in
                    DispatchQueue.main.async {
                        completion?(nil, nil, response.error)
                    }
                }
            }
        } catch {
            let err = error as NSError
            // PMLog.D(error.localizedDescription)
            if err.code == 9001 {
                // here need let user to show the human check.
            } else if err.code == 15198 {

            } else if err.code == 15004 {
                // this error means the message has already been sent
                // so don't need to show this error to user
                DispatchQueue.main.async {
                    completion?(nil, nil, nil)
                }
                return
            } else if err.code == 33101 {
                // Email address validation failed
            } else if err.code == 2500 {
                // The error means "Message has already been sent"
                // Since the message is sent, this alert is useless to user
                DispatchQueue.main.async {
                    completion?(nil, nil, nil)
                }
                return
            } else {

            }
            DispatchQueue.main.async {
                completion?(nil, nil, ResponseError(httpCode: nil, responseCode: err.code, userFacingMessage: nil, underlyingError: err))
            }
        }
    }

    internal static func getSession(keyPacket: String, keys: [Data], mailboxPassword: String) throws -> SymmetricKey? {
        let passphrase = mailboxPassword
        guard let data: Data = Data(base64Encoded: keyPacket, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
            return nil // TODO:: error throw
        }

        let sessionKey = try data.getSessionFromPubKeyPackageNonOptional(passphrase, privKeys: keys)
        return sessionKey
    }

    internal static func getSession(keyPacket: String, userKey: [Data], keys: [Key], mailboxPassword: String) throws -> SymmetricKey? {
        let passphrase = mailboxPassword
        let data: Data = Data(base64Encoded: keyPacket, options: NSData.Base64DecodingOptions(rawValue: 0))!

        let sessionKey = try data.getSessionFromPubKeyPackageNonOptional(userKeys: userKey, passphrase: passphrase, keys: keys)
        return sessionKey
    }

}

private extension SendBuilder {

    func addPreAddress(
        recipient: Recipient,
        pubKey: String?,
        pgpKey: Data?,
        isEO: Bool,
        hasMime: Bool,
        isSigned: Bool,
        isPgpEncrypted: Bool,
        isPlainText: Bool
    ) {
        add(addr: PreAddress(
            email: recipient.email,
            pubKey: pubKey,
            pgpKey: pgpKey,
            recipintType: recipient.type.rawValue,
            eo: isEO,
            hasMime: hasMime,
            isSigned: isSigned,
            isPgpEncrypted: isPgpEncrypted,
            isPlainText: isPlainText
        ))
    }

}

private extension MailFeature {
    struct NewKeys {
        let userKeys: [Key]
        let addressKeys: [Key]
    }

    static func newKeys(oldUserKeys: [Key], oldAddressKeys: [Key]) -> NewKeys {
        var newUserKeys: [Key] = []
        for key in oldUserKeys {
            newUserKeys.append(
                Key(
                    keyID: key.keyID,
                    privateKey: key.privateKey,
                    token: nil,
                    signature: nil,
                    activation: nil,
                    isUpdated: false
                )
            )
        }

        var newAddrKeys: [Key] = []
        for key in oldAddressKeys {
            newAddrKeys.append(
                Key(
                    keyID: key.keyID,
                    privateKey: key.privateKey,
                    token: key.token,
                    signature: key.signature,
                    activation: nil,
                    isUpdated: false
                )
            )
        }

        return .init(userKeys: newUserKeys, addressKeys: newAddrKeys)
    }
}

extension UserInfo {
    var userPrivateKeys: Data {
        var out = Data()
        var error: NSError?
        for key in userKeys {
            if let privK = CryptoGo.ArmorUnarmor(key.privateKey, &error) {
                out.append(privK)
            }
        }
        return out
    }

    var userPrivateKeysArray: [Data] {
        var out: [Data] = []
        var error: NSError?
        for key in userKeys {
            if let privK = CryptoGo.ArmorUnarmor(key.privateKey, &error) {
                out.append(privK)
            }
        }
        return out
    }

}
