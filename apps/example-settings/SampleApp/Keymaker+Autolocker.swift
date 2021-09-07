//
//  Keymaker+Autolocker.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Keymaker
import ProtonCore_Settings

extension Keymaker: AutoLocker {
    public var autolockerTimeout: LockTime {
        LockTime(rawValue: DemoKeychain().lockTime.rawValue)
    }

    public func setAutolockerTimeout(_ timeout: LockTime) {
        DemoKeychain().lockTime = .init(rawValue: timeout.rawValue)
    }
}
