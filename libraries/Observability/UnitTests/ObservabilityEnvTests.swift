//
//  ObservabilityEnvTests.swift
//  ProtonCore-Observability-iOS-Unit-UnitTests - Created on 10.02.23.
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

@testable import ProtonCoreObservability
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import XCTest

final class ObservabilityEnvTests: XCTestCase {
    private var sut: ObservabilityEnv!
    private let apiServiceMock = APIServiceMock()
    
    override func setUp() {
        super.setUp()
        sut = ObservabilityEnv.current
    }
    
    func test_setupWorld_setsAPIService() {
        // Given
        XCTAssertNil(sut.observabilityService)

        // When
        sut.setupWorld(requestPerformer: apiServiceMock)

        // Then
        XCTAssertNotNil(sut.observabilityService)
    }
}
