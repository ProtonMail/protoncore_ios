//
//  BaseTestCase.swift
//  SampleAppUITests
//
//  Created by Krzysztof Siejkowski on 08/06/2021.
//

import Foundation
import pmtest
import XCTest

class BaseTestCase: CoreTestCase {

    public var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }
}
