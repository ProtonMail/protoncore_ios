//
//  Settings+Keymaker+LockReader.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCoreKeymaker
import ProtonCoreSettings

// MARK: - Lock reader
extension Keymaker: LockReader {
    public var isBioProtected: Bool {
        isProtectorActive(BioProtection.self)
    }

    public var isPinProtected: Bool {
        isProtectorActive(PinProtection.self)
    }
}
