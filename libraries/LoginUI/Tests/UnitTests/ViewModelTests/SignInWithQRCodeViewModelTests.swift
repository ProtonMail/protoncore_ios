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
import ProtonCoreLogin
@testable import ProtonCoreLoginUI
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreServices

@MainActor
class SignInWithQRCodeViewModelTests: XCTestCase {
    var sut: SignInWithQRCodeView.ViewModel!
    var mockAPIService: APIServiceMock!
    var mockSecureHashGenerator: MockSecureHashGenerator!
    var mockClientIdProvider: MockClientIdProvider!

    override func setUp() async throws {
        mockAPIService = APIServiceMock()
        mockSecureHashGenerator = MockSecureHashGenerator()
        mockClientIdProvider = MockClientIdProvider()

        sut = SignInWithQRCodeView.ViewModel(dependencies:
                .init(apiService: mockAPIService,
                      secureHashGenerator: mockSecureHashGenerator,
                      clientIdProvider: mockClientIdProvider))
    }

    func testGenerateQRCodeText() async {
        let selector = "selector"
        let userCode = "userCode"
        let clientId = "clientId"
        mockAPIService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(ForkSessionInitiateResponse(selector: selector, userCode: userCode)))
        }

        mockClientIdProvider.id = clientId
        mockSecureHashGenerator.data = Data([1,2,3])

        sut.generateANewQRCodeText()

        // wait a little for the qrCode to reach the main thread
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.qrCodeText, "\(userCode):AQID:\(clientId)")
    }

    func testRefreshOfQRCodeText() async {
        let selector = "selector"
        let userCode = "userCode"
        let clientId = "clientId"
        mockAPIService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(ForkSessionInitiateResponse(selector: selector, userCode: userCode)))
        }

        mockClientIdProvider.id = clientId
        mockSecureHashGenerator.data = Data([1,2,3])

        sut.refreshWaitTimeInSeconds = 1

        sut.generateANewQRCodeText()

        // wait a little for the qrCode to reach the main thread
        try? await Task.sleep(nanoseconds: 100_000_000)

        let qrCode1 = sut.qrCodeText

        // Change the secure hash
        mockSecureHashGenerator.data = Data([1,2,3,4])

        // wait for refreshWaitTimeInSeconds to expire
        try? await Task.sleep(nanoseconds: UInt64(sut.refreshWaitTimeInSeconds * 1_000_000_000))

        let qrCode2 = sut.qrCodeText

        XCTAssertNotEqual(qrCode1, qrCode2)
    }

    func testPollingOfFork() async {
        let selector = "selector"
        let userCode = "userCode"
        let clientId = "clientId"
        let UID = "UID"
        let payload = "TestPayload"
        let refreshToken = "RefreshToken"
        let accessToken = "AccessToken"
        var pullResult: ForkSessionPullResponse?

        mockAPIService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains(try! Regex("/auth/[^/]+/sessions/forks$")) {
                completion(nil, .success(ForkSessionInitiateResponse(selector: selector, userCode: userCode)))
                return
            } else if let result = pullResult {
                completion(nil, .success(result))
                return
            } else {
                completion(nil, .failure(NSError(domain: "", code: 404)))
                return
            }
        }

        mockClientIdProvider.id = clientId
        mockSecureHashGenerator.data = Data([1,2,3])

        sut.refreshWaitTimeInSeconds = 100
        sut.pullForkIntervalInSeconds = 1

        sut.generateANewQRCodeText()

        // wait for a bit more then a second for the fork to be pulled
        try? await Task.sleep(nanoseconds: UInt64(sut.pullForkIntervalInSeconds * 1_000_000_000) + 100_000_000)

        // wait for one cycle and then set the pullResult, to make sure that we keep polling on failure to get the fork
        pullResult = ForkSessionPullResponse(code: 1000, payload: payload, UID: UID, refreshToken: refreshToken, accessToken: accessToken)

        try? await Task.sleep(nanoseconds: UInt64(sut.pullForkIntervalInSeconds * 1_000_000_000) + 100_000_000)

        XCTAssertEqual(pullResult?.UID, sut.forkedSession?.UID)
        XCTAssertEqual(pullResult?.payload, sut.forkedSession?.payload)
        XCTAssertEqual(pullResult?.accessToken, sut.forkedSession?.accessToken)
        XCTAssertEqual(pullResult?.refreshToken, sut.forkedSession?.refreshToken)

        // make sure that after we get the pullResult, we stop polling
        pullResult = ForkSessionPullResponse(code: 1000, payload: "DifferentPayload", UID: UID, refreshToken: refreshToken, accessToken: accessToken)

        try? await Task.sleep(nanoseconds: UInt64(sut.pullForkIntervalInSeconds * 1_000_000_000) + 100_000_000)

        // Make sure we did not replace the forkedSession with the new pulledResult.
        XCTAssertNotEqual(pullResult?.payload, sut.forkedSession?.payload)
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
