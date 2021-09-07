//
//  LogoutManager.swift
//  ProtonCore-Settings - Created on 30.10.2020.
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

/// A type that should able to perform logout actions.
///
/// Logout can either be successful or fail with an error.
public protocol LogoutManager {
    typealias LogoutAction = (Result<Void, Error>) -> Void

    /// Performs logout
    /// - Parameter completion: Result of the logout attempt
    func logout(completion: @escaping LogoutAction)
}
