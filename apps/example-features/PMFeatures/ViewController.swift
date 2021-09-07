//
//  ViewController.swift
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
import ProtonCore_Authentication
import ProtonCore_Authentication_KeyGeneration
import ProtonCore_DataModel
import ProtonCore_Doh
import ProtonCore_Features
import ProtonCore_Networking
import ProtonCore_Services
import PromiseKit
import AwaitKit

class ProdDoHMail: DoH, ServerConfig {

    var signupDomain: String = ObfuscatedConstants.liveSignupDomain
    var defaultHost: String = ObfuscatedConstants.liveDefaultHost
    var captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    var apiHost: String = ObfuscatedConstants.liveApiHost

    static let `default` = try! ProdDoHMail()
}

class ViewController: UIViewController, TrustKitUIDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var receipientTextField: UITextField!
    
    private var authCredential: AuthCredential?
    private var user: User?
    private var addresses: [Address]?
    var liveApi = PMAPIService(doh: ProdDoHMail.default, sessionUID: "testSessionUID")
    
    private var keypassphrase = ""
    
    override func viewDidLoad() {
        TrustKitWrapper.start(delegate: self)
        PMAPIService.noTrustKit = false
        PMAPIService.trustKit = TrustKitWrapper.current
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
            print("no username or password or receipient")
            return
        }

        let emails = emailsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        liveApi.authDelegate = self
        ProdDoHMail.default.status = .off
        liveApi.serviceDelegate = self
        
        let authApi = Authenticator(api: liveApi)
        authApi.authenticate(username: username, password: password) { result in
            switch result {
            case .success(.newCredential(let credential, _)):
                self.authCredential = AuthCredential(credential)
                
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
                                        self.authCredential?.update(salt: salts.first?.keySalt, privateKey: nil)
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
                print(error)
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
        
        guard let encrypted = try! plainData.encryptAttachment(fileName: "invite.ics", pubKey: firstKey.privateKey.publicKey) else {
            return
        }
        let emails = emails
        let body = try! "You are invited to testing 222".encrypt(withPrivKey: firstKey.privateKey, mailbox_pwd: keypassphrase)

        let attData = NSMutableData()
        attData.append(encrypted.keyPacket!)
        attData.append(encrypted.dataPacket!)
        
        let att = AttachmentContent.init(fileName: "invite.ics", mimeType: "text/calendar",
                                         keyPacket: encrypted.keyPacket!.encodeBase64(), dataPacket: encrypted.dataPacket!,
                                         fileData: (attData as Data).encodeBase64())
        
        let msgContent = MessageContent.init(recipients: emails, subject: "Invitation for an event starting on Mar 8, 2021, 2:30 PM (GMT-8) Testing", body: body!, attachments: [att])
        features.send(content: msgContent,
                      userKeys: self.user!.keys,
                      addressKeys: address.keys,
                      senderName: address.displayName.isEmpty ? address.email : address.displayName,
                      senderAddr: address.email,
                      password: self.keypassphrase) { (task, res, error) in
            print(task as Any, res as Any, error as Any)
        }
    }

    func onTrustKitValidationError(_ alert: UIAlertController) {

    }

}


extension ViewController: AuthDelegate {
    func getToken(bySessionUID uid: String) -> AuthCredential? {
        return authCredential
    }
    
    func onLogout(sessionUID uid: String) {
    }
    
    func onUpdate(auth: Credential) {
    }
    
    func onRefresh(bySessionUID uid: String, complete: @escaping AuthRefreshComplete) {
    }
    
    func onForceUpgrade() {
    }
}

extension ViewController: APIServiceDelegate {

    var locale: String {
        "en_US"
    }

    var userAgent: String? {
        return "" //need to be set
    }
    
    func isReachable() -> Bool {
        return true
    }
    
    
    var appVersion: String {
        return "iOSCalendar_0.2.4"
    }
    
    func onChallenge(challenge: URLAuthenticationChallenge,
                     credential: AutoreleasingUnsafeMutablePointer<URLCredential?>?) -> URLSession.AuthChallengeDisposition {
        
        var dispositionToReturn: URLSession.AuthChallengeDisposition = .performDefaultHandling
        if let validator = TrustKitWrapper.current?.pinningValidator {
            validator.handle(challenge, completionHandler: { (disposition, credentialOut) in
                credential?.pointee = credentialOut
                dispositionToReturn = disposition
            })
        } else {
            assert(false, "TrustKit not initialized correctly")
        }
        
        return dispositionToReturn
    }
    
    func onUpdate(serverTime: Int64) {
        // on update the server time for user.
        Crypto.CryptoUpdateTime(serverTime)
    }

    func onDohTroubleshot() {
        // show up Doh Troubleshot view
    }
}
