//
//  ConfirmationPasswordViewModelTests.swift
//  ProtonCore-Settings - Created on 23.11.2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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
@testable import ProtonCore_Settings

final class ConfirmationPasswordViewModelTests: XCTestCase {
    func test_userInputDidChangeForwardsUserSelectedConfirmationPasswordToPasswordSelector() {
        let (sut, passwordSelector, _, _) = makeSUT()

        XCTAssertEqual(passwordSelector.messages, [])

        sut.userInputDidChange(to: "1")
        XCTAssertEqual(passwordSelector.messages, [.confirmation("1")])

        sut.userInputDidChange(to: "12")
        XCTAssertEqual(passwordSelector.messages, [.confirmation("1"), .confirmation("12")])

        sut.userInputDidChange(to: "1")
        XCTAssertEqual(passwordSelector.messages, [.confirmation("1"), .confirmation("12"), .confirmation("1")])
    }

    func test_userInputDidChangeChangesTopRightButtonState() {
        let (sut, passwordSelector, _, _) = makeSUT()

        // Stub passwordSelector to always fail inserting initial password
        passwordSelector.stubConfirmationPasswordSettingSuccessTo(false)

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

        passwordSelector.stubConfirmationPasswordSettingSuccessTo(true)

        sut.userInputDidChange(to: "1234")
        XCTAssertEqual(rightButton, [false, false, true])
    }

    func test_withdrawFromScreen_registersWithDrawAction() {
        let (sut, _, router, _) = makeSUT()

        sut.withdrawFromScreen()

        XCTAssertEqual(router.messages, [.withdraw])
    }

    func test_advance_RegistersAdvancesOnValidPasswordAndPinEnableSuccess() {
        let (sut, passwordSelector, router, pinEnabler) = makeSUT()
        passwordSelector.stubPasswordValidation(with: .success("1234"))
        pinEnabler.stubCompleteWithSuccess(true)
        var errors: [String] = []
        sut.onErrorReceived = { errors.append($0) }

        sut.advance()

        XCTAssertEqual(router.messages, [.advance])
        XCTAssertEqual(errors.count, 0)
    }

    func test_advance_doesNotRegistersAdvancesOnInValidPasswordAndPinEnableSuccess() {
        let (sut, passwordSelector, router, pinEnabler) = makeSUT()
        passwordSelector.stubPasswordValidation(with: .success("1234"))
        pinEnabler.stubCompleteWithSuccess(false)
        var errors: [String] = []
        sut.onErrorReceived = { errors.append($0) }

        sut.advance()

        XCTAssertEqual(router.messages, [])
        XCTAssertEqual(errors.count, 1)
    }

    func test_advance_doesNotRegistersAdvancesOnInValidPasswordAndPinEnableFailure() {
        let (sut, passwordSelector, router, pinEnabler) = makeSUT()
        passwordSelector.stubPasswordValidation(with: .failure(anyError()))
        pinEnabler.stubCompleteWithSuccess(false)
        var errors: [String] = []
        sut.onErrorReceived = { errors.append($0) }

        sut.advance()

        XCTAssertEqual(router.messages, [])
        XCTAssertEqual(errors.count, 1)
    }

    func test_advance_doesNotRegistersAdvancesOnValidPasswordAndPinEnableFailure() {
        let (sut, passwordSelector, router, pinEnabler) = makeSUT()
        passwordSelector.stubPasswordValidation(with: .failure(anyError()))
        pinEnabler.stubCompleteWithSuccess(true)
        var errors: [String] = []
        sut.onErrorReceived = { errors.append($0) }

        sut.advance()

        XCTAssertEqual(router.messages, [])
        XCTAssertEqual(errors.count, 1)
    }

    func test_viewWillDissapearOnlyFinishesSuccessfullyAfterSuccessfulAdvanceCall() {
        let (sut, passwordSelector, router, pinEnabler) = makeSUT()
        passwordSelector.stubPasswordValidation(with: .success("1234"))
        pinEnabler.stubCompleteWithSuccess(true)

        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false)])

        sut.advance()
        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false), .advance, .finish(success: true)])
    }

    func test_viewWillDissapearAfterWidthrawFinishesFailing() {
        let (sut, _, router, _) = makeSUT()

        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false)], "View is removed without prior setting password finish with failure")

        sut.withdrawFromScreen()
        sut.viewWillDissapear()

        XCTAssertEqual(router.messages, [.finish(success: false), .withdraw, .finish(success: false)], "After advance, do not finish successfully on initial password setting")
    }

    // MARK: - Helpers
    private func makeSUT() -> (sut: ConfirmationPasswordConfigurationViewModel, passwordSelector: PasswordSelectorSpy, router: PasswordRouterSpy, enabler: PinLockActivatorStub) {
        let router = PasswordRouterSpy()
        let pinEnabler = PinLockActivatorStub()
        let passwordSelector = PasswordSelectorSpy()
        let sut = ConfirmationPasswordConfigurationViewModel(passwordSelector: passwordSelector, router: router, enabler: pinEnabler)
        return (sut, passwordSelector, router, pinEnabler)
    }

    private func anyError() -> Error {
        NSError(domain: "Any error", code: 1, userInfo: nil)
    }
}

private final class PinLockActivatorStub: PinLockActivator {
    private var stubbedEnablingSuccess = true

    func stubCompleteWithSuccess(_ success: Bool) {
        stubbedEnablingSuccess = success
    }

    func activatePin(pin: String, completion: @escaping (Bool) -> Void) {
        completion(stubbedEnablingSuccess)
    }
}
