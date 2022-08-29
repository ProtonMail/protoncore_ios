//
//  FeaturesViewController.swift
//  PMFeatures
//
//  Created by zhj4478 on 03/08/2021.
//  Copyright (c) 2021 zhj4478. All rights reserved.
//

import UIKit
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
#if canImport(ProtonCore_Crypto_VPN)
import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
import ProtonCore_Crypto
#endif
import ProtonCore_Authentication
import ProtonCore_Authentication_KeyGeneration
import ProtonCore_DataModel
import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Features
import ProtonCore_Networking
import ProtonCore_Services

class FeaturesViewController: UIViewController, TrustKitUIDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var receipientTextField: UITextField!
    
    private var authHelper: AuthHelper?
    private var user: User?
    private var addresses: [Address]?
    var liveApi = PMAPIService(doh: clientApp == .vpn ? ProdDoHVPN.default : ProdDoHMail.default, sessionUID: "testSessionUID")
    
    private var keypassphrase = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        liveApi.getSession()?.setChallenge(noTrustKit: false, trustKit: TrustKitWrapper.current)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func sendButtonTapped() {

        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              !username.isEmpty,
              !password.isEmpty,
              let emailsString = receipientTextField.text,
              !emailsString.isEmpty
        else {
            PMLog.info("no username or password or receipient")
            return
        }

        let emails = emailsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        authHelper = AuthHelper()
        liveApi.authDelegate = authHelper
        liveApi.serviceDelegate = self

        let authApi = Authenticator(api: liveApi)
        authApi.authenticate(username: username, password: password, challenge: nil) { result in
            switch result {
            case .success(.newCredential(let credential, _)):
                self.authHelper?.onUpdate(credential: credential, sessionUID: self.liveApi.sessionUID)
                authApi.getUserInfo { resUser in
                    switch resUser {
                    case .success(let user):
                        self.user = user
                        authApi.getAddresses { resAddr in
                            switch resAddr {
                            case .success(let addresses):
                                self.addresses = addresses
                                authApi.getKeySalts { resSalt in
                                    switch resSalt {
                                    case .success(let salts):
                                        self.authHelper?.updateAuth(for: self.liveApi.sessionUID, password: nil, salt: salts.first?.keySalt, privateKey: nil)
                                        guard let salt = salts.first?.keySalt else {
                                            return
                                        }
                                        
                                        let keysalt: Data = salt.decodeBase64()
                                        
                                        self.keypassphrase = PasswordHash.hashPassword(password, salt: keysalt)
                                        self.testSendEvent(emails: emails)
                                    case .failure:
                                        break
                                    }
                                    
                                }
                            case .failure:
                                break
                            }
                        }
                    case .failure:
                        break
                    }
                }
            case .failure(AuthErrors.networkingError(let error)):
                PMLog.info(String(describing: error))
            case .failure(AuthErrors.apiMightBeBlocked(_, _)):
                self.onDohTroubleshot()
            case .failure(_):
                break
            case .success(.ask2FA((_, _))):
                break
            case .success(.updatedCredential(_)):
                break
            }
        }
    }

    func testSendEvent(emails: [String]) {
        let features = MailFeature.init(apiService: self.liveApi)
        guard let localFile = Bundle.main.path(forResource: "testinvite", ofType: "ics") else {
            return
        }
        guard let content = try? String(contentsOfFile: localFile) else {
            return
        }
        guard let plainData = content.data(using: .utf8) else {
            return
        }
        guard let address = self.addresses?.first else {
            return
        }
        
        // this should be the first valid key
        guard let firstKey = address.keys.first else {
            return
        }
        
        let encrypted = try! plainData.encryptAttachmentNonOptional(fileName: "invite.ics",
                                                                    pubKey: firstKey.privateKey.publicKey)
        let emails = emails
        let body = try! "You are invited to testing 222".encryptNonOptional(withPrivKey: firstKey.privateKey,
                                                                            mailbox_pwd: keypassphrase)

        let attData = NSMutableData()
        attData.append(encrypted.keyPacket!)
        attData.append(encrypted.dataPacket!)
        
        let att = AttachmentContent.init(fileName: "invite.ics", mimeType: "text/calendar",
                                         keyPacket: encrypted.keyPacket!.encodeBase64(), dataPacket: encrypted.dataPacket!,
                                         fileData: (attData as Data).encodeBase64())
        
        let msgContent = MessageContent(recipients: emails, subject: "Invitation for an event starting on Mar 8, 2021, 2:30 PM (GMT-8) Testing", body: body, attachments: [att])
        features.send(content: msgContent,
                      userKeys: self.user!.keys,
                      addressKeys: address.keys,
                      senderName: address.displayName.isEmpty ? address.email : address.displayName,
                      senderAddr: address.email,
                      password: Passphrase.init(value: self.keypassphrase)) { (task, res, error) in
            PMLog.info("\(String(describing: task)), \(String(describing: res)), \(String(describing: error))")
        }
    }

    func onTrustKitValidationError(_ alert: UIAlertController) {

    }

}

extension FeaturesViewController: APIServiceDelegate {
    
    var additionalHeaders: [String : String]? { nil }

    var locale: String { Locale.autoupdatingCurrent.identifier }

    var userAgent: String? { "" }
    
    func isReachable() -> Bool { true }
    
    var appVersion: String { appVersionHeader.getVersionHeader() }
    
    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}
