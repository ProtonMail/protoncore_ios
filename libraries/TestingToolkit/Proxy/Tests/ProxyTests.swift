//
//  ProxyTests.swift
//  ProtonCore-Performance - Created on 13.06.2024.
//
// Copyright (c) 2023. Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import XCTest

final class ProxyTest: XCTestCase {

    var client: ProxyClient!
    private let defaultTimeout: TimeInterval = 25.0

    private var dynamicDomain: String? {
        if let domain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"], !domain.isEmpty {
            return domain
        } else {
            return nil
        }
    }

    override func setUp() {
        super.setUp()
        let domain = dynamicDomain ?? "proton.black"
        client = ProxyClient(baseURL: URL(string: "https://account.mock.\(domain)")!)
    }

    override func tearDown() {
        client = nil
        super.tearDown()
    }

    func testListScenarios() {
        let expectation = self.expectation(description: "Fetch scenarios")

        client.fetchDynamicMockRoutes { result in
            switch result {
            case .success(let scenarios):
                XCTAssertNotNil(scenarios.first?.name, "Scenario name should not be nil.")
                XCTAssertFalse(scenarios.isEmpty, "The scenarios list should not be empty.")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)
    }

    func testDisableProxyRequestForward() {
        let expectation = self.expectation(description: "Fetch proxy forward")

        client.fetchMockForwardingStatus { result in
            switch result {
            case .success(let forward):
                XCTAssertNotNil(forward.enabled, "The forward should be enabled.")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)

        let disableForwardExpectation = self.expectation(description: "Disable forward")

        client.setMockForwardingStatus(requestForward: RequestForward(enabled: false), completion: { result in
            switch result {
            case .success(let forward):
                XCTAssertFalse(forward.enabled, "The forward should be disabled.")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            disableForwardExpectation.fulfill()
        })

        wait(for: [disableForwardExpectation], timeout: defaultTimeout)
    }

    func testEnableDynamicMockSrp() {
        let expectation = self.expectation(description: "Fetch scenarios")
        let parameters: [String: Any] = [
            "password": "test1234"
        ]
        let dynamicMock = DynamicMockBody(name: "loginWithSrp", enabled: true, parameters: AnyCodable(value: parameters))

        client.addDynamicMockScenario(dynamicMock: dynamicMock) { result in
            switch result {
            case .success(let dynamicMock):
                debugPrint(dynamicMock)
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func testEnableDynamicMockRecordAll() {
        let expectation = self.expectation(description: "Fetch scenarios")
        let parameters: [String: Any] = [
            "mockDirectory": "1234"
        ]
        let dynamicMock = DynamicMockBody(name: "loginWithSrp", enabled: true, parameters: AnyCodable(value: parameters))

        client.addDynamicMockScenario(dynamicMock: dynamicMock) { result in
            switch result {
            case .success(let dynamicMock):
                debugPrint(dynamicMock)
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func testRegisterAStaticMock() {
        var expectation = self.expectation(description: "Register a static mock")

        let requestDetails = RequestDetails(exactUrl: ["test/testRegisterAStaticMock"], method: "GET")
        let responseDetails = ResponseDetails(statusCode: 200, body: AnyCodable(value: "{\"test\": \"asas\"}"), headers: AnyCodable(value: ContentType.json.asHeader))
        let routeRequest = MockObject(name: "TestScenario", enabled: true, updateFile: false, isRawFileContent: false, request: requestDetails, response: responseDetails)

        client.addStaticMockRoute(route: routeRequest) { result in
            switch result {
            case .success(let staticRoute):
                XCTAssertEqual(staticRoute.name, routeRequest.name, "The scenario name should match the test scenario.")
            case .failure(let error):
                XCTFail("Failed to register static mock: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)

        expectation = self.expectation(description: "Fetch scenarios")

        client.fetchStaticMockRoutes { result in
            switch result {
            case .success(let staticRoute):
                XCTAssertFalse(staticRoute.isEmpty, "The staticRoute list should not be empty.")
                XCTAssertNotNil(staticRoute.count, "staticRoute name should not be nil.")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)

        expectation = self.expectation(description: "Reset scenarios")

        client.disableStaticMocks(staticMock: routeRequest) { result in
            switch result {
            case .success(let staticRoute):
                XCTAssertEqual(staticRoute.enabled, false, "The scenario name should match the test scenario.")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)
    }

    func testSetAndGetGlobalBandwidth() {
        let setBandwidthExpectation = expectation(description: "Set bandwidth settings")
        let getBandwidthExpectation = expectation(description: "Get bandwidth settings")
        let resetBandwidthExpectation = expectation(description: "Reset bandwidth settings")

        let bandwidthInfo = BandwidthInfo(enabled: true, limit: BandwidthLimit.edge.speedBytesPerSec)

        client.addGlobalBandwidth(bandwidthInfo: bandwidthInfo) { result in
            switch result {
            case .success(let updatedBandwidth):
                XCTAssertEqual(updatedBandwidth.limit, BandwidthLimit.edge.speedBytesPerSec, "Bandwidth limit should be EDGE.")
            case .failure(let error):
                XCTFail("Failed to set bandwidth settings: \(error)")
            }
            setBandwidthExpectation.fulfill()
        }

        wait(for: [setBandwidthExpectation], timeout: defaultTimeout)

        client.fetchGlobalBandwidth { result in
            switch result {
            case .success(let bandwidth):
                XCTAssertEqual(bandwidth.limit, BandwidthLimit.edge.speedBytesPerSec, "Bandwidth limit should be EDGE.")
            case .failure(let error):
                XCTFail("Failed to fetch bandwidth settings: \(error)")
            }
            getBandwidthExpectation.fulfill()
        }

        wait(for: [getBandwidthExpectation], timeout: defaultTimeout)

        client.resetBandwidth { result in
            switch result {
            case .success(let bandwidth):
                XCTAssertEqual(bandwidth.limit, BandwidthLimit.none.speedBytesPerSec, "Bandwidth limit should be 1000.")
            case .failure(let error):
                XCTFail("Failed to fetch bandwidth settings: \(error)")
            }
            resetBandwidthExpectation.fulfill()
        }

        wait(for: [resetBandwidthExpectation], timeout: defaultTimeout)
    }

    func testSetAndGetGlobalLatency() {
        let setLatencyExpectation = expectation(description: "Set latency settings")
        let getLatencyExpectation = expectation(description: "Get latency settings")
        let resetLatencyExpectation = expectation(description: "Reset latency settings")

        let latencyInfo = LatencyInfo(enabled: true, latency: LatencyLevel.high.latencyMs)

        client.addGlobalLatency(latencyInfo: latencyInfo) { result in
            switch result {
            case .success(let updatedLatency):
                XCTAssertEqual(updatedLatency.latency, LatencyLevel.high.latencyMs, "Latency should be HIGH.")
            case .failure(let error):
                XCTFail("Failed to set latency settings: \(error)")
            }
            setLatencyExpectation.fulfill()
        }

        wait(for: [setLatencyExpectation], timeout: defaultTimeout)

        client.fetchGlobalLatency { result in
            switch result {
            case .success(let latency):
                XCTAssertEqual(latency.latency, LatencyLevel.high.latencyMs, "Latency should be HIGH.")
            case .failure(let error):
                XCTFail("Failed to fetch latency settings: \(error)")
            }
            getLatencyExpectation.fulfill()
        }

        wait(for: [getLatencyExpectation], timeout: defaultTimeout)

        client.resetLatency { result in
            switch result {
            case .success(let latency):
                XCTAssertEqual(latency.latency, LatencyLevel.none.latencyMs, "Latency should be 0.")
            case .failure(let error):
                XCTFail("Failed to reset latency settings: \(error)")
            }
            resetLatencyExpectation.fulfill()
        }

        wait(for: [resetLatencyExpectation], timeout: defaultTimeout)
    }

    func testResetAllMocksAndSettings() {
        let expectation = self.expectation(description: "Disable all mocks")

        client.resetAllMocksAndSettings { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, "All mocks disabled successfully, bandwith, latency and forwarding controls are disabled.")
            case .failure(let error):
                XCTFail("Failed to disable all mocks: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)
    }

    func testFetchStaticMocks() {
        let expectation = self.expectation(description: "Fetch all static mocks")

        client.fetchStaticMockRoutes { result in
            switch result {
            case .success(let mocks):

                for mock in mocks {
                    debugPrint(mock.request.exactUrl!)
                }

            case .failure(let error):
                XCTFail("Fetch all static mocks: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)
    }

    func testBulkRouteActions() {
        let bulkRouteExpectation = expectation(description: "Set bulk routes")

        let routes = TestDataFactory.createMultipleRoutes()

        client.updateStaticMockRoutes(routes: routes) { result in
            switch result {
            case .success(let routeDataArray):
                XCTAssertEqual(routeDataArray.count, routes.count, "Expected the same number of routes to be set.")
                XCTAssertEqual(routeDataArray[0].name, "Route1", "Expected the first route to be named 'Route1'.")
                XCTAssertEqual(routeDataArray[1].response.statusCode, 201, "Expected status code 201 for the second route.")
            case .failure(let error):
                XCTFail("Failed to set bulk routes: \(error)")
            }
            bulkRouteExpectation.fulfill()
        }

        wait(for: [bulkRouteExpectation], timeout: defaultTimeout)
    }

    func testBulkRouteActionsWithFileInput() {
        let bulkRouteExpectation = expectation(description: "Set bulk routes from file")

        let bundle = Bundle(for: Self.self)

        do {
            let data = bundle.getDataFor(fileName: "ConversationsCount100.json", subdirectory: "Mocks")!
            let routes = try JSONDecoder().decode([MockObject].self, from: data)

            client.updateStaticMockRoutes(routes: routes) { result in
                switch result {
                case .success(let routeDataArray):
                    XCTAssertEqual(routeDataArray.count, routes.count, "Expected the number of routes to match the input file.")
                case .failure(let error):
                    XCTFail("Failed to set bulk routes from file: \(error)")
                }
                bulkRouteExpectation.fulfill()
            }
        } catch {
            XCTFail("Failed to decode: \(error)")
        }

        wait(for: [bulkRouteExpectation], timeout: defaultTimeout)
    }

    fileprivate func loadScenarioFile(subdirectory: String, filename: String) {
        let bulkRouteExpectation = expectation(description: "Set bulk routes from scenario file")

        let bundle = Bundle(for: Self.self)

        do {
            let scenarioFileWithName = try ScenarioDataFactory.readScenarioFile(filename: filename, subdirectory: subdirectory, bundle: bundle)
            let routes = try ScenarioDataFactory.parseScenarioFile(from: scenarioFileWithName, bundle: bundle)
            client.updateStaticMockRoutes(routes: routes) { result in
                switch result {
                case .success(let routeDataArray):
                    XCTAssertEqual(routeDataArray.count, routes.count, "Expected the number of routes to match the input file.")
                case .failure(let error):
                    XCTFail("Failed to set bulk routes from scenario file: \(error)")
                }

                bulkRouteExpectation.fulfill()
            }

        } catch ScenarioDataError.missingFile(let message) {
            XCTFail("Error: Missing file - \(message)")
        } catch ScenarioDataError.jsonParsingError(let message) {
            XCTFail("Error: JSON Parsing failed - \(message)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        wait(for: [bulkRouteExpectation], timeout: 30)
    }

    func testBulkRouteActionsFromScenarioFileAsAFile() {
        let subdirectory = "Mocks/scenarioB"
        let filename = "scenario.json"
        loadScenarioFile(subdirectory: subdirectory, filename: filename)
    }

    func testBulkRouteActionsFromScenarioFileAsAFolder() {
        let resetStaticMocks = self.expectation(description:"Reset all mocks")
        let expectationsrp = self.expectation(description:"Fetch scenarios")
        let dynamicMock = DynamicMockBody(name: "loginWithSrp", enabled: true)

        client.resetAllMocksAndSettings { result in
            switch result {
            case .success(_):
                debugPrint("Reset all mocks Success \n")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            resetStaticMocks.fulfill()
        }
        wait(for: [resetStaticMocks], timeout: defaultTimeout)

        client.addDynamicMockScenario(dynamicMock: dynamicMock) { result in
            switch result {
            case .success(_):
                debugPrint("Enable loginWithSrp \n")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            expectationsrp.fulfill()
        }
        wait(for: [expectationsrp], timeout: defaultTimeout)

        let subdirectory = "Mocks/scenarios"
        let filename = "common-mocks-scenario.json"
        loadScenarioFile(subdirectory: subdirectory, filename: filename)
        let disableForwardExpectation = self.expectation(description: "Disable forward")

        client.setMockForwardingStatus(requestForward: RequestForward(enabled: false), completion: { result in
            switch result {
            case .success(let forward):
                XCTAssertFalse(forward.enabled, "The forward should be disabled.")
            case .failure(let error):
                XCTFail("Failed to fetch scenarios: \(error)")
            }
            disableForwardExpectation.fulfill()
        })

        wait(for: [disableForwardExpectation], timeout: defaultTimeout)
    }

    func testRegisterAPicture() {
        let expectation = expectation(description: "Upload picture from file")
        let bundle = Bundle(for: Self.self)
        let data = bundle.getDataFor(fileName: "placeholder.png", subdirectory: "Mocks")!

        let requestDetails = RequestDetails(exactUrl: ["/mail/valid.png"], method: "GET")
        let responseDetails = ResponseDetails(statusCode: 200, body: AnyCodable(value: data), headers: AnyCodable(value: ContentType.imagePng.asHeader))
        let routeRequest = MockObject(name: "TestScenario", enabled: true, updateFile: false, isRawFileContent: true, request: requestDetails, response: responseDetails)


        client.addStaticMockRoute(route: routeRequest) { result in
            switch result {
            case .success(let scenarios):
                XCTAssertEqual(scenarios.name, "TestScenario", "The scenario name should match the test scenario.")
            case .failure(let error):
                XCTFail("Failed to register static mock: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)
    }
}
