//
//  AccountDeletionViewControllerPresenterMock.swift
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
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif

#if canImport(AppKit)
public struct AccountDeletionViewControllerPresenterMock: AccountDeletionViewControllerPresenter {
    
    public init() {}
    
    @FuncStub(AccountDeletionViewControllerPresenterMock.presentAsModalWindow) public var presentAsModalWindowStub
    public func presentAsModalWindow(_ vc: NSViewController) {
        presentAsModalWindowStub(vc)
    }
}

#elseif canImport(UIKit)

public struct AccountDeletionViewControllerPresenterMock: AccountDeletionViewControllerPresenter {
    
    public init() {}
    
    @FuncStub(AccountDeletionViewControllerPresenterMock.present) public var presentStub
    public func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentStub(vc, animated, completion)
    }
}

#endif
