//
//  Created on 13.03.2025.
//
//  Copyright (c) 2025 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
@testable import ProtonCoreLogin

final class GenerateSignInQRCodeTests: XCTestCase {

    var sut: GenerateSignInQRCode!
    var mockHashGenerator: MockSecureHashGenerator!
    var mockClientIdProvider: MockClientIdProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockHashGenerator = MockSecureHashGenerator()
        mockClientIdProvider = MockClientIdProvider()
        sut = GenerateSignInQRCode(
            hashGenerator: mockHashGenerator,
            clientIdProvider: mockClientIdProvider)
    }

    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
    }

    func testGenerateQRTextSuccess() throws {
        let flagAndBase64EncryptionKey = [(true,"AQID"), (false, "")]

        for (flag, base64EncryptionKey) in flagAndBase64EncryptionKey {
            let userCode = "someUserCode"
            let clientId = "ios-vpn"
            mockHashGenerator.data = Data([1,2,3])
            mockClientIdProvider.id = clientId

            let qrCode = try sut.invoke(userCode: userCode, withEncryptionKey: flag)

            XCTAssertEqual(qrCode.text, "\(GenerateSignInQRCode.QRCodeVersion):\(userCode):\(base64EncryptionKey):\(clientId)")
        }
    }

    func testGenerateQRTextFailure() {
        enum MockError: Error {
            case some
        }

        enum Result {
            case throwError
            case doNothing
        }

        let flagsAndResult = [(true, Result.throwError), (false, Result.doNothing)]

        for (flag, result) in flagsAndResult {
            let userCode = "someUserCode"
            let clientId = "ios-vpn"
            mockHashGenerator.error = MockError.some
            mockClientIdProvider.id = clientId

            do {
                let _ = try sut.invoke(userCode: userCode, withEncryptionKey: flag)
                switch result {
                case .throwError:
                    XCTFail("call to invoke should throw an error.")
                case .doNothing:
                    break
                }
            } catch {
                switch result {
                case .throwError:
                    XCTAssertEqual((error as! MockError), .some)
                case .doNothing:
                    XCTFail("call to invoke should NOT throw an error.")
                }
            }
        }
    }
}

class MockSecureHashGenerator: SecureHashGenerator {
    var data: Data!
    var error: (any Error)?

    func random(bits: Int32) throws -> Data {
        if let err = error {
            throw err
        }
        return data
    }
}

class MockClientIdProvider: ClientIdProvider {
    var id: String!

    func clientId() -> String {
        id
    }
}
