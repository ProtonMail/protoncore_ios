//
//  TokenRefreshTests.swift
//  Example-TokenRefresh-UITests - Created on 20/05/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
#else
import ProtonCoreTestingToolkit
#endif

final class TokenRefreshTests: TokenRefreshBaseTestCase {

    func testLogInGetUserSuccess() throws {
        let robot = appRobot.createAccount()
        robot
            .logIn()
            .verify.loggedInMessageIsDisplayed()
            .getUser()
            .verify.getUserMessageIsDisplayed()
    }

    func testLogInExpireSessionGetUserRefreshTokenSuccess() {
        let robot = appRobot.createAccount()
        robot
            .logIn()
            .verify.loggedInMessageIsDisplayed()
            .expireSession()
            .verify.expiredSessionMessageIsDisplayed()
            .getUser()
            .verify.getUserMessageIsDisplayed()
    }

    func testLogInExpireSessionAndRefreshTokenGetUserRefreshTokenFailure() {
        let robot = appRobot.createAccount()
        robot
            .logIn()
            .verify.loggedInMessageIsDisplayed()
            .expireSessionAndRefreshToken()
            .verify.expiredSessionMessageIsDisplayed()
            .getUser()
            .verify.failedToGetUserMessageIsDisplayed()
    }
}
