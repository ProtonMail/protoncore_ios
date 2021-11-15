//
//  DeviceServiceMock.swift
//  ProtonCore-Login-Tests - Created on 08.04.21.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import Foundation
import DeviceCheck

@available(macOS 10.15, iOS 11.0, *)
public class DCDeviceMock: DCDevice {

    public let mockIsSupported: Bool
    public let mockData: Data?
    public let mockError: Error?

    public init(isSupported: Bool, data: Data? = nil, error: Error? = nil) {
        mockIsSupported = isSupported
        mockData = data
        mockError = error
    }

    override public class var current: DCDevice {
        return super.current
    }

    override public var isSupported: Bool {
        return mockIsSupported
    }

    override public func generateToken(completionHandler completion: @escaping (Data?, Error?) -> Void) {
        return completion(mockData, mockError)
    }
}
