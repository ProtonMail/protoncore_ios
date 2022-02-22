//
//  PMUIFoundationsTests.swift
//  ProtonCore-UIFoundations - Created on 25.05.20.
//
//  Copyright (c) 2020 Proton Technologies AG
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

@testable import ProtonCore_UIFoundations

class PMUIFoundationsTests: XCTestCase {

    func testColorManager() {
        XCTAssertNotNil(ColorProvider.TextNorm as UIColor)
    }
    
    let colorComparisonAccuracy: CGFloat = 0.01
    
    func testConversionFromHSBAToHSLA_NonZeroBrightness() {
        let hsla = hsbaToHSLA(hsba: HSBA(hue: 240.0 / 360.0, saturation: 0.5, brightness: 1.0, alpha: 1.0))
        XCTAssertEqual(hsla, HSLA(hue: 240.0 / 360.0, saturation: 1.0, lightness: 0.75, alpha: 1.0))
    }
    
    func testConversionFromHSBAToHSLA_ZeroBrightness() {
        let hsla = hsbaToHSLA(hsba: HSBA(hue: 240.0 / 360.0, saturation: 0.5, brightness: 0.0, alpha: 1.0))
        XCTAssertEqual(hsla, HSLA(hue: 240.0 / 360.0, saturation: 0.0, lightness: 0.0, alpha: 1.0))
    }
    
    func testConversionFromHSLAToHSBA_NonZeroLightnessAndSaturation() {
        let hsba = hslaToHSBA(hsla: HSLA(hue: 240.0 / 360.0, saturation: 0.73, lightness: 0.63, alpha: 1.0))
        XCTAssertEqual(hsba.hue, 240.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.saturation, 0.6, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.brightness, 0.9, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }
    
    func testConversionFromHSLAToHSBA_ZeroLightnessAndSaturation() {
        let hsba = hslaToHSBA(hsla: HSLA(hue: 240.0 / 360.0, saturation: 0.0, lightness: 0.0, alpha: 1.0))
        XCTAssertEqual(hsba, HSBA(hue: 240.0 / 360.0, saturation: 0.0, brightness: 0.0, alpha: 1.0))
    }
    
    func testStrongVariantComputationHSLA() {
        let hsla = computeStrongVariant(from: HSLA(hue: 339.0 / 360.0, saturation: 0.82, lightness: 0.58, alpha: 1.0))
        XCTAssertEqual(hsla.hue, 333.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsla.saturation, 0.72, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsla.lightness, 0.48, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsla.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }
    
    func testIntenseVariantComputationHSLA() {
        let hsla = computeIntenseVariant(from: HSLA(hue: 302.0 / 360.0, saturation: 0.63, lightness: 0.62, alpha: 1.0))
        XCTAssertEqual(hsla.hue, 294.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsla.saturation, 0.53, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsla.lightness, 0.45, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsla.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }
    
    func testStrongVariantComputationHSBA() {
        let hsba = computeStrongVariant(from: HSBA(hue: 230.0 / 360.0, saturation: 0.73, brightness: 0.94, alpha: 1.0))
        XCTAssertEqual(hsba.hue, 224.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.saturation, 0.86, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.brightness, 0.88, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }
    
    func testIntenseVariantComputationHSBA() {
        let hsba = computeIntenseVariant(from: HSBA(hue: 230.0 / 360.0, saturation: 0.73, brightness: 0.94, alpha: 1.0))
        XCTAssertEqual(hsba.hue, 222.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.saturation, 0.86, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.brightness, 0.75, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(hsba.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }
    
    func testStrongVariantUIColor() {
        let originalColor = UIColor(hue: 119.0 / 360.0, saturation: 0.69, brightness: 0.73, alpha: 1.0)
        let strongColor = originalColor.computedStrongVariant
        XCTAssertEqual(strongColor.hsba.hue, 113.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(strongColor.hsba.saturation, 0.60, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(strongColor.hsba.brightness, 0.54, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(strongColor.hsba.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }
    
    func testIntenseVariantUIColor() {
        let originalColor = UIColor(hue: 54.0 / 360.0, saturation: 0.92, brightness: 0.71, alpha: 1.0)
        let strongColor = originalColor.computedIntenseVariant
        XCTAssertEqual(strongColor.hsba.hue, 46.0 / 360.0, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(strongColor.hsba.saturation, 0.86, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(strongColor.hsba.brightness, 0.37, accuracy: colorComparisonAccuracy)
        XCTAssertEqual(strongColor.hsba.alpha, 1.0, accuracy: colorComparisonAccuracy)
    }

}
