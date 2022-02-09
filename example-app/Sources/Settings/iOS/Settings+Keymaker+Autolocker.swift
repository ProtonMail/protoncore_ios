//
//  Settings+Keymaker+Autolocker.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Keymaker
import ProtonCore_Settings

extension Keymaker: AutoLocker {
    public var autolockerTimeout: LockTime {
        LockTime(rawValue: SettingsDemoKeychain().lockTime.rawValue)
    }

    public func setAutolockerTimeout(_ timeout: LockTime) {
        SettingsDemoKeychain().lockTime = .init(rawValue: timeout.rawValue)
    }
}
