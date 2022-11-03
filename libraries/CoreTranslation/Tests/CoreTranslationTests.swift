//
//  CoreTranslationTests.swift
//  ProtonCore-CoreTranslation - Created on 07.11.20.
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
@testable import ProtonCore_CoreTranslation

final class CoreTranslationTests: XCTestCase {
    
    func testAllSubstitutionsAreFollowingTheExpectedFormat() {
        let localizedStringInstance = LocalizedString()
        let elementWithIllegalSubstitution = LocalizedStringAccessors.allCases
            .map { (elem: $0, value: $0.localizedString(from: localizedStringInstance)) }
            .filter { $0.value.contains("%") }
            .map {
                (
                    elem: $0,
                    value: $0.value
                        .replacingOccurrences(of: "%@", with: "") // like $@
                        .replacingOccurrences(of: "%\\d\\$@", with: "", options: .regularExpression) // like %1$@
                        .replacingOccurrences(of: "%#@[A-Z]+\\d*@", with: "", options: .regularExpression) // like %#@VARIABLE@
                )
            }
            .first { $0.value.contains("%") }
        if let elementWithIllegalSubstitution {
            XCTFail("Found localized string with an illegal substitution format. \(elementWithIllegalSubstitution.elem): \(elementWithIllegalSubstitution.value)")
        }
    }
    
}
