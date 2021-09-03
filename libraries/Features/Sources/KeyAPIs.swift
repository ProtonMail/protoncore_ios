//
//  KeyAPIs.swift
//  PMFeatures
//
//  Created by Yanfeng Zhang on 3/8/21.
//

import Foundation
import PromiseKit
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_Common
import ProtonCore_DataModel
import ProtonCore_KeyManager
import ProtonCore_Networking
import ProtonCore_Services

//Keys API
struct KeysAPI {
    static let path : String = "/keys"
}


///KeysResponse
final class UserEmailPubKeys : Request {
    let email : String
    
    init(email: String, authCredential: AuthCredential? = nil) {
        self.email = email
        self.auth = authCredential
    }
    
    var parameters: [String : Any]? {
        let out : [String : Any] = ["Email" : self.email]
        return out
    }
    
    var path: String {
        return KeysAPI.path
    }
    
    //custom auth credentical
    let auth: AuthCredential?
    var authCredential : AuthCredential? {
        get {
            return self.auth
        }
    }
}

extension Array where Element : UserEmailPubKeys {
    func getPromises(api: APIService) -> [Promise<KeysResponse>] {
        var out : [Promise<KeysResponse>] = [Promise<KeysResponse>]()
        for it in self {
            out.append(api.run(route: it))
        }
        return out
    }
}


final class KeyResponse {
    //TODO:: change to bitmap later
    var flags : Int = 0 // bitmap: 1 = can be used to verify, 2 = can be used to encrypt
    var publicKey : String?
   
    init(flags : Int, pubkey: String?) {
        self.flags = flags
        self.publicKey = pubkey
    }
}


final class KeysResponse : Response {
    var recipientType : Int = 1 // 1 internal 2 external
    var mimeType : String?
    var keys : [KeyResponse] = [KeyResponse]()
    override func ParseResponse(_ response: [String : Any]!) -> Bool {
        self.recipientType = response["RecipientType"] as? Int ?? 1
        self.mimeType = response["MIMEType"] as? String
        
        if let keyRes = response["Keys"] as? [[String : Any]] {
            for keyDict in keyRes {
                let flags =  keyDict["Flags"] as? Int ?? 0
                let pubKey = keyDict["PublicKey"] as? String
                self.keys.append(KeyResponse(flags: flags, pubkey: pubKey))
            }
        }
        return true
    }
    
    func firstKey () -> String? {
        for k in keys {
            if k.flags == 2 ||  k.flags == 3 {
                return k.publicKey
            }
        }
        return nil
    }
    
    //TODO:: change to filter later.
    func getCompromisedKeys() -> Data?  {
        var pubKeys : Data? = nil
        for k in keys {
            if k.flags == 0 {
                if pubKeys == nil {
                    pubKeys = Data()
                }
                if let p = k.publicKey {
                    var error : NSError?
                    if let data = ArmorUnarmor(p, &error) {
                        if error == nil && data.count > 0 {
                            pubKeys?.append(data)
                        }
                    }
                }
            }
        }
        return pubKeys
    }
    
    func getVerifyKeys() -> Data? {
        var pubKeys : Data? = nil
        for k in keys {
            if k.flags == 1 || k.flags == 3 {
                if pubKeys == nil {
                    pubKeys = Data()
                }
                if let p = k.publicKey {
                    var error : NSError?
                    if let data = ArmorUnarmor(p, &error) {
                        if error == nil && data.count > 0 {
                            pubKeys?.append(data)
                        }
                    }
                }
            }
        }
        return pubKeys
    }
}
