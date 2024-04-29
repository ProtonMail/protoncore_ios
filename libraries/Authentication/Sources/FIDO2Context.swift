//
//  FIDO2Context.swift
//  ProtonCore-Authentication - Created on 29/04/24.
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
import ProtonCoreServices
import ProtonCoreNetworking

/// Holds the bits necessary for signing a FIDO2 challenge
public struct FIDO2Context {
    public let fido2: TwoFA.Fido2 // For now, passing everything as it's not clear what is needed
    public let credential: Credential
}
