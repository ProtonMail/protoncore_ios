//
//  ErrorsTests.swift
//  ProtonCore-Crypto-Tests - Created on 07/15/22.
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
import ProtonCoreCryptoGoInterface
@testable import ProtonCoreCrypto

class ErrorsTests: CryptoTestBase {

    private func throwingSessionErrors(index: Int) throws {
        switch index {
        case 0:
            throw SessionError.unSupportedAlgorithm
        case 1:
            throw SessionError.emptyKey
        default:
            return
        }
    }

    private func throwingArmoredErrors(index: Int) throws {
        switch index {
        case 0:
            throw ArmoredError.noKeyPacket
        case 1:
            throw ArmoredError.noDataPacket
        default:
            return
        }
    }

    private func throwingSignatureVerifyErrors(code: Int, message: String) throws {
        throw SignatureVerifyError(code: code, message: message)
    }

    func testSignatureVerifyError() {
        let testCode = 1
        let testMsg = "test"
        XCTAssertThrowsError(try throwingSignatureVerifyErrors(code: testCode, message: testMsg)) { error in
            XCTAssertTrue(error is SignatureVerifyError)
            let errorCheck = error as! SignatureVerifyError
            XCTAssertEqual(errorCheck.code, testCode)
            XCTAssertEqual(errorCheck.message, testMsg)
        }
    }

    func testArmoredError() {
        XCTAssertThrowsError(try throwingArmoredErrors(index: 0)) { error in
            XCTAssertEqual(error.localizedDescription, ArmoredError.noKeyPacket.localizedDescription)
        }
        XCTAssertThrowsError(try throwingArmoredErrors(index: 1)) { error in
            XCTAssertEqual(error.localizedDescription, ArmoredError.noDataPacket.localizedDescription)
        }
    }

    func testSessionError() {
        XCTAssertThrowsError(try throwingSessionErrors(index: 0)) { error in
            XCTAssertEqual(error.localizedDescription, SessionError.unSupportedAlgorithm.localizedDescription)
        }
        XCTAssertThrowsError(try throwingSessionErrors(index: 1)) { error in
            XCTAssertEqual(error.localizedDescription, SessionError.emptyKey.localizedDescription)
        }
    }
}
