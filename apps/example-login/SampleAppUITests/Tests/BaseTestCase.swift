//
//  BaseTesCase.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import pmtest
import XCTest

class BaseTestCase: CoreTestCase {
    
    let testData = TestData()
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
