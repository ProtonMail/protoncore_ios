//
//  MailSending.swift
//  ProtonMail
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import AwaitKit
import PromiseKit
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_Authentication
import ProtonCore_Common
#if canImport(ProtonCore_Crypto_VPN)
import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
import ProtonCore_Crypto
#endif
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services

protocol CustomErrorVar {
    var code : Int { get }
    
    var desc : String { get }
    
    var reason : String { get }
}

/// Attachment content
public class AttachmentContent {
    
    var fileName: String
    var mimeType: String
    var keyPacket: String
    var dataPacket: Data
    
    /// based 64
    var fileData : String
    
    public init(fileName: String, mimeType: String, keyPacket: String, dataPacket: Data, fileData: String) {
        self.fileName = fileName
        self.mimeType = mimeType
        self.keyPacket = keyPacket
        self.dataPacket = dataPacket
        self.fileData = fileData
    }
}

public class Recipient : Package {
    
    public init(email: String, name: String) {
        self.email = email
        self.name = name
    }
    
    var email: String
    var name: String
    
    public var parameters: [String : Any]? {
        return nil
    }
    
}

/// Message content need to be send
public class MessageContent {
    /// recipints internal & external
    var recipients : [String] //chagne to Recipient later when use contacts
    
    /// encrypted message body. encrypted by self key
    var body: String = ""
    
    var subject : String
    
    var sign: Int = 0
    
    /// attachments need to be sent
    var attachments: [AttachmentContent]
    
    /// inital
    /// - Parameters:
    ///   - emails: email addresses
    ///   - body: event body
    ///   - attachments: attachments
    public init(recipients: [String], subject: String, body: String, attachments: [AttachmentContent]) {
        self.recipients = recipients
        self.subject = subject
        self.body = body
        self.attachments = attachments
    }
}

public typealias MailFeatureCompletion = (_ task: URLSessionDataTask?, _ response: [String: Any]?, _ error: ResponseError?) -> Void

/// shared features
public class MailFeature {
    
    enum RuntimeError : String, Error, CustomErrorVar {
        case cant_decrypt = "can't decrypt message body"
        case bad_draft
        var code: Int {
            get {
                return -1002000
            }
        }
        var desc: String {
            get {
                return self.rawValue
            }
        }
        var reason: String {
            get {
                return self.rawValue
            }
        }
    }
    
    let apiService: APIService
    
    
    /// api service
    /// - Parameter apiService
    public init(apiService: APIService) {
        self.apiService = apiService
    }
    
    /// send a email
    func sendEmail() {
        
    }

    
    public func send(content: MessageContent, userKeys: [Key], addressKeys: [Key], senderName: String, senderAddr: String,
                     password: String, auth: AuthCredential? = nil, completion: MailFeatureCompletion?) {
        
        var newUserKeys : [Key] = []
        for key in userKeys {
            newUserKeys.append(Key(keyID: key.keyID,
                                   privateKey: key.privateKey,
                                   token: nil, signature: nil,
                                   activation: nil,
                                   isUpdated: false))
        }
        
        var newAddrKeys : [Key] = []
        for key in addressKeys {
            newAddrKeys.append(Key(keyID: key.keyID,
                                   privateKey: key.privateKey,
                                   token: key.token, signature: key.signature,
                                   activation: nil,
                                   isUpdated: false))
        }
        self.send(content: content, userPrivKeys: newUserKeys, addrPrivKeys: newAddrKeys, senderName: senderName, senderAddr: senderAddr,
                  password: password, auth: auth, completion: completion)
    }
    
    internal func send(content: MessageContent, userPrivKeys: [Key], addrPrivKeys: [Key], senderName: String, senderAddr: String,
                       password: String, auth: AuthCredential? = nil, completion: MailFeatureCompletion?) {
        
        //let userPrivKeys = userInfo.userPrivateKeys
        let userPrivKeysArray = userPrivKeys.binPrivKeysArray
        //let addrPrivKeys = userInfo.addressKeys
        let newSchema = addrPrivKeys.isKeyV2
        let authCredential = auth
        let passphrase = password
        
        let sign = content.sign
        
        let addressKey = addrPrivKeys.first!


        var requests : [UserEmailPubKeys] = [UserEmailPubKeys]()
        let emails : [String] = content.recipients
        for email in emails {
            requests.append(UserEmailPubKeys(email: email, authCredential: authCredential))
        }
        
        // is encrypt outside -- disable now
        let isEO = false // !message.password.isEmpty
        
        // get attachment
        let attachments = content.attachments //self.attachmentsForMessage(message)
        
        //create builder
        let sendBuilder = SendBuilder()
        
        //current mail flow
        //get email public key from api
        //get email public key from contacts pinned
        //merge the keys above and use Pinned key > API response
    
        let body = content.body
        
        //build contacts if user setup key pinning
        let contacts : [PreContact] = [PreContact]()
//        firstly {
//            //fech addresses contact
//            //userManager.messageService.contactDataService.fetch(byEmails: emails, context: context)
//        }.then { (cs) -> Guarantee<[Result<KeysResponse>]> in
//            // fech email keys from api
//            contacts.append(contentsOf: cs)
//            return when(resolved: requests.getPromises(api: self.apiService))
//        }
        
        firstly {
            when(resolved: requests.getPromises(api: self.apiService))
        }.then { results -> Promise<SendBuilder> in
            //all prebuild errors need pop up from here
            guard let splited = try body.split(),
                  let bodyData = splited.dataPacket,
                  let keyData = splited.keyPacket,
                  let session = newSchema ?
                    try keyData.getSessionFromPubKeyPackage(userKeys: userPrivKeysArray,
                                                            passphrase: passphrase,
                                                            keys: addrPrivKeys) :
                    try keyData.getSessionFromPubKeyPackage(passphrase,
                                                            privKeys: addrPrivKeys.binPrivKeysArray) else {
                throw RuntimeError.cant_decrypt
            }
            guard let key = session.key else {
                throw RuntimeError.cant_decrypt
            }
            sendBuilder.update(bodyData: bodyData, bodySession: key, algo: session.algo)
            //sendBuilder.set(pwd: message.password, hit: message.passwordHint)
                        
            for (index, result) in results.enumerated() {
                switch result {
                case .fulfilled(let value):
                    let req = requests[index]
                    //check contacts have pub key or not
                    if let contact = contacts.find(email: req.email) {
                        if value.recipientType == 1 {
                            //if type is internal check is key match with contact key
                            //compare the key if doesn't match
                            sendBuilder.add(addr: PreAddress(email: req.email, pubKey: value.firstKey(), pgpKey: contact.firstPgpKey, recipintType: value.recipientType, eo: isEO, mime: false, sign: true, pgpencrypt: false, plainText: contact.plainText))
                        } else {
                            //sendBuilder.add(addr: PreAddress(email: req.email, pubKey: nil, pgpKey: contact.pgpKey, recipintType: value.recipientType, eo: isEO, mime: true))
                            sendBuilder.add(addr: PreAddress(email: req.email, pubKey: nil, pgpKey: contact.firstPgpKey, recipintType: value.recipientType, eo: isEO, mime: contact.mime, sign: contact.sign, pgpencrypt: contact.encrypt, plainText: contact.plainText))
                        }
                    } else {
                        if sign == 1 {
                            sendBuilder.add(addr: PreAddress(email: req.email, pubKey: value.firstKey(), pgpKey: nil, recipintType: value.recipientType, eo: isEO, mime: true, sign: true, pgpencrypt: false, plainText: false))
                        } else {
                            sendBuilder.add(addr: PreAddress(email: req.email, pubKey: value.firstKey(), pgpKey: nil, recipintType: value.recipientType, eo: isEO, mime: false, sign: false, pgpencrypt: false, plainText: false))
                        }
                    }
                case .rejected(let error):
                    throw error
                }
            }
            
            if sendBuilder.hasMime || sendBuilder.hasPlainText {
                guard let clearbody = newSchema ?
                        try body.decryptBody(keys: addrPrivKeys,
                                                userKeys: userPrivKeysArray,
                                                passphrase: passphrase) :
                        try body.decryptBody(keys: addrPrivKeys,
                                                passphrase: passphrase) else {
                    throw RuntimeError.cant_decrypt
                }
                sendBuilder.set(clear: clearbody)
            }
            
            for att in attachments {
 
                if let sessionPack = newSchema ?
                    try self.getSession(keyPacket: att.keyPacket, userKey: userPrivKeysArray,
                                        keys: addrPrivKeys,
                                        mailboxPassword: passphrase) :
                    try self.getSession(keyPacket: att.keyPacket, keys: addrPrivKeys.binPrivKeysArray,
                                        mailboxPassword: passphrase) {
                    guard let key = sessionPack.key else {
                        continue
                    }
                    sendBuilder.add(att: PreAttachment(id: "",
                                                       session: key,
                                                       algo: sessionPack.algo,
                                                       att: att))
                }
            }
            
            return .value(sendBuilder)
        }.then{ (sendbuilder) -> Promise<SendBuilder> in
            if !sendBuilder.hasMime {
                return .value(sendBuilder)
            }
            //build pgp sending mime body
            return sendBuilder.buildMime(senderKey: addressKey,
                                         passphrase: passphrase,
                                         userKeys: userPrivKeysArray,
                                         keys: addrPrivKeys,
                                         newSchema: newSchema)
        }.then{ (sendbuilder) -> Promise<SendBuilder> in
            
            if !sendBuilder.hasPlainText {
                return .value(sendBuilder)
            }

            //build pgp sending mime body
            return sendBuilder.buildPlainText(senderKey: addressKey,
                                              passphrase: passphrase,
                                              userKeys: userPrivKeysArray,
                                              keys: addrPrivKeys,
                                              newSchema: newSchema)
        } .then { sendbuilder -> Guarantee<[Result<AddressPackageBase>]> in
            
            //build address packages
            return when(resolved: sendbuilder.promises)
        }.then { results -> Promise<SendResponse> in
            
            //build api request
            let encodedBody = sendBuilder.bodyDataPacket.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            var msgs = [AddressPackageBase]()
            for res in results {
                switch res {
                case .fulfilled(let value):
                    msgs.append(value)
                case .rejected(let error):
                    throw error
                }
            }
            
            let sendApi = SendCalEvent.init(subject: content.subject,
                                            body: body,
                                            bodyData: encodedBody,
                                            senderName: senderName, senderAddr: senderAddr,
                                            recipients: content.recipients, atts: content.attachments,
                                            
                                            messagePackage: msgs, clearBody: sendBuilder.clearBodyPackage, clearAtts: sendBuilder.clearAtts,
                                            mimeDataPacket: sendBuilder.mimeBody, clearMimeBody: sendBuilder.clearMimeBodyPackage,
                                            plainTextDataPacket: sendBuilder.plainBody, clearPlainTextBody: sendBuilder.clearPlainBodyPackage,
                                            authCredential: authCredential)
            
            return self.apiService.run(route: sendApi)
        }.done { (res) in
            let error = res.error
            if error == nil {
                // sucessed
            } else {
                // failed
            }
            completion?(nil, nil, error)
        }.catch(policy: .allErrors) { (error) in
            let err = error as NSError
            //PMLog.D(error.localizedDescription)
            if err.code == 9001 {
                //here need let user to show the human check.
            } else if err.code == 15198 {
                
            } else if err.code == 15004 {
                // this error means the message has already been sent
                // so don't need to show this error to user
                completion?(nil, nil, nil)
                return
            } else if err.code == 33101 {
                //Email address validation failed
            } else if err.code == 2500 {
                // The error means "Message has already been sent"
                // Since the message is sent, this alert is useless to user
                completion?(nil, nil, nil)
                return
            } else {
                
            }
            
            completion?(nil, nil, ResponseError(httpCode: nil, responseCode: err.code, userFacingMessage: nil, underlyingError: err))
        }.finally {
            ///
        }
    }
    
    internal func getSession(keyPacket: String, keys: [Data], mailboxPassword: String) throws -> SymmetricKey? {

        let passphrase = mailboxPassword
        guard let data: Data = Data(base64Encoded: keyPacket, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
            return nil //TODO:: error throw
        }
        
        let sessionKey = try data.getSessionFromPubKeyPackage(passphrase, privKeys: keys)
        return sessionKey
    }
    
    internal func getSession(keyPacket: String, userKey: [Data], keys: [Key], mailboxPassword: String) throws -> SymmetricKey? {

        let passphrase = mailboxPassword
        let data: Data = Data(base64Encoded: keyPacket, options: NSData.Base64DecodingOptions(rawValue: 0))!
        
        let sessionKey = try data.getSessionFromPubKeyPackage(userKeys: userKey, passphrase: passphrase, keys: keys)
        return sessionKey
    }
    
}

extension UserInfo {
    var userPrivateKeys : Data {
        var out = Data()
        var error : NSError?
        for key in userKeys {
            if let privK = ArmorUnarmor(key.privateKey, &error) {
                out.append(privK)
            }
        }
        return out
    }
    
    var userPrivateKeysArray: [Data] {
        var out: [Data] = []
        var error: NSError?
        for key in userKeys {
            if let privK = ArmorUnarmor(key.privateKey, &error) {
                out.append(privK)
            }
        }
        return out
    }
    
}
