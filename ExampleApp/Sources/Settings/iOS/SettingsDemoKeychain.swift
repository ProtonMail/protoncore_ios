//
//  SettingsDemoKeychain.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCoreKeymaker

public final class SettingsDemoKeychain: Keychain {
    public init() {
        let prefix = "2SB5Z68H26."
        let group = prefix + "ch.protontech.core.ios.ExampleApp"
        let service = "ch.protontech.core.ios"

        super.init(service: service, accessGroup: group)
    }
}


extension SettingsDemoKeychain: SettingsProvider {
    private static var LockTimeKey = "DemoKeychain.LockTimeKey"

    public var lockTime: AutolockTimeout {
        get {
            guard let string = self.string(forKey: Self.LockTimeKey), let intValue = Int(string) else {
                return .never
            }
            return AutolockTimeout(rawValue: intValue)
        }
        set {
            self.set(String(newValue.rawValue), forKey: Self.LockTimeKey)
        }
    }
}
