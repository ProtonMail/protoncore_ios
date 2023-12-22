//
//  ActiveAccountRecoveryViewTests.swift
//  ProtonCore-AccountRecovery-Unit-Tests - Created on 31/7/23.
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
#if os(iOS)
import XCTest
@testable import ProtonCoreAccountRecovery
import ViewInspector
import SwiftUI

final class ActiveAccountRecoveryViewTests: XCTestCase {

    @MainActor func testInitialState() throws {
        // Given
        let viewModel = AccountRecoveryView.ViewModel()
        viewModel.state = .grace
        viewModel.email = "janedoe@proton.me"
        viewModel.remainingTime = 72 * 3600
        viewModel.isLoaded = true

        // When
        let sut = ActiveAccountRecoveryView(viewModel: viewModel)

        // Then
        let foundImages = try sut.inspect().findAll(ViewType.Image.self).map { try! $0.actualImage() }
        _ = try sut.inspect().find(textWhere: {string, _ -> Bool in
            string.contains("janedoe@proton.me")
        })
        _ = try sut.inspect().find(textWhere: {string, _ -> Bool in
            string.contains("72 hours")
        })
        let foundButton = try sut.inspect().find(ViewType.Button.self)
        _ = try foundButton.find(text: ARTranslation.graceViewCancelButtonCTA.l10n)

        XCTAssertThrowsError(try sut.inspect().find(ViewType.ProgressView.self))
        XCTAssertEqual(["ic-exclamation-circle", "password-reset-lock-clock"], foundImages.map { try! $0.name() })
        XCTAssert(type(of: try foundButton.buttonStyle()) == SolidButton.self)
    }

}
#endif
