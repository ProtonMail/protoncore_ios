//
//  ChooseUsernameUISnapshotTests.swift
//  ProtonCore-LoginUI-V5-Unit-TestsUsingCrypto - Created on 17/11/22.
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
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_Utilities
import ProtonCore_Networking
import ProtonCore_DataModel
@testable import ProtonCore_LoginUI

@available(iOS 13, *)
class ChooseUsernameUISnapshotTests: SnapshotTestCase {

    func testChooseUsernameScreen() {
        let controller = UIStoryboard.instantiate(storyboardName: "PMLogin",
                                                  controllerType: ChooseUsernameViewController.self)
        let loginMock = LoginMock()
        loginMock.currentlyChosenSignUpDomainStub.fixture = "snapshot.test"
        let data = CreateAddressData.init(email: "",
                                          credential: AuthCredential.dummy,
                                          user: User.dummy,
                                          mailboxPassword: "")
        let viewModel = ChooseUsernameViewModel.init(data: data, login: loginMock, appName: "")
        controller.viewModel = viewModel
        checkSnapshots(controller: controller, perceptualPrecision: 0.98)
    }
}
