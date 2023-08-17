//
//  InitialPasswordViewModel.swift
//  ProtonCore-Settings - Created on 02.10.2020.
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

#if os(iOS)

import XCTest
@testable import ProtonCoreSettings

final class InitialPasswordViewModelTests: XCTestCase {
    func test_userInputDidChangeForwardsUserSelectedInitialPasswordToPasswordSelector() {
        let (sut, passwordSelector, _) = makeSUT()

        XCTAssertEqual(passwordSelector.messages, [])

        sut.userInputDidChange(to: "1")
        XCTAssertEqual(passwordSelector.messages, [.initital("1")])

        sut.userInputDidChange(to: "12")
        XCTAssertEqual(passwordSelector.messages, [.initital("1"), .initital("12")])

        sut.userInputDidChange(to: "1")
        XCTAssertEqual(passwordSelector.messages, [.initital("1"), .initital("12"), .initital("1")])
    }

    func test_userInputDidChangeChangesTopRightButtonState() {
        let (sut, passwordSelector, _) = makeSUT()

        // Stub passwordSelector to always fail inserting initial password
        passwordSelector.stubInitialPasswordSettingSuccessTo(false)

        // Register right button  enable/disable state evolution
        var rightButton = [Bool]()
        sut.rightNavigationButtonEnabled = {
            rightButton.append($0)
        }

        XCTAssertEqual(rightButton, [])

        sut.userInputDidChange(to: "12")
        XCTAssertEqual(rightButton, [false])

        sut.userInputDidChange(to: "123")
        XCTAssertEqual(rightButton, [false, false])

        passwordSelector.stubInitialPasswordSettingSuccessTo(true)

        sut.userInputDidChange(to: "1234")
        XCTAssertEqual(rightButton, [false, false, true])
    }

    func test_withdrawFromScreen_registersWithDrawAction() {
        let (sut, _, router) = makeSUT()

        sut.withdrawFromScreen()

        XCTAssertEqual(router.messages, [.withdraw])
    }

    func test_nextScren_registersAdvanceAction() {
        let (sut, _, router) = makeSUT()

        sut.advance()

        XCTAssertEqual(router.messages, [.advance])
    }

    func test_viewWillDissapearAfterAdvance_registersDoesNotFinish() {
        let (sut, _, router) = makeSUT()

        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false)], "View is removed without prior setting password finish with failure")

        sut.advance()
        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false), .advance], "After advance, do not finish successfully on initial password setting")
    }

    func test_viewWillDissapearAfterWidthrawFinishesFailing() {
        let (sut, _, router) = makeSUT()

        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false)], "View is removed without prior setting password finish with failure")

        sut.withdrawFromScreen()
        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false), .withdraw, .finish(success: false)], "After advance, do not finish successfully on initial password setting")
    }

    // MARK: - Helpers
    private func makeSUT() -> (sut: InitialPasswordConfigurationViewModel, passwordSelector: PasswordSelectorSpy, router: PasswordRouterSpy) {
        let router = PasswordRouterSpy()
        let passwordSelector = PasswordSelectorSpy()
        let sut = InitialPasswordConfigurationViewModel(passwordSelector: passwordSelector, router: router)
        return (sut, passwordSelector, router)
    }
}

final class PasswordSelectorSpy: PasswordSelector {
    // MARK: - Spy for Password setting process
    enum Messages: Equatable, CustomStringConvertible {
        case initital(String)
        case confirmation(String)

        var description: String {
            switch self {
            case .initital(let password): return ".initial(\(password))"
            case .confirmation(let password): return ".confirmation(\(password))"
            }
        }
    }

    private(set) var messages: [Messages] = []
    private let stubPasswordSettingStub = NSError(domain: "some error", code: 0)
    private var succededInsertingInitialPassword = true
    private var succededInsertingConfirmationPassword = true

    func stubInitialPasswordSettingSuccessTo(_ isSuccess: Bool) {
        succededInsertingInitialPassword = isSuccess
    }

    func stubConfirmationPasswordSettingSuccessTo(_ isSuccess: Bool) {
        succededInsertingConfirmationPassword = isSuccess
    }

    func setInitialPassword(to password: String) throws {
        messages.append(.initital(password))

        guard succededInsertingInitialPassword else {
            throw stubPasswordSettingStub
        }
    }

    func setConfirmationPassword(to password: String) throws {
        messages.append(.confirmation(password))

        guard succededInsertingConfirmationPassword else {
            throw stubPasswordSettingStub
        }
    }

    // MARK: - Stub for Password validation
    private var passwordValidationStub: Result<String, Error>!

    func stubPasswordValidation(with result: Result<String, Error>) {
        passwordValidationStub = result
    }

    func getPassword() -> Result<String, Error> {
        passwordValidationStub
    }
}

final class PasswordRouterSpy: SecurityPasswordRouter {
    var messages: [Messages] = []

    func advance() {
        messages.append(.advance)
    }

    func withdraw() {
        messages.append(.withdraw)
    }

    func finishWithSuccess(_ success: Bool) {
        messages.append(.finish(success: success))
    }

    enum Messages: Equatable, CustomStringConvertible {
        case advance
        case withdraw
        case finish(success: Bool)

        var description: String {
            switch self {
            case .advance: return ".advance"
            case .withdraw: return ".withdraw"
            case let .finish(success: success): return ".finish(\(success))"
            }
        }
    }
}

#endif
