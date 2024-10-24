//
//  SRPTests.swift
//  ProtonCore-Login-Tests - Created on 29.01.2021.
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

// swiftlint:disable xctfail_message

import XCTest

import ProtonCoreObfuscatedConstants
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreLogin
import ProtonCoreCrypto
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif

class SRPTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    func testSrpServerClientVerify() {
        let bits = 2048
        let password: String = LoginTestUser.defaultUser.password
        let rawSalt = CryptoGo.SrpRandomBytes(PasswordSaltSize.login.IntBytes, nil)!

        do {
            let passwordSlic = password.data(using: .utf8)
            guard let verifierAuth = CryptoGo.SrpNewAuthForVerifier(passwordSlic, ObfuscatedConstants.modulus, rawSalt, nil) else {
                XCTFail()
                return
            }

            let verifier = try verifierAuth.generateVerifier(bits)
            let server = CryptoGo.SrpNewServerFromSigned(ObfuscatedConstants.modulus, verifier, bits, nil)!
            let challenge = try server.generateChallenge() // this is the serverEphemeral
            let auth = CryptoGo.SrpNewAuth(4, ObfuscatedConstants.srpAuthPassword, passwordSlic, rawSalt.base64EncodedString(), ObfuscatedConstants.modulus, challenge.base64EncodedString(), nil)!
            let proofs: SrpProofs = try auth.generateProofs(bits)

            let serverProof = try server.verifyProofs(proofs.clientEphemeral, clientProofBytes: proofs.clientProof)
            let isComplete = server.isCompleted()
            XCTAssertTrue(isComplete)
            let expectedServerProof = proofs.expectedServerProof
            XCTAssertEqual(serverProof, expectedServerProof)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

// swiftlint:enable xctfail_message
