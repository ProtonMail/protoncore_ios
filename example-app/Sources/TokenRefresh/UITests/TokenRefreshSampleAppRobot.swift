//
//  TokenRefreshSampleAppRobot.swift
//  Example-TokenRefresh-UITests-V5 - Created on 20/05/2022.
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

import Foundation
import pmtest
import ProtonCore_TestingToolkit
import XCTest

let createAccountButton = "TokenRefreshViewController.createAccountButton"
let logInButton = "TokenRefreshViewController.logInButton"
let getUserButton = "TokenRefreshViewController.getUserButton"
let expireSessionButton = "TokenRefreshViewController.expireSessionButton"
let expireSessionAndRefreshTokenButton = "TokenRefreshViewController.expireSessionAndRefreshTokenButton"
let activityIndicatorView = "TokenRefreshViewController.activityIndicatorView"

final class TokenRefreshSampleAppRobot: CoreElements {
    
    public let verify = Verify()

    public final class Verify: CoreElements {
        
        @discardableResult
        public func createAccountMessageIsDisplayed() -> TokenRefreshSampleAppRobot {
            staticText(TokenRefreshStrings.createAccountSuccessfully).wait().checkExists()
            return .init()
        }
        
        @discardableResult
        public func loggedInMessageIsDisplayed() -> TokenRefreshSampleAppRobot {
            staticText(TokenRefreshStrings.loggedInSuccessfully).wait().checkExists()
            return .init()
        }
        
        @discardableResult
        public func expiredSessionMessageIsDisplayed() -> TokenRefreshSampleAppRobot {
            staticText(TokenRefreshStrings.expiredSessionSuccessfully).wait().checkExists()
            return .init()
        }
        
        @discardableResult
        public func getUserMessageIsDisplayed() -> TokenRefreshSampleAppRobot {
            staticText(TokenRefreshStrings.getUserSuccessfully).wait().checkExists()
            return .init()
        }
        
        @discardableResult
        public func refreshTokenSuccessfullyMessageIsDisplayed() -> TokenRefreshSampleAppRobot {
            staticText(TokenRefreshStrings.refreshAccessTokenSuccessfully).wait().checkExists()
            return .init()
        }
        
        @discardableResult
        public func refreshTokenFailedMessageIsDisplayed() -> TokenRefreshSampleAppRobot {
            staticText(TokenRefreshStrings.refreshAccessTokenFailed).wait().checkExists()
            return .init()
        }
    }

    func createAccount() -> TokenRefreshSampleAppRobot {
        button(createAccountButton).tap()
        return .init()
    }
    
    func logIn() -> TokenRefreshSampleAppRobot {
        button(logInButton).tap()
        return .init()
    }
    
    func getUser() -> TokenRefreshSampleAppRobot {
        button(getUserButton).tap()
        return .init()
    }
    
    func expireSession() -> TokenRefreshSampleAppRobot {
        button(expireSessionButton).tap()
        return .init()
    }
    
    func expireSessionAndRefreshToken() -> TokenRefreshSampleAppRobot {
        button(expireSessionAndRefreshTokenButton).tap()
        return .init()
    }
}
