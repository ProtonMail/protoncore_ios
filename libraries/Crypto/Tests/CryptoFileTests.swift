//
//  CryptoFileTests.swift
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
#if canImport(ProtonCore_Crypto_VPN)
@testable import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
@testable import ProtonCore_Crypto
#endif
import ProtonCore_Utilities

class CryptoFileTests: CryptoTestBase {
    
    func testWriteAndRead() {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileToWrite = url.appendingPathComponent("write.dat")
            
            if FileManager.default.fileExists(atPath: fileToWrite.path) {
                try FileManager.default.removeItem(at: fileToWrite)
            }
            FileManager.default.createFile(atPath: fileToWrite.path, contents: Data(), attributes: nil)
            let writeFileHandle = try FileHandle(forWritingTo: fileToWrite)
            guard let size = try FileManager.default.attributesOfItem(atPath: fileToWrite.path)[.size] as? Int else {
                throw CryptoError.streamCleartextFileHasNoSize
            }
            XCTAssertTrue(size == 0)
            let fileMobileWriter = File.FileMobileWriter(file: writeFileHandle)
            let testdata = "this is test data to write!".utf8!
            try fileMobileWriter.write(testdata, n: nil)
            defer { writeFileHandle.closeFile() }
            let readFileHandle = try FileHandle(forReadingFrom: fileToWrite)
            defer { readFileHandle.closeFile() }
            let fileMobileReader = File.FileMobileReader(file: readFileHandle)
            let readData = try fileMobileReader.read(1000).data
            XCTAssertEqual(testdata, readData)
        } catch {
            XCTFail("Should not happen: \(error)")
        }
        
    }
}
