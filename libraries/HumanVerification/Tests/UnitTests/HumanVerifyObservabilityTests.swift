//
//  HumanVerifyObservabilityTests.swift
//  ProtonCore-HumanVerification-iOS-Unit-Tests - Created on 15.02.23.
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

#if os(iOS)

@testable import ProtonCoreHumanVerification
@testable import ProtonCoreObservability
@testable import ProtonCoreNetworking
#if SPM
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

import WebKit
import XCTest

final class HumanVerifyObservabilityTests: XCTestCase {
    var sut: HumanVerifyViewController!
    var apiService: APIServiceMock!
    var observabilityService: ObservabilityServiceMock!
    var dohMock: DohInterfaceMock!
    private var wkNavigation: WKNavigationMock!
    
    override func setUp() {
        super.setUp()
        setUpMock()
        sut = UIStoryboard.instantiate(
            storyboardName: "HumanVerify",
            controllerType: HumanVerifyViewController.self,
            name: "HumanVerifyViewController"
        )
        sut.viewModel = .init(api: apiService, startToken: "", methods: nil, clientApp: .drive)
    }
    
    private func setUpMock() {
        wkNavigation = WKNavigationMock()
        observabilityService = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observabilityService
        apiService = APIServiceMock()
        dohMock = DohInterfaceMock()
        dohMock.getHumanVerificationV3HostStub.bodyIs { _ in
            "test.proton.test"
        }
        dohMock.getHumanVerificationV3HeadersStub.bodyIs { _ in
            ["test.proton.test": "test.proton.test"]
        }
        dohMock.handleErrorResolvingProxyDomainIfNeededWithExecutorWithSessionIdStub.bodyIs { _, _, _, _, _, _, completion in
            completion(true)
        }
        apiService.dohInterfaceStub.fixture = dohMock
        apiService.sessionUIDStub.fixture = "ID"
    }
    
    // MARK: - HV Canceled
    
    func test_closeAction_reportsHVCanceled() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationOutcomeTotal(status: .canceled)
        
        // When
        sut.closeAction(SenderMock())
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    // MARK: - HV Failed
    
    func test_webViewDidFailProvisionalNavigation_reportsHVFailed() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationScreenLoadTotal(status: .failed)
        _ = sut.view
        
        // When
        sut.webView(sut.webView, didFailProvisionalNavigation: wkNavigation, withError: AnyError())
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_webViewDidFail_reportsHVFailed() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationScreenLoadTotal(status: .failed)
        _ = sut.view
        
        // When
        sut.webView(sut.webView, didFail: wkNavigation, withError: AnyError())
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_userContentController_loaded_reportsHVSuccessfullyLoaded() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationScreenLoadTotal(status: .successful)
        let messageBody = """
            {"type": "LOADED"}
        """
        _ = sut.view
        
        // When
        sut.userContentController(WKUserContentController(), didReceive: WKScriptMessageMock(name: "iOS", body: messageBody))
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_userContentController_humanVerificationSuccess_reportsHVOutcomeSuccessful() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationOutcomeTotal(status: .successful)
        let messageBody = """
            {
                "type": "HUMAN_VERIFICATION_SUCCESS",
                "payload": {
                    "token": "token",
                    "type": "captcha"
                }
            }
        """
        sut.viewModel.onVerificationCodeBlock = { completion in
            completion(true, nil, {})
        }
        _ = sut.view
        
        // When
        sut.userContentController(WKUserContentController(), didReceive: WKScriptMessageMock(name: "iOS", body: messageBody))
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_userContentController_close_reportsHVOutcomeFailed() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationOutcomeTotal(status: .failed)
        let messageBody = """
            { "type": "CLOSE" }
        """
        sut.dispatchQueue = .immediateExecutor
        _ = sut.view
        
        // When
        sut.userContentController(WKUserContentController(), didReceive: WKScriptMessageMock(name: "iOS", body: messageBody))
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_userContentController_error_reportsHVOutcomeFailed() {
        // Given
        let expectedEvent: ObservabilityEvent = .humanVerificationOutcomeTotal(status: .failed)
        let messageBody = """
            {
                "type": "ERROR",
                "payload": {
                    "code": 1
                }
            }
        """
        sut.dispatchQueue = .immediateExecutor
        _ = sut.view
        
        // When
        sut.userContentController(WKUserContentController(), didReceive: WKScriptMessageMock(name: "iOS", body: messageBody))
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasCalledExactlyOnce)
        XCTAssertTrue(observabilityService.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_userContentController_humanVerificationAddressAlreadyTaken_doesNotReportsHVOutcomeFailed() {
        // Given
        let messageBody = """
            {
                "type": "HUMAN_VERIFICATION_SUCCESS",
                "payload": {
                    "token": "token",
                    "type": "captcha"
                }
            }
        """
        sut.dispatchQueue = .immediateExecutor
        sut.viewModel.onVerificationCodeBlock = { completion in
            completion(false, ResponseError(httpCode: nil, responseCode: 2001, userFacingMessage: nil, underlyingError: nil), {})
        }
        _ = sut.view
        
        // When
        sut.userContentController(WKUserContentController(), didReceive: WKScriptMessageMock(name: "iOS", body: messageBody))
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasNotCalled)
    }
    
    func test_userContentController_invalidVerificationCode_doesNotReportsHVOutcomeFailed() {
        // Given
        let messageBody = """
            {
                "type": "HUMAN_VERIFICATION_SUCCESS",
                "payload": {
                    "token": "token",
                    "type": "captcha"
                }
            }
        """
        sut.dispatchQueue = .immediateExecutor
        sut.viewModel.onVerificationCodeBlock = { completion in
            completion(false, ResponseError(httpCode: nil, responseCode: 12087, userFacingMessage: nil, underlyingError: nil), {})
        }
        _ = sut.view
        
        // When
        sut.userContentController(WKUserContentController(), didReceive: WKScriptMessageMock(name: "iOS", body: messageBody))
        
        // Then
        XCTAssertTrue(observabilityService.reportStub.wasNotCalled)
    }
}

private class SenderMock {}
private struct AnyError: Error {}
private class WKNavigationMock: WKNavigation {}

#endif
