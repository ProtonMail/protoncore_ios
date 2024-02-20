//
//  ObservabilityEventTests.swift
//  ProtonCore-Observability-Tests - Created on 16.12.22.
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

import XCTest
import ProtonCoreAuthentication
import ProtonCoreEnvironment
import ProtonCoreNetworking
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsObservability
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreObservability

final class ObservabilityEventTests: IntegrationTestCase {

    override var testBundle: Bundle? { Bundle(for: Self.self) }
    var environment: Environment { dynamicDomain.map(Environment.custom) ?? .black }

    final class TestServiceDelegate: APIServiceDelegate {
        var appVersion: String { "ios-mail@4.2.0-dev" }
        var userAgent: String? { nil }
        var locale: String { "en_US" }
        var additionalHeaders: [String: String]? { nil }
        func onUpdate(serverTime: Int64) { }
        func isReachable() -> Bool { true }
        func onDohTroubleshot() { }
    }

    let serviceDelegate = TestServiceDelegate()
    let expectationTimeout: TimeInterval = 60
    var authHelper: AuthHelper!

    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }

    override func setUp() {
        super.setUp()
        authHelper = AuthHelper()
    }

    override func tearDown() {
        authHelper = nil
        super.tearDown()
    }

    override class func tearDown() {
        PMAPIService.noTrustKit = false
        super.tearDown()
    }

    private func setupService(expectation: XCTestExpectation,
                              interval: TimeInterval = 0.5,
                              expectedHTTPResponse: Int = 200) -> ObservabilityServiceImpl {
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: environment, challengeParametersProvider: .empty)
        apiService.serviceDelegate = serviceDelegate
        apiService.authDelegate = authHelper

        return ObservabilityServiceImpl(
            requestPerformer: apiService,
            timer: ObservabilityTimerImpl(interval: interval),
            completion: { (task, result) in
                do {
                    let httpResponse = try XCTUnwrap(task?.response as? HTTPURLResponse)
                    XCTAssertEqual(httpResponse.statusCode, expectedHTTPResponse)
                } catch {
                    XCTFail("Response should unwrap")
                }
                expectation.fulfill()
            }
        )
    }

    let testResponses = [
        ResponseError(httpCode: 400, responseCode: nil, userFacingMessage: nil, underlyingError: nil),
        ResponseError(httpCode: 500, responseCode: nil, userFacingMessage: nil, underlyingError: nil)
    ]

    // MARK: - Test SSO auth schema

    func test_ssoAuth_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        HTTPResponseCodeStatus.allCases
            .map(ObservabilityEvent.ssoAuthWithTokenTotalEvent(status:))
            .forEach(service.report)
        testResponses
            .map(ObservabilityEvent.ssoAuthWithTokenTotalEvent(error:))
            .forEach(service.report)
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test SSO obtain challenge token schema

    func test_ssoObtainChallengeToken_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        SSOObtainChallengeTokenStatus.allCases
            .map(ObservabilityEvent.ssoObtainChallengeToken(status:))
            .forEach(service.report)
        testResponses
            .map(ObservabilityEvent.ssoObtainChallengeToken(error:))
            .forEach(service.report)
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test SSO identity provider login schema

    func test_ssoIdentityProviderLogin_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        SuccessOrFailureOrCanceledStatus.allCases
            .map(ObservabilityEvent.ssoIdentityProviderLoginResult(status:))
            .forEach(service.report)
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test SSO page load count schema

    func test_ssoPageLoadCountTotal_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        [200, 300, 400, 500]
            .flatMap {
                [($0, true), ($0, false)]
            }
            .map {
                ObservabilityEvent.ssoWebPageLoadCountTotal(responseStatusCode: $0, isProtonPage: $1)
            }
            .forEach {
                switch $0 {
                case .left(let event): service.report(event)
                case .right(let event): service.report(event)
                case nil: break
                }
            }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test SSO IDP page load count schema

    func test_ssoIDPPageLoadCountTotal_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        HTTPResponseCodeStatus.allCases
            .map(ObservabilityEvent.ssoIDPPageLoadCountTotal(status:))
            .forEach { service.report($0) }
        testResponses
            .map(ObservabilityEvent.ssoIDPPageLoadCountTotal(error:))
            .forEach(service.report)
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test SSO proton page load count schema

    func test_ssoProtonPageLoadCountTotal_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        HTTPResponseCodeStatus.allCases
            .map(ObservabilityEvent.ssoProtonPageLoadCountTotal(status:))
            .forEach { service.report($0) }
        testResponses
            .map(ObservabilityEvent.ssoProtonPageLoadCountTotal(error:))
            .forEach(service.report)
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test external account available schema

    func test_externalAccountAvailable_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 1.0)
        ExternalAccountAvailableStatus.allCases
            .map(ObservabilityEvent.externalAccountAvailableSignupTotal(status:))
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test proton account available schema

    func test_protonAccountAvailable_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 1.0)
        ProtonAccountAvailableSignupStatus.allCases
            .map(ObservabilityEvent.protonAccountAvailableSignupTotal(status:))
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test human verification schema

    func test_humanVerification_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 1.0)
        HumanVerificationOutcomeStatus.allCases
            .map(ObservabilityEvent.humanVerificationOutcomeTotal(status:))
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_humanVerificationScreenLoad_withSuccessfulStatus_isValid() {
        let expectation = expectation(description: "test_humanVerificationScreenLoad_withSuccessfulStatus_isValid")
        let service = setupService(expectation: expectation)
        service.report(.humanVerificationScreenLoadTotal(status: .successful))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_humanVerificationScreenLoad_withFailedStatus_isValid() {
        let expectation = expectation(description: "test_humanVerificationScreenLoad_withFailedStatus_isValid")
        let service = setupService(expectation: expectation)
        service.report(.humanVerificationScreenLoadTotal(status: .failed))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test plan selection schema

    func test_paidPlanSelection_withSuccessfulStatus_isValid() {
        let expectation = expectation(description: "test_unlimitedPlanSelection_withSuccessfulStatus_isValid")
        let service = setupService(expectation: expectation)
        service.report(.planSelectionCheckoutTotal(status: .successful, plan: .paid))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paidPlanSelection_withFailedStatus_isValid() {
        let expectation = expectation(description: "test_unlimitedPlanSelection_withFailedStatus_isValid")
        let service = setupService(expectation: expectation)
        service.report(.planSelectionCheckoutTotal(status: .failed, plan: .paid))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_freePlanSelection_withSuccessfulStatus_isValid() {
        let expectation = expectation(description: "test_freePlanSelection_withSuccessfulStatus_isValid")
        let service = setupService(expectation: expectation)
        service.report(.planSelectionCheckoutTotal(status: .successful, plan: .free))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_freePlanSelection_withFailedStatus_isValid() {
        let expectation = expectation(description: "test_freePlanSelection_withFailedStatus_isValid")
        let service = setupService(expectation: expectation)
        service.report(.planSelectionCheckoutTotal(status: .failed, plan: .free))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Test screen load count schema

    func test_screenLoadCount_forExternalAccountAvailable_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forExternalAccountAvailable_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .externalAccountAvailable))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forProtonAccountAvailable_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forProtonAccountAvailable_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .protonAccountAvailable))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forPasswordCreation_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forPasswordCreation_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .passwordCreation))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forSetRecoveryMethod_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forSetRecoveryMethod_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .setRecoveryMethod))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forEmailVerification_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forEmailVerification_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .emailVerification))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forCongratulation_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forCongratulation_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .congratulation))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forCreateProtonAccountWithCurrentEmail_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forCreateProtonAccountWithCurrentEmail_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .createProtonAccountWithCurrentEmail))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_screenLoadCount_forPlanSelection_isValid() {
        let expectation = expectation(description: "test_screenLoadCount_forPlanSelection_isValid")
        let service = setupService(expectation: expectation)
        service.report(.screenLoadCountTotal(screenName: .planSelection))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: test session token refresh failure count schema

    func test_failureCount_withAuthenticatedState_forSessionTokenRefresh_isValid() {
        let expectation = expectation(description: "test_failureCount_forSessionTokenRefresh_isValid")
        let service = setupService(expectation: expectation)
        service.report(.tokenRefreshFailureTotal(authState: .authenticated))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_failureCount_withUnauthenticatedState_forSessionTokenRefresh_isValid() {
        let expectation = expectation(description: "test_failureCount_forSessionTokenRefresh_isValid")
        let service = setupService(expectation: expectation)
        service.report(.tokenRefreshFailureTotal(authState: .unauthenticated))
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: test invalid event

    func test_invalidEventIsRejected() {
        struct InvalidData: Encodable, Equatable {}

        let event = ObservabilityEvent<PayloadWithLabels<InvalidData>>.init(
            name: "invalid_name",
            version: .v1,
            data: .init(value: 0, labels: .init())
        )
        let expectation = expectation(description: "test_invalidEventIsRejected")
        let service = setupService(expectation: expectation, expectedHTTPResponse: 422)
        service.report(event)
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: Payment events

    func test_paymentCreateToken_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        HTTPResponseCodeStatus.allCases
            .map { ObservabilityEvent.paymentCreatePaymentTokenTotal(status: $0) }
            .forEach { service.report($0) }
        testResponses
            .map { ObservabilityEvent.paymentCreatePaymentTokenTotal(error: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paymentLaunchBilling_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        PaymentLaunchBillingTotalStatus.allCases
            .map { ObservabilityEvent.paymentLaunchBillingTotal(status: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paymentPurchase_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        PaymentPurchaseTotalStatus.allCases
            .map { ObservabilityEvent.paymentPurchaseTotal(status: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paymentScreenView_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        PaymentsScreenViewScreenID.allCases
            .map { ObservabilityEvent.paymentScreenView(screenID: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paymentQuerySubscription_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        SuccessOrFailureStatus.allCases
            .map { ObservabilityEvent.paymentQuerySubscriptionsTotal(status: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paymentSubscribe_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        SuccessOrFailureStatus.allCases
            .map { ObservabilityEvent.paymentSubscribeTotal(status: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_paymentValidatePlan_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        HTTPResponseCodeStatus.allCases
            .map { ObservabilityEvent.paymentValidatePlanTotal(status: $0) }
            .forEach { service.report($0) }
        testResponses
            .map { ObservabilityEvent.paymentValidatePlanTotal(error: $0) }
            .forEach { service.report($0) }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    // MARK: - Dynamic plans

    func test_currentPlanLoad_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        service.report(.currentPlanLoad(status: .http2xx))
        [300, 400, 500, nil, 600, 409, 422].forEach { (httpStatus: Int?) in
            service.report(.currentPlanLoad(httpCode: httpStatus))
        }
        wait(for: [expectation], timeout: expectationTimeout)
    }

    func test_availablePlansLoad_everyStatus_isValid() {
        let expectation = expectation(description: #function)
        let service = setupService(expectation: expectation, interval: 2.0)
        service.report(.availablePlansLoad(status: .http2xx))
        [300, 400, 500, nil, 600, 409, 422].forEach { (httpStatus: Int?) in
            service.report(.availablePlansLoad(httpCode: httpStatus))
        }
        wait(for: [expectation], timeout: expectationTimeout)
    }
}
