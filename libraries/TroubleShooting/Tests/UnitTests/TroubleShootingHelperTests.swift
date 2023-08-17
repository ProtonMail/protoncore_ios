//
//  TroubleShootingHelperTests.swift
//  ProtonCore-TroubleShooting - Created on 08/20/2020
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
//

#if os(iOS)

import UIKit

import XCTest
@testable import ProtonCoreTroubleShooting
import ProtonCoreDoh
#if SPM
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif

class TroubleShootingHelperTests: XCTestCase {
    private var dohMock: DohMock!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dohMock = DohMock()
    }

    override func tearDownWithError() throws {
        dohMock = nil

        try super.tearDownWithError()
    }
    
    func testStatusHelper() {
        let exceptionCheck = self.expectation(description: "Success completion block called")
        
        let helper = DohStatusHelper(doh: dohMock as DoHInterface)
        dohMock.statusStub.fixture = .on
        XCTAssertTrue(helper.status == .on)
        
        helper.onChanged = { newStatus in
            XCTAssertTrue(newStatus == .off)
            exceptionCheck.fulfill()
        }
        helper.status = .off
        XCTAssertTrue(dohMock.statusStub.setWasCalled)
        wait(for: [exceptionCheck], timeout: 1.0)
    }

    func testPresentedViewController() throws {
        let viewController = UIViewControllerMock()
        viewController.presentStub.bodyIs { _, _, _, completion in
            completion?()
        }

        var onPresentWasCalled = false

        viewController.present(
            doh: dohMock as DoHInterface,
            modalPresentationStyle: .fullScreen,
            onPresent: {
                onPresentWasCalled = true
            }
        )

        let presentedController = try XCTUnwrap(viewController.presentStub.lastArguments).a1
        XCTAssertEqual(presentedController.modalPresentationStyle, .fullScreen)

        XCTAssert(onPresentWasCalled)
    }
}

private class UIViewControllerMock: UIViewController {
    @FuncStub(UIViewControllerMock.present) public var presentStub
    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentStub(viewControllerToPresent, flag, completion)
    }
}

#endif
