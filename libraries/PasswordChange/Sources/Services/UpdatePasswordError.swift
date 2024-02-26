//
//  UpdatePasswordError.swift
//  ProtonCore-PasswordChange - Created on 20.03.2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

// code start at 0x110000
enum UpdatePasswordError: Int, Error {
    case invalidUserName = 0x110001
    case invalidModulusID = 0x110002
    case invalidModulus = 0x110003
    case cantHashPassword = 0x110004
    case cantGenerateVerifier = 0x110005
    case cantGenerateSRPClient = 0x110006

    // mailbox password part
    case currentPasswordWrong = 0x110008
    case newNotMatch = 0x110009
    case passwordEmpty = 0x110010
    case keyUpdateFailed = 0x110011

    case minimumLengthError = 0x110012

    case `default` = 0x110000

    var code: Int {
        return self.rawValue
    }
}
