//
//  CryptoDataExtTest.swift
//  ProtonCore-KeyManager-Tests - Created on 4/19/21.
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

class TestCaseBase: XCTestCase {
    private var testBundle: Bundle!
    func content(of name: String) -> String {
        let url = testBundle.url(forResource: name, withExtension: "txt")!
        let content = try! String.init(contentsOf: url)
        return content.trimmingCharacters(in: .newlines)
    }
    
    override func setUp() {
        super.setUp()
        self.testBundle = Bundle(for: type(of: self))
    }
    
}
