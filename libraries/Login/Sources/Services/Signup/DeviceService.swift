//
//  DeviceService.swift
//  ProtonCore-Login - Created on 11/03/2021.
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
#if canImport(IOKit)
import IOKit
#endif

public protocol DeviceServiceProtocol {
    func generateToken(result: @escaping (Result<String, SignupError>) -> Void)
}

public class DeviceService: DeviceServiceProtocol {
    
    let device: Any?
    
    @available(macOS 10.15, iOS 11.0, *)
    public init(device: DCDevice = DCDevice.current) {
        self.device = device
    }
    #if canImport(IOKit)
    public init() {
        self.device = nil
    }
    #endif
    
    public func generateToken(result: @escaping (Result<String, SignupError>) -> Void) {
        if #available(macOS 10.15, iOS 11.0, *) {
            generateTokenUsingDeviceCheckAPI(result: result)
        } else {
            #if canImport(IOKit)
            generateTokenUsingSerialNumberAPI(result: result)
            #else
            result(.failure(.deviceTokenUnsuported))
            #endif
        }
    }
    
    @available(macOS 10.15, iOS 11.0, *)
    func generateTokenUsingDeviceCheckAPI(result: @escaping (Result<String, SignupError>) -> Void) {
        guard let device = device as? DCDevice, device.isSupported else {
            DispatchQueue.main.async {
                result(.failure(SignupError.deviceTokenUnsuported))
            }
            return
        }
        device.generateToken(completionHandler: { (data, error) in
            DispatchQueue.main.async {
                if let tokenData = data {
                    result(.success(tokenData.base64EncodedString()))
                } else if let error = error {
                    #if targetEnvironment(simulator)
                    result(.success("test"))
                    #else
                    result(.failure(SignupError.generic(message: error.messageForTheUser)))
                    #endif
                } else {
                    result(.failure(SignupError.deviceTokenError))
                }
            }
        })
    }
    
    #if canImport(IOKit)
    public func generateTokenUsingSerialNumberAPI(result: @escaping (Result<String, SignupError>) -> Void) {
        
        // after https://developer.apple.com/library/archive/technotes/tn1103/_index.html
        
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
        guard platformExpert > 0 else { return result(.failure(.deviceTokenError)) }
        
        defer { IOObjectRelease(platformExpert) }
        let propertyRef = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0)
        guard let serialNumber = propertyRef?.takeUnretainedValue() as? String else {
            return result(.failure(.deviceTokenError))
        }
        
        result(.success(serialNumber))
    }
    #endif
}
