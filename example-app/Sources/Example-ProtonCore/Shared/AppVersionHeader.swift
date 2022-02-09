//
//  AppVersionHeader.swift
//  ExampleApp - Created on 04.02.22.
//  
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation

class AppVersionHeader {
    
    private let appNamePrefix: String
    private let defaults = UserDefaults.standard
    
    init(appNamePrefix: String) {
        self.appNamePrefix = appNamePrefix
    }
    
    func getVersionHeader() -> String {
        let version = readVersion() ?? getDefaultVersion()
        return appNamePrefix + version
    }
    
    func getVersion() -> String? {
        return readVersion()
    }
    
    func getDefaultVersion() -> String {
        return Bundle.main.majorVersion
    }
    
    func setVersion(version: String?) {
        guard let version = version else {
            resetVersion()
            return
        }
        writeVersion(version: version)
    }
    
    func resetVersion() {
        defaults.removeObject(forKey: appNamePrefix)
    }
    
    // MARK: Private interface
    
    private func readVersion() -> String? {
        return defaults.object(forKey: appNamePrefix) as? String
    }
    
    private func writeVersion(version: String) {
        defaults.set(version, forKey: appNamePrefix)
    }
}
