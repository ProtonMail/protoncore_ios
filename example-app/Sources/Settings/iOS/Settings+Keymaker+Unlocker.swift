//
//  Settings+Keymaker+Unlocker.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Log
import ProtonCore_Keymaker
import ProtonCore_Settings

// MARK: - Unlocking
extension Keymaker: PinUnlocker {
    public func pinUnlock(pin: String, completion: @escaping UnlockResult) {
        obtainMainKey(with: PinProtection(pin: pin, keychain: SettingsDemoKeychain()), handler: { key in
            guard let key = key, !key.isEmpty else {
                PMLog.info("Tried to unlock with PIN ❌.")
                return completion(false)
            }
            PMLog.info("Unlock with PIN ✅. \n Key: \(key)")
            completion(true)
        })
    }
}

extension Keymaker: BioUnlocker {
    public func bioUnlock(completion: @escaping UnlockResult) {
        obtainMainKey(with: BioProtection(keychain: SettingsDemoKeychain()), handler: { key in
            guard let key = key, !key.isEmpty else {
                PMLog.info("Tried to unlock with BIO ❌.")
                return completion(false)
            }
            PMLog.info("Unlock with BIO ✅. \n Key: \(key)")
            completion(true)
        })
    }
}
