//
//  HumanCheckHelperTests.swift
//  ProtonCore-HumanVerification-Tests - Created on 29/10/20.
//
//  Copyright (c) 2022 Proton Technologies AG
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

#if os(iOS)

import XCTest

#if SPM
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreCryptoPatchedGoImplementation
#else
import ProtonCoreTestingToolkit
import ProtonCoreCryptoGoImplementation
#endif

import ProtonCoreChallenge
import ProtonCoreDoh
import ProtonCoreServices
import ProtonCoreNetworking
import ProtonCoreCryptoGoInterface
@testable import ProtonCoreHumanVerification

class HumanCheckHelperTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    func testHumanCheckHelperClose() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectationDelegateEnd = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")

        let delegate = HumanVerifyResponseDelegateMock()
        delegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }
        delegate.onHumanVerifyEndStub.bodyIs { _, _ in expectationDelegateEnd.fulfill() }

        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(), challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        // also test pass in v2. work as v3
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl, inAppTheme: { .default }, clientApp: .mail)
        humanCheckHelper.responseDelegateForLoginAndSignup = delegate
        // triger close from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            humanCheckHelper.humanCheckCoordinator?.delegate?.close()
        }
        let parameters = HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha),
                                                         VerifyMethod(predefinedMethod: .email)], startToken: "")
        humanCheckHelper.onHumanVerify(parameters: parameters, currentURL: nil) { reason in
            switch reason {
            case .verification: XCTFail()
            case .close: expectation1.fulfill()
            case .closeWithError: XCTFail()
            }
        }

        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)
        wait(for: [expectationDelegateStart, expectation1, expectationDelegateEnd], timeout: 3, enforceOrder: true)

        XCTAssertTrue(delegate.humanVerifyTokenStub.wasNotCalled)
    }

    func testHumanCheckHelperFinalToken() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectationDelegateEnd = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")
        let expectation2 = self.expectation(description: "Success send code completion block called")

        let delegate = HumanVerifyResponseDelegateMock()
        delegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }
        delegate.onHumanVerifyEndStub.bodyIs { _, _ in expectationDelegateEnd.fulfill() }

        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(), challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl,
                                                inAppTheme: { .default }, clientApp: .mail)
        humanCheckHelper.responseDelegateForLoginAndSignup = delegate
        // triger finalToken from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.methods = [VerifyMethod(predefinedMethod: .email)]
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.finalToken(method: VerifyMethod(predefinedMethod: .email), token: "666666", complete: { result, error, _ in
                XCTAssertEqual(result, true)
                XCTAssertEqual(error, nil)
                expectation1.fulfill()
            })
        }

        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha), VerifyMethod(predefinedMethod: .email)], startToken: ""), currentURL: nil) { reason in
            switch reason {
            case .verification(let header, let verificationCodeBlock):
                XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "email" as String)
                XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "666666" as String)
                // send final result to backend and trigger verificationCodeBlock
                verificationCodeBlock?(true, nil, nil)
                expectation2.fulfill()
            case .close:
                XCTFail()
            case .closeWithError:
                XCTFail()
            }
        }

        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)

        wait(for: [expectationDelegateStart, expectation1, expectationDelegateEnd, expectation2], timeout: 3, enforceOrder: true)

        XCTAssertTrue(delegate.humanVerifyTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(delegate.humanVerifyTokenStub.lastArguments?.first, "666666")
        XCTAssertEqual(delegate.humanVerifyTokenStub.lastArguments?.second, "email")
    }

    func testHumanCheckHelperFinalError() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")
        let expectation2 = self.expectation(description: "Success send code completion block called")

        let delegate = HumanVerifyResponseDelegateMock()
        delegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }

        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(), challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl, inAppTheme: { .default }, clientApp: .mail)
        humanCheckHelper.responseDelegateForLoginAndSignup = delegate
        // triger finalToken from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.methods = [VerifyMethod(predefinedMethod: .email)]
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.finalToken(method: VerifyMethod(predefinedMethod: .email), token: "111111", complete: { result, error, _ in
                XCTAssertEqual(result, false)
                XCTAssert(error != nil)
                XCTAssertEqual(error?.underlyingError?.code, 123)
                XCTAssertEqual(error?.underlyingError?.domain, "test")
                expectation1.fulfill()
            })
        }

        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha), VerifyMethod(predefinedMethod: .email)], startToken: ""), currentURL: nil) { reason in
            switch reason {
            case .verification(let header, let verificationCodeBlock):
                XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "email" as String)
                XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "111111" as String)
                // send final result to backend and trigger verificationCodeBlock
                let testError = NSError(domain: "test", code: 123, userInfo: nil)
                verificationCodeBlock?(false, ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: nil, underlyingError: testError), nil)
                expectation2.fulfill()
            case .close:
                XCTFail()
            case .closeWithError:
                XCTFail()
            }
        }

        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)

        wait(for: [expectationDelegateStart, expectation1, expectation2], timeout: 3, enforceOrder: true)

        XCTAssertTrue(delegate.humanVerifyTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(delegate.humanVerifyTokenStub.lastArguments?.first, "111111")
        XCTAssertEqual(delegate.humanVerifyTokenStub.lastArguments?.second, "email")
    }

    func testHumanCheckHelperPaymentTokenSuccessful() {
        let expectation1 = self.expectation(description: "Success send code completion block called")

        let responseDelegate = HumanVerifyResponseDelegateMock()
        let paymentDelegate = HumanVerifyPaymentDelegateMock()
        paymentDelegate.paymentTokenStub.fixture = "payment_token"

        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(), challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl,
                                                inAppTheme: { .default }, clientApp: .mail)
        humanCheckHelper.responseDelegateForLoginAndSignup = responseDelegate
        humanCheckHelper.paymentDelegateForLoginAndSignup = paymentDelegate

        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha), VerifyMethod(predefinedMethod: .email)], startToken: ""), currentURL: nil) { reason in
            switch reason {
            case .verification(let header, let verificationCodeBlock):
                XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "payment" as String)
                XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "payment_token" as String)
                // send final result to backend and trigger verificationCodeBlock
                verificationCodeBlock?(true, nil, nil)
                expectation1.fulfill()
            case .close:
                XCTFail()
            case .closeWithError:
                XCTFail()
            }
        }

        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)

        wait(for: [expectation1], timeout: 3, enforceOrder: true)

        XCTAssertTrue(responseDelegate.onHumanVerifyStartStub.wasNotCalled)
        XCTAssertTrue(responseDelegate.humanVerifyTokenStub.wasNotCalled)
        XCTAssertTrue(responseDelegate.onHumanVerifyEndStub.wasNotCalled)
        XCTAssertTrue(paymentDelegate.paymentTokenStub.getWasCalledExactlyOnce)
        XCTAssertTrue(paymentDelegate.paymentTokenStatusChangedStub.wasCalledExactlyOnce)
        XCTAssertEqual(paymentDelegate.paymentTokenStatusChangedStub.lastArguments?.value, .success)
    }

    func testHumanCheckHelperUsesRegularHVFlowIfPaymentTokenFailed() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectationDelegateEnd = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")
        let expectation2 = self.expectation(description: "Success send code completion block called")

        let responseDelegate = HumanVerifyResponseDelegateMock()
        responseDelegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }
        responseDelegate.onHumanVerifyEndStub.bodyIs { _, _ in expectationDelegateEnd.fulfill() }
        let paymentDelegate = HumanVerifyPaymentDelegateMock()
        paymentDelegate.paymentTokenStub.fixture = "payment_token"

        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(), challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl,
                                                inAppTheme: { .default }, clientApp: .mail)
        humanCheckHelper.responseDelegateForLoginAndSignup = responseDelegate
        humanCheckHelper.paymentDelegateForLoginAndSignup = paymentDelegate

        // triger finalToken from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.methods = [VerifyMethod(predefinedMethod: .email)]
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.finalToken(method: VerifyMethod(predefinedMethod: .email), token: "666666", complete: { result, error, _ in
                XCTAssertEqual(result, true)
                XCTAssertEqual(error, nil)
                expectation1.fulfill()
            })
        }

        var count = 0
        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha), VerifyMethod(predefinedMethod: .email)], startToken: ""), currentURL: nil) { reason in
            switch reason {
            case .verification(let header, let verificationCodeBlock):
                if count == 0 {
                    count += 1
                    XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "payment" as String)
                    XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "payment_token" as String)
                    verificationCodeBlock?(false, nil, nil)
                } else {
                    XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "email" as String)
                    XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "666666" as String)
                    verificationCodeBlock?(true, nil, nil)
                    expectation2.fulfill()
                }

            case .close:
                XCTFail()
            case .closeWithError:
                XCTFail()
            }
        }

        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)

        wait(for: [expectationDelegateStart, expectation1, expectationDelegateEnd, expectation2], timeout: 3, enforceOrder: true)

        XCTAssertTrue(responseDelegate.humanVerifyTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(responseDelegate.humanVerifyTokenStub.lastArguments?.first, "666666")
        XCTAssertEqual(responseDelegate.humanVerifyTokenStub.lastArguments?.second, "email")
        XCTAssertTrue(paymentDelegate.paymentTokenStub.getWasCalledExactlyOnce)
        XCTAssertTrue(paymentDelegate.paymentTokenStatusChangedStub.wasCalledExactlyOnce)
        XCTAssertEqual(paymentDelegate.paymentTokenStatusChangedStub.lastArguments?.value, .fail)
    }

    func testHumanCheckHelperOnDeviceVerifySuccess() {
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(),
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"),
                                                                                                                 challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl, inAppTheme: { .default }, clientApp: .mail)
        var parameters = DeviceVerifyParameters(challengeType: .Argon2,
                                                challengePayload: "qbYJSn07JQGfol0u8MJTZ16fDRyFo2AR6phcgqlZCr44RBpz/odJc17EROMfMOpz2dE8oHW2JHeqoRax2ha4bpGusDBkEySSWJU+cmuWePzUC58fTY+VJMLBMDLhdqV9QKvozeqKcoPzqDoHZZYmyWQf4DIAKfgaha/WwzMikQMBAAAAIAAAAOEQAAABAAAA")

        let argon2Solved = humanCheckHelper.onDeviceVerify(parameters: parameters)
        XCTAssertNotNil(argon2Solved)
        XCTAssertTrue(argon2Solved!.contains("ewAAAAAAAABXe+n/4g0Hfz40eEw7h5d3XeiKdWilfCJvz0izj7p0YA=="))
        parameters = DeviceVerifyParameters(challengeType: .ECDLP,
                                                challengePayload: "kavkPtdQF/bQMvMlCjfgMdRdMsIsA8DP0X0/p44n+6jcchSeEewrjqcwy0FYF0jkWO1Wz1pdSe3meRNtpf+g2DQluiIbobuq4mM7J45fabUlKRtbEhSogoc9H3S74Wlj")
        let ECDLPSolved = humanCheckHelper.onDeviceVerify(parameters: parameters)
        XCTAssertNotNil(ECDLPSolved)
        XCTAssertTrue(ECDLPSolved!.contains("ngAAAAAAAAAczZrEZLqS9+TGdB7vNex1HzvPpFJD7Qd4+yPEgGduDw=="))
    }

    func testHumanCheckHelperOnDeviceVerifyError() {
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock(),
                                                                     challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"),
                                                                                                                 challenge: .init()))
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl, inAppTheme: { .default }, clientApp: .mail)
        let parameters = DeviceVerifyParameters(challengeType: .Argon2,
                                                challengePayload: "qbYJSn07JQGfol")
        XCTAssertNil(humanCheckHelper.onDeviceVerify(parameters: parameters))
    }
}

#endif
