//
//  TokenRefreshBaseTestCase.swift
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

import Foundation
import pmtest
import XCTest
import ProtonCore_Log
import ProtonCore_TestingToolkit

class TokenRefreshBaseTestCase: ProtonCoreBaseTestCase {
    
    let entryRobot = CoreExampleMainRobot()
    var appRobot: TokenRefreshSampleAppRobot!

    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-TokenRefresh-UITests")
        super.setUp()
        appRobot = entryRobot.tap(.tokenRefresh, to: TokenRefreshSampleAppRobot.self)
    }
}

