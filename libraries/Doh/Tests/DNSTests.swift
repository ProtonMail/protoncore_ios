//
//  DohTests.swift
//  ProtonCore-Doh-Tests - Created on 4/19/21.
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
//

import XCTest
@testable import ProtonCore_Doh

class DNSTests: XCTestCase {
    
    func testDnsStruct() {
        let url = "test_url"
        let ttl = 60
        let dns = DNS.init(url: url, ttl: ttl)
        XCTAssertEqual(dns.url, url)
        XCTAssertEqual(dns.ttl, ttl)
    }
    
    func testDnsType() {
        let type1 = DNSType(rawValue: 10)
        XCTAssertNil(type1)
        let type2 = DNSType(rawValue: 16)
        XCTAssertNotNil(type2)
        XCTAssertEqual(type2, DNSType.txt)
    }
    
    func testType() {
        let type1 = DNSType(rawValue: 10)
        XCTAssertNil(type1)
        let type2 = DNSType(rawValue: 16)        
        XCTAssertNotNil(type2)
        XCTAssertEqual(type2, DNSType.txt)
    }
}
