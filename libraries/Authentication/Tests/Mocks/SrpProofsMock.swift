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

import GoLibs

class SrpProofsMock: SrpProofs {
    var clientProof_: Data?
    var clientEphemeral_: Data?
    var expectedServerProof_: Data?

    override var clientProof: Data? {
        get {
            return clientProof_
        }
        set {
            clientProof_ = newValue
        }
    }
    override var clientEphemeral: Data? {
        get {
            return clientEphemeral_
        }
        set {
            clientEphemeral_ = newValue
        }
    }
    override var expectedServerProof: Data? {
        get {
            return expectedServerProof_
        }
        set {
            expectedServerProof_ = newValue
        }
    }
}
