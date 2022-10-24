//
//  LoginMockingSetup.swift
//  SampleApp
//
//  Created by Igor Kulman on 14.12.2020.
//

import Foundation
import OHHTTPStubs
import ProtonCore_Log

final class LoginMockingSetup {
    static func stop() {
        HTTPStubs.removeAllStubs()
        HTTPStubs.setEnabled(false)
    }

    static func start(hostUrl: String, shouldMockHumanVerification: Bool) {
        guard let url = URL(string: hostUrl), let hostName = url.host  else {
            fatalError("Cannot get host from URL")
        }
        
        stop()

        let subStrings = hostName.components(separatedBy: ".")
        var domainName = ""
        let count = subStrings.count
        if count > 2 {
            domainName = subStrings.joined(separator: ".")
        } else if count == 2 {
            domainName = hostName
        }
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation() { request, descriptor, response in
            PMLog.info("\(request.url!) stubbed by \(String(describing: descriptor.name)).")
        }

        var requestCount = 0
        func isFirstRequest() -> HTTPStubsTestBlock {
            return { _ in requestCount == 0 }
        }
        // The parameter controlling the mocking here is set in the UI tests.
        //
        // In the UI tests testing the feature that requires mocking for simulation, the UI tests runner sets the appropriate app's launch argument via:
        // launchArguments.append(ParameterControllingMocking)
        // app.launchArguments = launchArguments
        //
        // The `ProtonCoreBaseTestCase` class has helper for that:
        // `ProtonCoreBaseTestCase.beforeSetUp(bundleIdentifier:launchArguments:launchEnvironment:)`
        //
        if ProcessInfo.processInfo.arguments.contains("UITests_MockExternalAccountsUnavailableInAuth") {
            stub(condition: isHost(domainName) && pathEndsWith("auth") && isMethodPOST()) { request in
                let response = """
                { "Code": 5099, "Error": "UI tests mocking External accounts not supported" }
                """.data(using: .utf8)!
                let headers = ["Content-Type" : "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: response, statusCode: 404, headers: headers)
            }
        } else if shouldMockHumanVerification, ProcessInfo.processInfo.arguments.contains("UITests_MockHVInAuth") {
            weak var usersStub = stub(condition: isHost(domainName) && pathEndsWith("auth") && isMethodPOST() && isFirstRequest()) { request in
                let url = Bundle.main.url(forResource: "HumanVerificationFail", withExtension: "json")!
                let headers = ["Content-Type" : "application/json;charset=utf-8"]
                requestCount += 1
                return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
            }
            usersStub?.name = "Users HumanVerificationFail stub"
        } else if shouldMockHumanVerification {
            weak var usersStub = stub(condition: isHost(domainName) && pathEndsWith("users") && isMethodGET() && isFirstRequest()) { request in
                let url = Bundle.main.url(forResource: "HumanVerificationFail", withExtension: "json")!
                let headers = ["Content-Type" : "application/json;charset=utf-8"]
                requestCount += 1
                return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
            }
            usersStub?.name = "Users HumanVerificationFail stub"
        }
        
    }
}
