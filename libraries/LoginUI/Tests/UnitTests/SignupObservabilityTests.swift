//
//  SignupObservabilityTests.swift
//  ProtonCore-LoginUI-Unit-UnitTests-Crypto-Go1.19.4 - Created on 10.02.23.
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

import XCTest

@testable import ProtonCoreLoginUI
@testable import ProtonCoreObservability
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif

final class SignupObservabilityTests: XCTestCase {
    var sut: SignupViewController!
    var serviceMock: ObservabilityServiceMock!
    var loginServiceMock: LoginMock!
    
    override func setUp() {
        super.setUp()
        setupMock()
        sut = UIStoryboard.instantiate(
            storyboardName: "PMSignup",
            controllerType: SignupViewController.self,
            inAppTheme: { .default }
        )
        sut.viewModel = SignupViewModel(
            signupService: SignupServiceMock(),
            loginService: loginServiceMock,
            challenge: .init()
        )
    }
    
    private func setupMock() {
        serviceMock = ObservabilityServiceMock()
        loginServiceMock = LoginMock()
        ObservabilityEnv.current.observabilityService = serviceMock
    }
    
    // MARK: - signupAccountType = .internal / minimumAccountType = .username
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndUsernameAccountType_reportsSuccessful() {
        // Given
        sut.signupAccountType = .internal
        // username is dropped. check user name will fall to checkAvailabilityForInternalAccount if account type is internal.
        sut.minimumAccountType = .username
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndUsernameAccountType_reportsGenericFailure() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .username
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .failed)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.generic(message: "", code: 0, originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndUsernameAccountType_reportsAPIFailure() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .username
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .apiMightBeBlocked)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.apiMightBeBlocked(message: "", originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndUsernameAccountType_reportsNoErrorIfNotAvailable() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .username
        let expectedEvent: ObservabilityEvent = .screenLoadCountTotal(screenName: .protonAccountAvailable)
        loginServiceMock.checkAvailabilityForUsernameAccountStub.bodyIs { _, _, completion in
            completion(.failure(.notAvailable(message: "")))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))    }
    
    // MARK: - signupAccountType = .internal / minimumAccountType = .internal
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndInternalAccountType_reportsSuccessful() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .internal
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndInternalAccountType_reportsGenericFailure() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .internal
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .failed)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.generic(message: "", code: 0, originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndInternalAccountType_reportsAPIFailure() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .internal
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .apiMightBeBlocked)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.apiMightBeBlocked(message: "", originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndInternalAccountType_reportsFailureIfNotAvailable() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .internal
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.notAvailable(message: "")))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    // MARK: - signupAccountType = .internal / minimumAccountType = .external
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndExternaldAccountType_reportsSuccessful() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .external
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndExternaldAccountType_reportsGenericFailure() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .external
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .failed)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.generic(message: "", code: 0, originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndExternaldAccountType_reportsAPIFailure() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .external
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .apiMightBeBlocked)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.apiMightBeBlocked(message: "", originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeInternalAndExternalAccountType_reportsFailureIfNotAvailable() {
        // Given
        sut.signupAccountType = .internal
        sut.minimumAccountType = .external
        let expectedEvent: ObservabilityEvent = .protonAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.notAvailable(message: "")))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    // MARK: - signupAccountType = .external
    
    func test_onNextButtonTap_withSignupAccountTypeExternal_reportsSuccessful() {
        // Given
        sut.signupAccountType = .external
        let expectedEvent: ObservabilityEvent = .externalAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForExternalAccountStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeExternal_reportsGenericFailure() {
        // Given
        sut.signupAccountType = .external
        let expectedEvent: ObservabilityEvent = .externalAccountAvailableSignupTotal(status: .failed)
        loginServiceMock.checkAvailabilityForExternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.generic(message: "", code: 0, originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withSignupAccountTypeExternal_reportsAPIFailure() {
        // Given
        sut.signupAccountType = .external
        let expectedEvent: ObservabilityEvent = .externalAccountAvailableSignupTotal(status: .apiMightBeBlocked)
        loginServiceMock.checkAvailabilityForExternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.apiMightBeBlocked(message: "", originalError: AnyError())))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
    
    func test_onNextButtonTap_withExternalAccountType_reportsFailureIfNotAvailable() {
        // Given
        sut.signupAccountType = .external
        let expectedEvent: ObservabilityEvent = .externalAccountAvailableSignupTotal(status: .successful)
        loginServiceMock.checkAvailabilityForExternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(.notAvailable(message: "")))
        }
        
        // When
        sut.onNextButtonTap(.init())
        
        // Then
        XCTAssertTrue(serviceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
    }
}

private struct AnyError: Error {}

#endif
