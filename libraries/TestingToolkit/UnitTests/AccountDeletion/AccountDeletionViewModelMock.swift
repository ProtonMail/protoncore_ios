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
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import WebKit

public final class AccountDeletionViewModelMock: AccountDeletionViewModelInterface {

    public init() {}

    @PropertyStub(\AccountDeletionViewModelMock.getURLRequest, initialGet: .crash) public var getURLRequestStub
    public var getURLRequest: URLRequest { getURLRequestStub() }

    @FuncStub(AccountDeletionViewModelMock.setup) public var setupStub
    public func setup(webViewConfiguration: WKWebViewConfiguration) { setupStub(webViewConfiguration) }

    @FuncStub(AccountDeletionViewModelMock.shouldRetryFailedLoading) public var shouldRetryFailedLoadingStub
    public func shouldRetryFailedLoading(host: String, error: Error, shouldReloadWebView: @escaping (AccountDeletionRetryCheckResult) -> Void) {
        shouldRetryFailedLoadingStub(host, error, shouldReloadWebView)
    }

    @FuncStub(AccountDeletionViewModelMock.interpretMessage) public var interpretMessageStub
    public func interpretMessage(_ message: WKScriptMessage,
                                 loadedPresentation: @escaping () -> Void,
                                 notificationPresentation: @escaping (NotificationType, String) -> Void,
                                 successPresentation: @escaping () -> Void,
                                 closeWebView: @escaping (@escaping () -> Void) -> Void) {
        interpretMessageStub(message, loadedPresentation, notificationPresentation, successPresentation, closeWebView)
    }

    @FuncStub(AccountDeletionViewModelMock.deleteAccountWasClosed) public var deleteAccountWasClosedStub
    public func deleteAccountWasClosed() { deleteAccountWasClosedStub() }

    @FuncStub(AccountDeletionViewModelMock.deleteAccountDidErrorOut) public var deleteAccountDidErrorOutStub
    public func deleteAccountDidErrorOut(message: String) { deleteAccountDidErrorOutStub(message) }

    @FuncStub(AccountDeletionViewModelMock.deleteAccountFailedBecauseApiMightBeBlocked) public var deleteAccountFailedBecauseApiMightBeBlockedStub
    public func deleteAccountFailedBecauseApiMightBeBlocked(message: String, originalError: Error) {
        deleteAccountFailedBecauseApiMightBeBlockedStub(message, originalError)
    }
}
