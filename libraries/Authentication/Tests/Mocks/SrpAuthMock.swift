//
//  SrpAuthMock.swift
//  ProtonCore-Authentication-Tests - Created on 01/10/2021.
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
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreTestingToolkitUnitTestsAuthentication)
import ProtonCoreTestingToolkitUnitTestsAuthentication
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif

class SrpAuthMock: SrpAuth {
    
    init() {}
    
    var modulus: Data?
    var serverEphemeral: Data?
    var hashedPassword: Data?
    var version: Int = 0
    
    @ThrowingFuncStub(SrpAuthMock.generateVerifier, initialReturn: Data()) public var generateVerifierStub
    func generateVerifier(_ bitLength: Int) throws -> Data {
        try generateVerifierStub(bitLength)
    }
    
    @ThrowingFuncStub(SrpAuthMock.generateProofs, initialReturn: CryptoGo.SrpProofs()) public var generateProofsStub
    func generateProofs(_ bitLength: Int) throws -> SrpProofs {
        try generateProofsStub(bitLength)
    }
}
