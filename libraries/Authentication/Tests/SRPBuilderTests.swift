//
//  SRPBuilderTests.swift
//  ProtonCore-Authentication-Tests - Created on 10.05.23.
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
@testable import ProtonCoreAuthentication
import ProtonCoreCryptoGoInterface
import ProtonCoreServices

final class SRPBuilderTests: XCTestCase {
    var sut: SRPBuilder!
    var srpAuth: SrpAuthMock!

    override func setUp() {
        super.setUp()
        srpAuth = SrpAuthMock()
        sut = SRPBuilder()
    }

    func test_buildSRP() throws {
        // Given
        let clientProof = Data(count: 1)
        let clientEphemeral = Data(count: 2)
        let expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)

        var srpProofs: SrpProofsMock {
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = clientProof
            srpProofs.clientEphemeral = clientEphemeral
            srpProofs.expectedServerProof = expectedServerProof
            return srpProofs
        }

        srpAuth.generateProofsStub.bodyIs { _, _  in
            return srpProofs
        }

        let authInfo = AuthInfoResponse(
            modulus: "modulus",
            serverEphemeral: "serverEphemeral",
            version: 1,
            salt: "0cNmaaFTYxDdFA==",
            srpSession: "b7953c6a26d97a8f7a673afb79e6e9ce"
        )

        // When
        let srpBuildResult = try sut.buildSRP(username: "username", password: "oiejf0294nriu", authInfo: authInfo, srpAuth: srpAuth)

        // Then
        switch srpBuildResult {
        case .failure:
            XCTFail("expected success")
        case .success(let srpClientInfo):
            XCTAssertEqual(srpClientInfo.clientProof, clientProof)
            XCTAssertEqual(srpClientInfo.clientEphemeral, clientEphemeral)
            XCTAssertEqual(srpClientInfo.expectedServerProof, expectedServerProof)
        }
    }
}
