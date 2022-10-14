//
//  LoginUISnapshotTests.swift
//  ProtonCore-LoginUI-V5-Unit-TestsUsingCrypto - Created on 13/10/22.
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
import ProtonCore_TestingToolkit
import ProtonCore_Challenge
@testable import ProtonCore_LoginUI

@available(iOS 13, *)
class LoginUISnapshotTests: SnapshotTestCase {

    func testSignInScreen() {
        let controller = UIStoryboard.instantiate(storyboardName: "PMLogin",
                                                  controllerType: LoginViewController.self)



        let viewModel = LoginViewModel(login: LoginMock(), challenge: PMChallenge())

        controller.viewModel = viewModel

        checkSnapshots(controller: controller)



    }

}
