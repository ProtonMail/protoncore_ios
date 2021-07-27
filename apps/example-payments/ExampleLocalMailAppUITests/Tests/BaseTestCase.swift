//
//  BaseTestCase.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import pmtest
import XCTest

class BaseTestCase: CoreTestCase {
    
    public var app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
