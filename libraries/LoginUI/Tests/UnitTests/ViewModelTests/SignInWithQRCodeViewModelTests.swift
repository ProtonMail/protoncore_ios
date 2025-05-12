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

#if os(iOS)
import XCTest
import ProtonCoreLogin
@testable import ProtonCoreLoginUI
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreServices
import ProtonCoreNetworking

@MainActor
class SignInWithQRCodeViewModelTests: XCTestCase {
    var sut: SignInWithQRCodeView.ViewModel!
    var mockAPIService: APIServiceMock!
    var mockSecureHashGenerator: MockSecureHashGenerator!
    var mockClientIdProvider: MockClientIdProvider!
    var handleLoginCredentials: (Credential,
                                 _ loginErrorHandler: @escaping () -> Void,
                                 _ loginSuccessHandler: @escaping () -> Void) -> Void = { _, _, _ in return }

    override func setUp() async throws {
        mockAPIService = APIServiceMock()
        mockSecureHashGenerator = MockSecureHashGenerator()
        mockClientIdProvider = MockClientIdProvider()

        setUpSut(withEncryptionKeyInQRCode: true)
    }

    func setUpSut(withEncryptionKeyInQRCode: Bool) {
        sut = SignInWithQRCodeView.ViewModel(
            dependencies:
                .init(apiService: mockAPIService,
                      secureHashGenerator: mockSecureHashGenerator,
                      clientIdProvider: mockClientIdProvider,
                      handleBackToLoginButtonPress: {},
                      handleLoginCredentials: handleLoginCredentials),
            generateEncryptionKey: withEncryptionKeyInQRCode)
    }

    func testGenerateQRCodeText() async {

        let withEncryptionKeyInQRCodeAndEncryptionKey = [(true, "AQID"), (false, "")]

        for (flag, base64EncryptionKey) in withEncryptionKeyInQRCodeAndEncryptionKey {
            setUpSut(withEncryptionKeyInQRCode: flag)

            let selector = "selector"
            let userCode = "userCode"
            let clientId = "clientId"
            mockAPIService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(ForkSessionInitiateResponse(selector: selector, userCode: userCode)))
            }

            mockClientIdProvider.id = clientId
            mockSecureHashGenerator.data = Data([1,2,3])

            sut.refreshWaitTimeInSeconds = 0.01
            sut.pullForkIntervalInSeconds = 100

            sut.generateANewQRCodeText()

            // wait a little for the qrCode to reach the main thread
            try? await Task.sleep(nanoseconds: 50_000_000)

            XCTAssertEqual(sut.qrCodeText, "\(GenerateSignInQRCode.QRCodeVersion):\(userCode):\(base64EncryptionKey):\(clientId)")
        }
    }

    @MainActor
    func testRefreshOfQRCodeText() async {
        let selector = "selector"
        let userCode = "userCode"
        let clientId = "clientId"
        mockAPIService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(ForkSessionInitiateResponse(selector: selector, userCode: userCode)))
        }

        mockClientIdProvider.id = clientId
        mockSecureHashGenerator.data = Data([1,2,3])

        sut.refreshWaitTimeInSeconds = 0.5
        sut.pullForkIntervalInSeconds = 100

        sut.generateANewQRCodeText()

        // wait a little for the qrCode to reach the main thread
        try? await Task.sleep(nanoseconds: 50_000_000)

        let qrCode1 = sut.qrCodeText

        // Change the secure hash
        mockSecureHashGenerator.data = Data([1,2,3,4])

        // wait for refreshWaitTimeInSeconds to expire
        try? await Task.sleep(nanoseconds: UInt64(sut.refreshWaitTimeInSeconds * 1_000_000_000) + 50_000_000)

        let qrCode2 = sut.qrCodeText

        XCTAssertNotEqual(qrCode1, qrCode2)
    }

    func testPollingOfFork() async throws {
        enum Cases: Equatable {
            case success
            case encryptionKeyMissing
            case payloadMissing
            case passphraseEmptyString
            case passphraseMissing
            case apiError
        }

        let cases: [Cases] = [
            .success, .encryptionKeyMissing, .payloadMissing, .passphraseEmptyString, .passphraseMissing, .apiError
        ]

        // In vpn .encryptionKeyMissing, .payloadMissing, .passphraseEmptyString, .passphraseMissing should succeed
        // In any other product we should get an error and set the state to a fail view
        let clientIds = ["vpn", "somethingElse"]

        let testCases = cases.cartesianProduct(with: clientIds)

        for (testCase, clientId) in testCases {
            if testCase == .encryptionKeyMissing {
                setUpSut(withEncryptionKeyInQRCode: false)
            } else {
                setUpSut(withEncryptionKeyInQRCode: true)
            }

            let encryptionKey = Data(Array(repeating: UInt8.random(in: 0..<100), count: 32))
            let selector = "selector"
            let userCode = "userCode"
            let UID = "UID"
            let refreshToken = "RefreshToken"
            let accessToken = "AccessToken"
            var pullResult: ForkSessionPullResponse?

            var httpErrorCode = 422

            if testCase == .apiError {
                httpErrorCode = 500
            }

            mockAPIService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains(try! Regex("/auth/[^/]+/sessions/forks$")) {
                    completion(nil, .success(ForkSessionInitiateResponse(selector: selector, userCode: userCode)))
                    return
                } else if let result = pullResult {
                    completion(nil, .success(result))
                    return
                } else {
                    completion(nil, .failure(
                        ResponseError(httpCode: httpErrorCode, responseCode: 0, userFacingMessage: "Invalid Selector", underlyingError: nil) as NSError)
                    )
                    return
                }
            }

            mockClientIdProvider.id = clientId
            mockSecureHashGenerator.data = encryptionKey

            sut.refreshWaitTimeInSeconds = 100
            sut.pullForkIntervalInSeconds = 0.01

            sut.generateANewQRCodeText()

            // wait for a bit more then a second for the fork to be pulled
            try? await Task.sleep(nanoseconds: UInt64(sut.pullForkIntervalInSeconds * 1_000_000_000) + 50_000_000)

            // wait for one cycle and then set the pullResult, to make sure that we keep polling on failure to get the fork

            switch testCase {
            case .success:
                let payload = try SecurePassphrasePayload(passphrase: "TestPassphrase", encryptionKey: encryptionKey)
                pullResult = ForkSessionPullResponse(code: 1000, payload: payload.encryptedPayload, UID: UID, refreshToken: refreshToken, accessToken: accessToken, expiresIn: 1000, tokenType: "Bearer", scope: "", scopes: [], userID: "")
            case .encryptionKeyMissing, .payloadMissing:
                pullResult = ForkSessionPullResponse(code: 1000, payload: nil, UID: UID, refreshToken: refreshToken, accessToken: accessToken, expiresIn: 1000, tokenType: "Bearer", scope: "", scopes: [], userID: "")
            case .passphraseEmptyString:
                let payload = try SecurePassphrasePayload(passphrase: "", encryptionKey: encryptionKey)
                pullResult = ForkSessionPullResponse(code: 1000, payload: payload.encryptedPayload, UID: UID, refreshToken: refreshToken, accessToken: accessToken, expiresIn: 1000, tokenType: "Bearer", scope: "", scopes: [], userID: "")
            case .passphraseMissing:
                let payload = try SecurePassphrasePayload(passphrase: nil, encryptionKey: encryptionKey)
                pullResult = ForkSessionPullResponse(code: 1000, payload: payload.encryptedPayload, UID: UID, refreshToken: refreshToken, accessToken: accessToken, expiresIn: 1000, tokenType: "Bearer", scope: "", scopes: [], userID: "")
            case .apiError:
                pullResult = nil
            }

            try? await Task.sleep(nanoseconds: UInt64(sut.pullForkIntervalInSeconds * 1_000_000_000) + 50_000_000)

            // Check result

            switch testCase {
            case .success:
                XCTAssertEqual(pullResult?.UID, sut.forkedSession?.UID)
                XCTAssertEqual(pullResult?.payload, sut.forkedSession?.payload)
                XCTAssertEqual(pullResult?.accessToken, sut.forkedSession?.accessToken)
                XCTAssertEqual(pullResult?.refreshToken, sut.forkedSession?.refreshToken)

                XCTAssertEqual(sut.state, .qrCode)
            case .encryptionKeyMissing, .passphraseEmptyString, .passphraseMissing, .payloadMissing:
                if !clientId.contains("vpn") {
                    XCTAssertEqual(sut.state, .requirePasswordFail)
                } else {
                    // On VPN if the passphrase, payload or encryption key are missing we are fine. We can log in
                    XCTAssertEqual(pullResult?.UID, sut.forkedSession?.UID)
                    XCTAssertEqual(pullResult?.accessToken, sut.forkedSession?.accessToken)
                    XCTAssertEqual(pullResult?.refreshToken, sut.forkedSession?.refreshToken)
                    XCTAssertEqual(sut.state, .qrCode)
                }
            case .apiError:
                XCTAssertEqual(sut.state, .genericFail)
            }

            // make sure that after we get the pullResult, we stop polling
            let payload = try SecurePassphrasePayload(passphrase: "DifferentPassphrase", encryptionKey: encryptionKey)
            pullResult = ForkSessionPullResponse(code: 1000, payload: payload.encryptedPayload, UID: UID, refreshToken: refreshToken, accessToken: accessToken, expiresIn: 1000, tokenType: "Bearer", scope: "", scopes: [], userID: "")

            try? await Task.sleep(nanoseconds: UInt64(sut.pullForkIntervalInSeconds * 1_000_000_000) + 100_000_000)

            // Make sure we did not replace the forkedSession with the new pulledResult.
            XCTAssertNotEqual(pullResult?.payload, sut.forkedSession?.payload)
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

extension Array {
    func cartesianProduct<OtherElement>(with otherArray: [OtherElement]) -> [(Element, OtherElement)] {
        guard !self.isEmpty, !otherArray.isEmpty else {
            return []
        }
        return self.flatMap { element -> [(Element, OtherElement)] in
            otherArray.map { otherElement -> (Element, OtherElement) in
                return (element, otherElement)
            }
        }
    }
}
#endif
