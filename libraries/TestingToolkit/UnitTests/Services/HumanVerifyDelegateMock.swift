//
//  HumanVerifyDelegateMock.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import ProtonCoreNetworking
import ProtonCoreServices

public final class HumanVerifyDelegateMock: HumanVerifyDelegate {

    public init() {}

    @PropertyStub(\HumanVerifyDelegateMock.responseDelegateForLoginAndSignup, initialGet: nil) public var responseDelegateForLoginAndSignupStub
    public var responseDelegateForLoginAndSignup: ProtonCoreServices.HumanVerifyResponseDelegate? {
        get { responseDelegateForLoginAndSignupStub() }
        set { responseDelegateForLoginAndSignupStub(newValue) }
    }

    @PropertyStub(\HumanVerifyDelegateMock.paymentDelegateForLoginAndSignup, initialGet: nil) public var paymentDelegateForLoginAndSignupStub
    public var paymentDelegateForLoginAndSignup: ProtonCoreServices.HumanVerifyPaymentDelegate? {
        get { paymentDelegateForLoginAndSignupStub() }
        set { paymentDelegateForLoginAndSignupStub(newValue) }
    }
    
    @FuncStub(HumanVerifyDelegateMock.onHumanVerify) public var onHumanVerifyStub
    public func onHumanVerify(parameters: HumanVerifyParameters,
                              currentURL: URL?,
                              completion: @escaping ((HumanVerifyFinishReason) -> Void)) {
        onHumanVerifyStub(parameters, currentURL, completion)
    }
    
    @FuncStub(HumanVerifyDelegateMock.onDeviceVerify, initialReturn: nil) public var onDeviceVerifyStub
    public func onDeviceVerify(parameters: DeviceVerifyParameters) -> String? {
        onDeviceVerifyStub(parameters)
    }
    
    @FuncStub(HumanVerifyDelegateMock.getSupportURL, initialReturn: URL(string: "https://protoncore.unittest")!) public var getSupportURLStub
    public func getSupportURL() -> URL {
        getSupportURLStub()
    }
}
