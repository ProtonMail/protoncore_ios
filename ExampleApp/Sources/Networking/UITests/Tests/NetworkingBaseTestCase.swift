//
//  NetworkingBaseTestCase.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import fusion
import XCTest
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
#else
import ProtonCoreTestingToolkit
#endif

class NetworkingBaseTestCase: ProtonCoreBaseTestCase {
    
    let entryRobot = CoreExampleMainRobot()
    var appRobot: NetworkingSampleAppRobot!

    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-Networking-UITests")
        super.setUp()
        appRobot = entryRobot.tap(.networking, to: NetworkingSampleAppRobot.self)
    }
}
