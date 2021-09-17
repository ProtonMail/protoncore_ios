//
//  ObfuscatedConstants.base.swift
//  ProtonCore-SampleApps-Example-Login - Created on 20.07.2021
//
//  Copyright (c) 2021 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

// Auto generated file, don't change it manually

enum ObfuscatedConstants {

    // live environment
    static let liveSignupDomain: String = "example.com"
    static let liveDefaultHostWithoutHttps: String = "example.com"
    static let liveDefaultHost: String = "https://example.com"
    static let liveCaptchaHost: String = "https://example.com"
    static let liveApiHost: String = "example.com"
    static let liveDefaultPath: String = ""

    static let samplePinningHost: String = ""

    static func samplePinningConfiguration(hardfail: Bool) -> [String: Any] { [:] }
}
