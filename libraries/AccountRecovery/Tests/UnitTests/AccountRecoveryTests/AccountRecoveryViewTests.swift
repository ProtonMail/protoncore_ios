//
//  AccountRecoveryViewTests.swift
//  ProtonCore-AccountRecovery-Unit-Tests - Created on 16/7/23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
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
@testable import ProtonCoreAccountRecovery
@testable import ProtonCoreDataModel
import ViewInspector

final class AccountRecoveryViewTests: XCTestCase {

    @MainActor func testInitialState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(ActiveAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InsecureAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(CancelledAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ExpiredAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InactiveRecoveryView.self))
        _ = try sut.inspect().find(SkeletonView.self)
    }

    @MainActor func testDefaultStateIsInactiveState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        viewModel.populateWithAccountRecoveryInfo(("janedoe", "janedoe@protonmail.com", nil))

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(ActiveAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InsecureAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(CancelledAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ExpiredAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(SkeletonView.self))
        _ = try sut.inspect().find(InactiveRecoveryView.self)

    }

    @MainActor func testInactiveState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        let recoveryInfo = ("janedoe", "janedoe@protonmail.com",
                            User.AccountRecovery(state: .none,
                                                 reason: nil,
                                                 startTime: .zero,
                                                 endTime: .zero,
                                                 UID: "5cigpml2LD_iUk_3DkV29oojTt3eA=="))
        viewModel.populateWithAccountRecoveryInfo(recoveryInfo)

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(ActiveAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InsecureAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(CancelledAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ExpiredAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(SkeletonView.self))
        _ = try sut.inspect().find(InactiveRecoveryView.self)

    }

    @MainActor func testGracePeriodState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        let currentTimeInterval = Date().timeIntervalSince1970
        let recoveryInfo = ("janedoe", "janedoe@protonmail.com",
                            User.AccountRecovery(state: .grace,
                                                 reason: nil,
                                                 startTime: currentTimeInterval - 3600 * 2,
                                                 endTime: currentTimeInterval + 3600 * 70,
                                                 UID: "5cigpml2LD_iUk_3DkV29oojTt3eA=="))
        viewModel.populateWithAccountRecoveryInfo(recoveryInfo)

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(InactiveRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InsecureAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(CancelledAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ExpiredAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(SkeletonView.self))
        let view = try sut.inspect().find(ActiveAccountRecoveryView.self)

        _ = try view.find(textWhere: { string, _ -> Bool in
            string.contains("janedoe@protonmail.com")
        })
        _ = try view.find(textWhere: { string, _ -> Bool in
            string.contains("69 hours")
        })
        _ = try view.find(button: ARTranslation.graceViewCancelButtonCTA.l10n)
    }

    @MainActor func testUnsecuredState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        let currentTimeInterval = Date().timeIntervalSince1970
        let recoveryInfo = ("janedoe", "janedoe@protonmail.com",
                            User.AccountRecovery(state: .insecure,
                                                 reason: nil,
                                                 startTime: currentTimeInterval - 3600 * 2,
                                                 endTime: currentTimeInterval + 3600 * 142,
                                                 UID: "5cigpml2LD_iUk_3DkV29oojTt3eA=="))
        viewModel.populateWithAccountRecoveryInfo(recoveryInfo)

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(InactiveRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ActiveAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(CancelledAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ExpiredAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(SkeletonView.self))
        let view = try sut.inspect().find(InsecureAccountRecoveryView.self)

        _ = try view.find(textWhere: { string, _ -> Bool in
            string.contains("janedoe@protonmail.com")
        })
        _ = try view.find(textWhere: { string, _ -> Bool in
            string.contains("5 days")
        })
    }

    @MainActor func testCancelledState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        let recoveryInfo = ("janedoe", "janedoe@protonmail.com",
                            User.AccountRecovery(state: .cancelled,
                                                 reason: nil,
                                                 startTime: .zero,
                                                 endTime: .zero,
                                                 UID: "5cigpml2LD_iUk_3DkV29oojTt3eA=="))
        viewModel.populateWithAccountRecoveryInfo(recoveryInfo)

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(ActiveAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InsecureAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InactiveRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(ExpiredAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(SkeletonView.self))
        _ = try sut.inspect().find(CancelledAccountRecoveryView.self)

    }

    @MainActor func testExpiredState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        let recoveryInfo = ("janedoe", "janedoe@protonmail.com",
                            User.AccountRecovery(state: .expired,
                                                 reason: nil,
                                                 startTime: .zero,
                                                 endTime: .zero,
                                                 UID: "5cigpml2LD_iUk_3DkV29oojTt3eA=="))
        viewModel.populateWithAccountRecoveryInfo(recoveryInfo)

        // When
        let sut = AccountRecoveryView(viewModel: viewModel)

        // Then
        XCTAssertThrowsError( try sut.inspect().find(ActiveAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InsecureAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(CancelledAccountRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(InactiveRecoveryView.self))
        XCTAssertThrowsError( try sut.inspect().find(SkeletonView.self))
        _ = try sut.inspect().find(ExpiredAccountRecoveryView.self)

    }

}
