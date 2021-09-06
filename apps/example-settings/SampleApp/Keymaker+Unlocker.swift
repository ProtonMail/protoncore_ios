//
//  Keymaker+Unlocker.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Keymaker
import ProtonCore_Settings

// MARK: - Unlocking
extension Keymaker: PinUnlocker {
    public func pinUnlock(pin: String, completion: @escaping UnlockResult) {
        obtainMainKey(with: PinProtection(pin: pin, keychain: DemoKeychain()), handler: { key in
            guard let key = key, !key.isEmpty else {
                print("Tried to unlock with PIN ❌.")
                return completion(false)
            }
            print("Unlock with PIN ✅. \n Key: \(key)")
            completion(true)
        })
    }
}

extension Keymaker: BioUnlocker {
    public func bioUnlock(completion: @escaping UnlockResult) {
        obtainMainKey(with: BioProtection(keychain: DemoKeychain()), handler: { key in
            guard let key = key, !key.isEmpty else {
                print("Tried to unlock with BIO ❌.")
                return completion(false)
            }
            print("Unlock with BIO ✅. \n Key: \(key)")
            completion(true)
        })
    }
}
