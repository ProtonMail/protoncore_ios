//
//  LoginAndSignupTests.swift
//  ProtonCore-Login-Tests - Created on 14.10.22.
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

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreServices
import ProtonCoreUtilities
@testable import ProtonCoreFeatureFlags
@testable import ProtonCoreChallenge
@testable import ProtonCoreNetworking
@testable import ProtonCoreLoginUI
@testable import ProtonCoreUIFoundations
import TrustKit

final class LoginAndSignupTests: XCTestCase {

    var testService: PMAPIService {
        PMAPIService.createAPIServiceWithoutSession(environment: .custom("test env"),
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
    }

    func testAccountDeletionTranslationsAreDefinedForEnglish() {
        testAllLocalizationsAreDefined(for: LUITranslation.self, prefixForMissingValue: #function)
    }

    func testAllSubstitutionsAreFollowingTheExpectedFormatForEnglish() {
        testAllSubstitutionsAreValid(for: LUITranslation.self)
    }

    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_RecommendedInitializer() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: testService,
                                 minimumAccountType: .username, isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }

    func testLoginModuleAsksForSession() throws {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: .init())
        _ = LoginAndSignup(appName: "test app",
                           clientApp: .other(named: "core"),
                           apiService: mockService,
                           minimumAccountType: .username, isCloseButtonAvailable: true,
                           paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        XCTAssertTrue(mockService.acquireSessionIfNeededStub.wasCalledExactlyOnce)
    }

    func testLoginModuleUsesProvidedChallenge() throws {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        let challenge = PMChallenge()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let loginAndSignup = LoginAndSignup(appName: "test app",
                                            clientApp: .other(named: "core"),
                                            apiService: mockService,
                                            minimumAccountType: .username, isCloseButtonAvailable: true,
                                            paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        XCTAssertIdentical(loginAndSignup.container.challenge, challenge)
    }

    func testLoginModuleSetsTextfieldObserversOnProvidedChallenge() throws {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        let challenge = PMChallenge()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let loginAndSignup = LoginAndSignup(appName: "test app",
                                            clientApp: .other(named: "core"),
                                            apiService: mockService,
                                            minimumAccountType: .username, isCloseButtonAvailable: true,
                                            paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let signupViewController = UIStoryboard.instantiate(storyboardName: "PMSignup", controllerType: SignupViewController.self, inAppTheme: { .default })
        signupViewController.viewModel = loginAndSignup.container.makeSignupViewModel()
        signupViewController.signupAccountType = .internal
        _ = signupViewController.view
        XCTAssertNotNil(challenge.getInterceptor(textField: signupViewController.internalNameTextField.textField))
        XCTAssertNotNil(challenge.getInterceptor(textField: signupViewController.externalEmailTextField.textField))
        XCTAssertIdentical(loginAndSignup.container.challenge, challenge)
    }

    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer1() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(
            appName: "test app",
            clientApp: .other(named: "core"),
            apiService: testService,
            minimumAccountType: .username,
            isCloseButtonAvailable: true,
            paymentsAvailability: .notAvailable,
            signupAvailability: .notAvailable
        )
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }

    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer2() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(
            appName: "test app",
            clientApp: .other(named: "core"),
            apiService: testService,
            minimumAccountType: .username,
            isCloseButtonAvailable: true,
            paymentsAvailability: .notAvailable,
            signupAvailability: .notAvailable
        )
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }

    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer3() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: testService,
                                 minimumAccountType: .username,
                                 isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable,
                                 signupAvailability: .notAvailable)
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }

    func testStartingLoginFlowSetsHVDelegates() {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        let challenge = PMChallenge()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: mockService,
                                 minimumAccountType: .username,
                                 isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable,
                                 signupAvailability: .notAvailable)
        let humanDelegate = HumanVerifyDelegateMock()
        mockService.humanDelegateStub.fixture = humanDelegate
        let authDelegate = AuthDelegateMock()
        mockService.authDelegateStub.fixture = authDelegate
        let vc = UIViewController()
        out.presentLoginFlow(over: vc) { result in }
        XCTAssertTrue(humanDelegate.responseDelegateForLoginAndSignupStub.setWasCalledExactlyOnce)
        XCTAssertIdentical(humanDelegate.responseDelegateForLoginAndSignupStub.setLastArguments?.value, out.container)
        XCTAssertTrue(humanDelegate.paymentDelegateForLoginAndSignupStub.setWasCalledExactlyOnce)
        XCTAssertIdentical(humanDelegate.paymentDelegateForLoginAndSignupStub.setLastArguments?.value, out.container)
    }

    func testLoginFlowUnregistersHVDelegatesOnFinish() {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        let challenge = PMChallenge()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: mockService,
                                 minimumAccountType: .username,
                                 isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable,
                                 signupAvailability: .notAvailable)
        let humanDelegate = HumanVerifyDelegateMock()
        mockService.humanDelegateStub.fixture = humanDelegate
        let authDelegate = AuthDelegateMock()
        mockService.authDelegateStub.fixture = authDelegate
        let vc = UIViewController()
        out.presentLoginFlow(over: vc) { result in }
        out.userDidDismissLoginCoordinator(loginCoordinator: out.loginCoordinator!)
        XCTAssertEqual(humanDelegate.responseDelegateForLoginAndSignupStub.setCallCounter, 2)
        XCTAssertNil(humanDelegate.responseDelegateForLoginAndSignupStub.setLastArguments?.value)
        XCTAssertEqual(humanDelegate.paymentDelegateForLoginAndSignupStub.setCallCounter, 2)
        XCTAssertNil(humanDelegate.paymentDelegateForLoginAndSignupStub.setLastArguments?.value)
    }

    func testStartingSignupFlowSetsHVDelegates() {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        let challenge = PMChallenge()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: mockService,
                                 minimumAccountType: .username,
                                 isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable,
                                 signupAvailability: .available(parameters: .init(separateDomainsButton: true, passwordRestrictions: .default, summaryScreenVariant: .noSummaryScreen)))
        let humanDelegate = HumanVerifyDelegateMock()
        mockService.humanDelegateStub.fixture = humanDelegate
        let authDelegate = AuthDelegateMock()
        mockService.authDelegateStub.fixture = authDelegate
        let vc = UIViewController()
        out.presentSignupFlow(over: vc) { result in }
        XCTAssertTrue(humanDelegate.responseDelegateForLoginAndSignupStub.setWasCalledExactlyOnce)
        XCTAssertIdentical(humanDelegate.responseDelegateForLoginAndSignupStub.setLastArguments?.value, out.container)
        XCTAssertTrue(humanDelegate.paymentDelegateForLoginAndSignupStub.setWasCalledExactlyOnce)
        XCTAssertIdentical(humanDelegate.paymentDelegateForLoginAndSignupStub.setLastArguments?.value, out.container)
    }

    func testSignupFlowUnregistersHVDelegatesOnFinish() {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        let challenge = PMChallenge()
        mockService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: mockService,
                                 minimumAccountType: .username,
                                 isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable,
                                 signupAvailability: .available(parameters: .init(separateDomainsButton: true, passwordRestrictions: .default, summaryScreenVariant: .noSummaryScreen)))
        let humanDelegate = HumanVerifyDelegateMock()
        mockService.humanDelegateStub.fixture = humanDelegate
        let authDelegate = AuthDelegateMock()
        mockService.authDelegateStub.fixture = authDelegate
        let vc = UIViewController()
        out.presentSignupFlow(over: vc) { result in }
        out.userDidDismissSignupCoordinator(signupCoordinator: out.signupCoordinator!)
        XCTAssertEqual(humanDelegate.responseDelegateForLoginAndSignupStub.setCallCounter, 2)
        XCTAssertNil(humanDelegate.responseDelegateForLoginAndSignupStub.setLastArguments?.value)
        XCTAssertEqual(humanDelegate.paymentDelegateForLoginAndSignupStub.setCallCounter, 2)
        XCTAssertNil(humanDelegate.paymentDelegateForLoginAndSignupStub.setLastArguments?.value)
    }
}

private class DummyRemoteDataSource: RemoteFeatureFlagsDataSourceProtocol {
    var didGetFlags = false
    func getFlags() async throws -> (featureFlags: [FeatureFlag], userID: String) {
        didGetFlags = true
        return ([], "")
    }
}

#endif
