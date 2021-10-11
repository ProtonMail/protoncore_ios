//
//  Settings+Keymaker+LockReader.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Keymaker
import ProtonCore_Settings

// MARK: - Lock reader
extension Keymaker: LockReader {
    public var isBioProtected: Bool {
        isProtectorActive(BioProtection.self)
    }

    public var isPinProtected: Bool {
        isProtectorActive(PinProtection.self)
    }
}
