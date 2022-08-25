//
//  TroubleShootingViewModelTests.swift
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

import XCTest
@testable import ProtonCore_TroubleShooting
import ProtonCore_Doh
import ProtonCore_CoreTranslation

class DohStatusStub: DohStatusProtocol {
    var status: DoHStatus = .on
}

class TroubleShootingViewModelTests: XCTestCase {
    var dohStub: DohStatusStub!
    var sut: TroubleShootingViewModel!

    override func setUp() {
        super.setUp()
        dohStub = DohStatusStub()
        sut = TroubleShootingViewModel(doh: dohStub)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        dohStub = nil
    }

    func testGetDohStatus() {
        dohStub.status = .off
        XCTAssertEqual(sut.dohStatus, .off)

        dohStub.status = .on
        XCTAssertEqual(sut.dohStatus, .on)
    }

    func testSetDohStatus() {
        sut.dohStatus = .on
        XCTAssertEqual(dohStub.status, .on)

        sut.dohStatus = .off
        XCTAssertEqual(dohStub.status, .off)
    }

    func testGetItems() {
        XCTAssertEqual(sut.items.count, 8)
        XCTAssertEqual(sut.items, [
            .allowSwitch,
            .noInternetNotes,
            .ispNotes,
            .blockNotes,
            .antivirusNotes,
            .firewallNotes,
            .downtimeNotes,
            .otherNotes
        ])
    }

    func testGetTitle() {
        XCTAssertEqual(sut.title, CoreString._troubleshooting_title)
    }
}
