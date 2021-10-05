//
//  SrpAuthMock.swift
//  ProtonCore-Authentication-Tests - Created on 01/10/2021.
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

#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_TestingToolkit

class SrpAuthMock: SrpAuth {
    @ThrowingFuncStub(SrpAuthMock.generateProofs, initialReturn: SrpProofs()) public var generateProofsStub
    override func generateProofs(_ bitLength: Int) throws -> SrpProofs {
        try generateProofsStub(bitLength)
    }
}
