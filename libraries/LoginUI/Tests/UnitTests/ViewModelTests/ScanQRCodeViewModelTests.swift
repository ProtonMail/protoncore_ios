//
//  Created on 28.03.2025.
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
import ProtonCoreLogin
@testable import ProtonCoreLoginUI
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreServices
import ProtonCoreCrypto

@MainActor
class ScanQRCodeViewModelTests: XCTestCase {
    var sut: ScanQRCodeView.ViewModel!
    var mockAPIService: APIServiceMock!

    let passphrase = "SomeTestPassphrase"

    override func setUp() async throws {
        mockAPIService = APIServiceMock()

        sut = ScanQRCodeView.ViewModel.init(dependencies: .init(passphrase: passphrase, apiService: mockAPIService))
    }

    func testHandleQRCode_GoodQRCode() async throws {
        let encryptionKeyData = Data(Array(repeating: UInt8.random(in: 0..<100), count: 32))
        let encryptionKey = Base64.encode(raw: encryptionKeyData)
        let qrCode = "userCode:\(encryptionKey):ios-mail"

        mockAPIService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(ForkSessionPushResponse(code: 1000, selector: "someSelector")))
        }

        await sut.processQRCode(qrCode)

        XCTAssertEqual(sut.state, .success)
    }

    func testHandleQRCode_BadQRCode() async throws {
        let qrCode = "SomeAbsoluteGarbageQRCode"
        
        await sut.processQRCode(qrCode)

        XCTAssertEqual(sut.state, .failure)
    }
}
