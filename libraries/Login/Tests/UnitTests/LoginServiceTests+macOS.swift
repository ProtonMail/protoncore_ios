//
//  LoginServiceTests+macOS.swift
//  ProtonCore-Login-Tests - Created on 09/01/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

#if os(macOS)

import XCTest

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsAuthenticationKeyGeneration
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#endif
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreObfuscatedConstants
import ProtonCoreFeatureSwitch
@testable import ProtonCoreServices
@testable import ProtonCoreLogin
@testable import ProtonCoreObservability

class LoginServiceMacOSTests: XCTestCase {
    var authInfoRequestData: [String: Any]?
    var server: SrpServer?
    var sut: LoginService!
    var api: APIServiceMock!
    var observabilityServiceMock: ObservabilityServiceMock!
    var featureFlagsRepositoryMock: FeatureFlagsRepositoryMock!

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    private func setupSUT() {
        featureFlagsRepositoryMock = FeatureFlagsRepositoryMock()
        api = APIServiceMock()
        api.authDelegateStub.fixture = AuthDelegateMock()
        let dohInterface = DohInterfaceMock()
        dohInterface.getCurrentlyUsedHostUrlStub.bodyIs { _ in
            "http://proton.black/api"
        }
        dohInterface.getAccountHostStub.bodyIs { _ in
            "http://account.proton.black"
        }
        api.sessionUIDStub.fixture = "sessionUID"
        api.dohInterfaceStub.fixture = dohInterface
        sut = LoginService(api: api,
                           clientApp: .vpn,
                           minimumAccountType: .external,
                           featureFlagsRepository: featureFlagsRepositoryMock,
                           ssoCallbackScheme: "protonvpn")
    }

    func test_getSSORequest_authCredentialsFound() async {
        // Given
        setupSUT()
        api.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: .init(Credential(UID: "", accessToken: "accessToken", refreshToken: "", userName: "", userID: "", scopes: .empty))))
        }

        // When
        let ssoResult = await sut.getSSORequest(challenge: .init(ssoChallengeToken: "ssoChallengeToken"))

        // Then
        XCTAssertNil(ssoResult.error)
        XCTAssertEqual(ssoResult.request?.url, URL(string: "http://proton.black/api/auth/sso/ssoChallengeToken?FinalRedirectBaseUrl=protonvpn://account.proton.black"))
        XCTAssertEqual(ssoResult.request?.headers.dictionary, ["x-pm-uid": "sessionUID", "Authorization": "accessToken"])
    }
}

#endif
