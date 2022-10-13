//
//  LoginExternalAccountNotSupportedSetup.swift
//  SampleApp
//
//  Created by Igor Kulman on 30.09.2022.
//

import Foundation
import OHHTTPStubs
import ProtonCore_Login

final class LoginExternalAccountNotSupportedSetup {
    static func stop() {
        HTTPStubs.removeAllStubs()
    }

    static func start() {
        HTTPStubs.setEnabled(true)

        // get code stub
        weak var usersStub = stub(condition: pathEndsWith("auth") && isMethodPOST()) { request in
            let url = LoginService.bundle.url(forResource: "AuthExtAccountsNotSupported", withExtension: "json")!
            let headers = ["Content-Type" : "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
        }
        usersStub?.name = "External accounts not supported stub"
    }
}
