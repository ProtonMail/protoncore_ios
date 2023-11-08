//
//  AccountDeletionMock.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
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

import XCTest
import ProtonCoreAccountDeletion
import ProtonCoreNetworking
import ProtonCoreUIFoundations
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif

public struct AccountDeletionWebViewDelegateMock: AccountDeletionWebViewDelegate {

    public init() {}

    @FuncStub(AccountDeletionWebViewDelegateMock.shouldCloseWebView) public var shouldCloseWebViewStub
    public func shouldCloseWebView(_ viewController: AccountDeletionViewController, completion: @escaping () -> Void) {
        shouldCloseWebViewStub(viewController, completion)
    }
}

#if canImport(AppKit)

import AppKit

public final class AccountDeletionMock: AccountDeletion {

    @FuncStub(AccountDeletionMock.initiateAccountDeletionProcess) public var initiateAccountDeletionProcessStub
    public func initiateAccountDeletionProcess(
        over viewController: NSViewController,
        inAppTheme: @escaping () -> InAppTheme,
        performAfterShowingAccountDeletionScreen: @escaping () -> Void,
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        initiateAccountDeletionProcessStub(
            viewController, inAppTheme, performAfterShowingAccountDeletionScreen, performBeforeClosingAccountDeletionScreen, completion
        )
    }
}

#elseif canImport(UIKit)

import UIKit

public final class AccountDeletionMock: AccountDeletion {

    @FuncStub(AccountDeletionMock.initiateAccountDeletionProcess) public var initiateAccountDeletionProcessStub
    public func initiateAccountDeletionProcess(
        over viewController: UIViewController,
        inAppTheme: @escaping () -> InAppTheme,
        performAfterShowingAccountDeletionScreen: @escaping () -> Void,
        performBeforeClosingAccountDeletionScreen: @escaping (@escaping () -> Void) -> Void,
        completion: @escaping (Result<AccountDeletionSuccess, AccountDeletionError>) -> Void
    ) {
        initiateAccountDeletionProcessStub(
            viewController, inAppTheme, performAfterShowingAccountDeletionScreen, performBeforeClosingAccountDeletionScreen, completion
        )
    }
}

#endif
