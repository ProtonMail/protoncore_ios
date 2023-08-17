//
//  CryptoTestBase.swift
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
import ProtonCoreCrypto
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

class CryptoTestBase: XCTestCase {
    
    var testBundle: Bundle!
    func content(of name: String) -> String {
        let url = testBundle.url(forResource: name, withExtension: "txt")!
        let content = try! String.init(contentsOf: url)
        return content
    }
    
    func url(of name: String) -> URL {
        let url = testBundle.url(forResource: name, withExtension: "txt")!
        return url
    }
    
    override func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
        #if SPM
        self.testBundle = Bundle.module
        #else
        self.testBundle = Bundle(for: type(of: self))
        #endif
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        #if SPM
        self.testBundle = Bundle.module
        #else
        self.testBundle = Bundle(for: type(of: self))
        #endif
    }
    
    func random(length: Int) -> Data {
        var error: NSError?
        guard let check = CryptoGo.CryptoRandomToken(length, &error) else {
            XCTFail("random token is nil")
            return Data()
        }
        return check
    }
}
