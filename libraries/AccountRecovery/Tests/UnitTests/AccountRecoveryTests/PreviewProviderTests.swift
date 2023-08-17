//
//  PreviewProviderTests.swift
//  ProtonCore-AccountDeletion-iOS-Unit-Tests - Created on 1/8/23.
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

// Previews are not production code, yet they live in the production
// library target. Hence these tests which do not verify production
// code, but avoid code coverage numbers to drop due to Previews
// Even so, some methods do not count as executed

final class PreviewProviderTests: XCTestCase {

    func testPreviewsForAccountRecoveryView() {
        XCTAssertNotNil(AccountRecoveryView_Previews.previews)
    }

    func testPreviewsForActiveAccountRecoveryView() {
        XCTAssertNotNil(ActiveAccountRecoveryView_Previews.previews)
    }

    func testPreviewsForCancelledAccountRecoveryView() {
        XCTAssertNotNil(CancelledAccountRecoveryView_Previews.previews)
    }

    func testPreviewsForInactiveAccountRecoveryView() {
        XCTAssertNotNil(InactiveRecoveryView_Previews.previews)
    }

    func testPreviewsForExpiredAccountRecoveryView() {
        XCTAssertNotNil(ExpiredAccountRecoveryView_Previews.previews)
    }

    func testPreviewsForInsecureAccountRecoveryView() {
        XCTAssertNotNil(InsecureAccountRecoveryView_Previews.previews)
    }
    
}
