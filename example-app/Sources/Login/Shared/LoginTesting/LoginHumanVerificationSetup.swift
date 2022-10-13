//
//  LoginHumanVerificationSetup.swift
//  SampleApp
//
//  Created by Igor Kulman on 14.12.2020.
//

import Foundation
import OHHTTPStubs
import ProtonCore_Log

final class LoginHumanVerificationSetup {
    static func stop() {
        HTTPStubs.removeAllStubs()
        HTTPStubs.setEnabled(false)
    }

    static func start(hostUrl: String) {
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

        if ProcessInfo.processInfo.arguments.contains("UITests_MockHVInAuth") {
            weak var usersStub = stub(condition: isHost(domainName) && pathEndsWith("auth") && isMethodPOST() && isFirstRequest()) { request in
                let url = Bundle.main.url(forResource: "HumanVerificationFail", withExtension: "json")!
                let headers = ["Content-Type" : "application/json;charset=utf-8"]
                requestCount += 1
                return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
            }
            usersStub?.name = "Users HumanVerificationFail stub"
        } else {
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
