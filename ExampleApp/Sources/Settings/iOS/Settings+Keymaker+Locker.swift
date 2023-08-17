//
//  Settings+Keymaker+Locker.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCoreLog
import ProtonCoreKeymaker
import ProtonCoreSettings

// MARK: - Pin locking
extension Keymaker: PinLocker { }

extension Keymaker: PinLockActivator {
    public func activatePin(pin: String, completion: @escaping (Bool) -> Void) {
        let protector = PinProtection(pin: pin, keychain: SettingsDemoKeychain())
        activate(protector, completion: { success in
            let result = success ? "succeed ✅" : "failed ❌"
            completion(success)
            PMLog.info("Activate protection with \(protector.self) \(result)! 🔒")
        })
    }
}

extension Keymaker: PinLockDeactivator {
    public func deactivatePin(completion: @escaping (Bool) -> Void) {
        let protector = PinProtection(pin: "12345", keychain: SettingsDemoKeychain())
        let success = deactivate(protector)
        let result = success ? "succeed ✅" : "failed ❌"
        completion(success)
        PMLog.info("Deactivate protection with \(protector.self) \(result) 🗝🔓!")
    }
}

// TODO: Implement Bio locking methods
extension Keymaker: BioLocker { }

extension Keymaker: BioLockActivator {
    public func activateBio(completion: @escaping (Bool) -> Void) {
        let protector = BioProtection(keychain: SettingsDemoKeychain())
        activate(protector, completion: { success in
            let result = success ? "succeed ✅" : "failed ❌"
            completion(success)
            PMLog.info("Activate protection with \(protector.self) \(result)! 🔒")
        })
    }
}

extension Keymaker: BioLockDeactivator {
    public func deactivateBio(completion: @escaping (Bool) -> Void) {
        let protector = BioProtection(keychain: SettingsDemoKeychain())
        let success = deactivate(protector)
        let result = success ? "succeed ✅" : "failed ❌"
        completion(success)
        PMLog.info("Deactivate protection with \(protector.self) \(result) 🗝🔓!")
    }
}
