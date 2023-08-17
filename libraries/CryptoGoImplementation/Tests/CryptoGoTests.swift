//
//  CryptoGo.swift
//  ProtonCore-CryptoGoImplementation - Created on 24/05/2023.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
import GoLibs
import ProtonCoreCryptoGoInterface
@testable import ProtonCoreCryptoPatchedGoImplementation

class CryptoDataExtTest: XCTestCase {
    
    func testCryptoGoClassesToGoLibsClassesConversion() {
        XCTAssertNotNil(CryptoKey().toGoLibsType)
        XCTAssertNotNil(CryptoSessionKey().toGoLibsType)
        XCTAssertNotNil(CryptoKeyRing().toGoLibsType)
        XCTAssertNotNil(CryptoPGPMessage().toGoLibsType)
        XCTAssertNotNil(CryptoPGPSplitMessage().toGoLibsType)
        XCTAssertNotNil(CryptoPlainMessage().toGoLibsType)
        XCTAssertNotNil(CryptoClearTextMessage().toGoLibsType)
        XCTAssertNotNil(HelperGo2IOSReader().toGoLibsType)
        XCTAssertNotNil(HelperMobileReadResult().toGoLibsType)
        XCTAssertNotNil(HelperMobile2GoReader().toGoLibsType)
        XCTAssertNotNil(HelperMobile2GoWriter().toGoLibsType)
        XCTAssertNotNil(HelperMobile2GoWriterWithSHA256().toGoLibsType)
        XCTAssertNotNil(CryptoPGPSignature().toGoLibsType)
        XCTAssertNotNil(CryptoAttachmentProcessor().toGoLibsType)
        XCTAssertNotNil(HelperExplicitVerifyMessage().toGoLibsType)
        XCTAssertNotNil(CryptoSignatureVerificationError().toGoLibsType)
        XCTAssertNotNil(CryptoSigningContext().toGoLibsType)
        XCTAssertNotNil(CryptoVerificationContext().toGoLibsType)
        XCTAssertNotNil(CryptoEncryptSplitResult().toGoLibsType)
        XCTAssertNotNil(CryptoPlainMessageMetadata().toGoLibsType)
        XCTAssertNotNil(CryptoPlainMessageReader().toGoLibsType)
    }
    
    func testGoLibsProtocolsToCryptoGoProtocolsConversion() {
        XCTAssertNotNil(CryptoWriteCloser().toCryptoGoType)
        XCTAssertNotNil(CryptoWriteCloser().toCryptoGoType.toGoLibsType)
    }
    
}
