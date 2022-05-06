//
//  AssertDecodingError.swift
//  ProtonCore-DataModel-Tests - Created on 26.04.22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest

func assertDecodingError(
    error: Error,
    codingKey: String,
    debugDescription: String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    if case .dataCorrupted(let context) = error as? DecodingError {
        XCTAssertEqual(context.codingPath.count, 1, file: file, line: line)
        XCTAssertEqual(context.codingPath.first?.stringValue, codingKey, file: file, line: line)
        XCTAssertEqual(context.codingPath.first?.intValue, nil, file: file, line: line)
        XCTAssertEqual(context.debugDescription, debugDescription, file: file, line: line)
    } else {
        XCTFail("Expected to have `.dataCorrupted` error, but got \(error) error instead.", file: file, line: line)
    }
}
