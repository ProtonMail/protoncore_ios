//
//  ArrayBuilderTests.swift
//  ProtonCore-Utilities-Tests - Created on 13/01/2023.
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

@testable import ProtonCoreUtilities

class ArrayBuilderTests: XCTestCase {

    func testRemovingRemovesElement() {
        let original = [2, 3, 1, 5]

        let result = original.removing(3)

        XCTAssertEqual(result, [2, 1, 5], "The element should be removed from the resulting array.")
    }

    func testRemovingRemovesAllOccurences() {
        let original = [2, 3, 1, 5, 3]

        let result = original.removing(3)

        XCTAssertEqual(result, [2, 1, 5], "All occurrences of the element to remove should be removed.")
    }

    func testRemovingRemovesElements() {
        let original = [2, 3, 1, 5, 3, 1]

        let result = original.removing([3, 1])

        XCTAssertEqual(result, [2, 5], "All occurrences of the elements to remove should be removed.")
    }

    func testRemovingPreservesOriginalArray() {
        let original = [2, 3, 1]

        _ = original.removing(2)

        XCTAssertEqual(original, [2, 3, 1], "The original array should not be altered.")
    }

    // MARK: Conditional removing tests

    func testConditionalRemovingReturnsOriginalArrayWhenConditionFalse() {
        let original = [2, 3, 1]

        let result = original.removing(3, if: false)

        XCTAssertEqual(result, original, "The original array should be returned when the condition is false.")
    }

    func testConditionalRemovingReturnsAlteredArrayWhenConditionTrue() {
        let original = [2, 3, 1]

        let result = original.removing(3, if: true)

        XCTAssertEqual(result, [2, 1], "Elements should be removed if the condition is true.")
    }

    func testConditionalRemovingElementsReturnsOriginalArrayWhenConditionFalse() {
        let original = [2, 3, 1, 5]

        let result = original.removing([1, 3], if: false)

        XCTAssertEqual(result, original, "The original array should be returned when the condition is false.")
    }

    func testConditionalRemovingElementsReturnsAlteredArrayWhenConditionTrue() {
        let original = [2, 3, 1, 5]

        let result = original.removing([1, 3], if: true)

        XCTAssertEqual(result, [2, 5], "Elements should be removed if the condition is true.")
    }

    func testConditionalAppendingReturnsOriginalArrayWhenConditionFalse() {
        let original = [2, 1, 5]

        let result = original.appending([2, 9], if: false)

        XCTAssertEqual(result, [2, 1, 5], "Elements should be not be appended if the condition is false.")
    }

    func testConditionalAppendingReturnsAlteredArrayWhenConditionTrue() {
        let original = [2, 1, 5]

        let result = original.appending([2, 9], if: true)

        XCTAssertEqual(result, [2, 1, 5, 2, 9], "Elements should be appended if the condition is true.")
    }

    func testConditionalAppendingDoesNotExecuteClosureIfConditionFalse() {
        let closureEvaluatedExpectation = XCTestExpectation(description: "Closure should not be executed unnecessarily")
        closureEvaluatedExpectation.isInverted = true

        let original = [2, 1, 5]
        let closure: () -> [Int] = {
            closureEvaluatedExpectation.fulfill()
            return [2, 9]
        }

        let result = original.appending(closure, if: false)

        XCTAssertEqual(result, [2, 1, 5], "Elements should not be appended if the condition is false.")
    }

    func testConditionalAppendingAppendsResultOfClosureWhenConditionTrue() {
        let original = [2, 1, 5]
        let closure: () -> [Int] = {
            return [2, 9]
        }

        let result = original.appending(closure, if: true)

        XCTAssertEqual(result, [2, 1, 5, 2, 9], "Elements should be appended if the condition is true.")
    }

    func testConditionalAppendingElementReturnsOriginalArrayWhenConditionFalse() {
        let original = [2, 1, 5]

        let result = original.appending(9, if: false)

        XCTAssertEqual(result, [2, 1, 5], "Element should be not be appended if the condition is false.")
    }

    func testConditionalAppendingElementReturnsAlteredArrayWhenConditionTrue() {
        let original = [2, 1, 5]

        let result = original.appending(9, if: true)

        XCTAssertEqual(result, [2, 1, 5, 9], "Element should be appended if the condition is true.")
    }

    func testConditionalAppendingElementDoesNotExecuteClosureIfConditionFalse() {
        let closureEvaluatedExpectation = XCTestExpectation(description: "Closure should not be executed unnecessarily")
        closureEvaluatedExpectation.isInverted = true

        let original = [2, 1, 5]
        let closure: () -> Int = {
            closureEvaluatedExpectation.fulfill()
            return 9
        }

        let result = original.appending(closure, if: false)

        XCTAssertEqual(result, [2, 1, 5], "Element should not be appended if the condition is false.")
    }

    func testConditionalAppendingElementAppendsResultOfClosureWhenConditionTrue() {
        let original = [2, 1, 5]
        let closure: () -> Int = { 9 }

        let result = original.appending(closure, if: true)

        XCTAssertEqual(result, [2, 1, 5, 9], "Element should be appended if the condition is true.")
    }
}
