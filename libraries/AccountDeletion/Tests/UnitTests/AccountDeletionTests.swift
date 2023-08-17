//
//  AccountDeletionTests.swift
//  ProtonCore-AccountDeletion-Tests - Created on 10.12.21.
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
import UIKit

@testable import ProtonCoreAccountDeletion

import ProtonCoreAuthentication
import ProtonCoreNetworking
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsAccountDeletion
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreDoh
import ProtonCoreUIFoundations
import WebKit

let navigation = WKNavigation()

@available(iOS 13.0.0, *)
final class AccountDeletionTests: XCTestCase {
    
    var apiMock: APIServiceMock!
    var dohMock: DohMock!
    var viewModelMock: AccountDeletionViewModelMock!
    var webViewDelegateMock: AccountDeletionWebViewDelegateMock!
    
    override func setUp() {
        super.setUp()
        apiMock = APIServiceMock()
        dohMock = DohMock()
        viewModelMock = AccountDeletionViewModelMock()
        webViewDelegateMock = AccountDeletionWebViewDelegateMock()
    }
    
    func testAccountDeletionTranslationsAreDefinedForEnglish() {
        testAllLocalizationsAreDefined(for: ADTranslation.self, prefixForMissingValue: #function)
    }
    
    func testAllSubstitutionsAreFollowingTheExpectedFormatForEnglish() {
        testAllSubstitutionsAreValid(for: ADTranslation.self)
    }
    
    // MARK: - AccountDeletionService tests
    
    func testAccountDeletionOperationFailsIfBackendDoesntConfirmUserIsDeletable() async throws {
        let presenterMock = AccountDeletionViewControllerPresenterMock()
        let out = AccountDeletionService(api: apiMock, doh: dohMock)
        apiMock.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/users/delete") {
                completion(nil, .failure(NSError(domain: NSURLErrorDomain, code: 444)))
            } else {
                completion(nil, .success([:]))
            }
        }
        let result = await withCheckedContinuation { continuation in
            out.initiateAccountDeletionProcess(presenter: presenterMock, completion: continuation.resume(returning:))
        }
        
        XCTAssertTrue(apiMock.requestJSONStub.wasCalledExactlyOnce)
        guard case .failure(.cannotDeleteYourself(let responseError)) = result else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, NSError(domain: NSURLErrorDomain, code: 444))
    }
    
    func testAccountDeletionOperationFailsIfSessionForkingFail() async throws {
        let presenterMock = AccountDeletionViewControllerPresenterMock()
        let out = AccountDeletionService(api: apiMock, doh: dohMock)
        apiMock.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/users/delete") {
                completion(nil, .success(["Code": 1000]))
            } else {
                completion(nil, .success([:]))
            }
        }
        apiMock.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks") {
                struct ForkingError: LocalizedError {
                    var errorDescription: String? { "session forking failed" }
                }
                completion(nil, .failure(ForkingError() as NSError))
            } else {
                completion(nil, .success([:]))
            }
        }
        let result = await withCheckedContinuation { continuation in
            out.initiateAccountDeletionProcess(presenter: presenterMock, completion: continuation.resume(returning:))
        }
        XCTAssertEqual(apiMock.requestJSONStub.callCounter, 1)
        XCTAssertEqual(apiMock.requestDecodableStub.callCounter, 1)
        guard case .failure(.sessionForkingError(let message)) = result else { XCTFail(); return }
        XCTAssertEqual(message, "session forking failed")
    }
    
    @MainActor
    func testAccountDeletionPresentsAccountDeletionWebViewWithRightSelectorIfForkingSucceeds() async throws {
        let presenterMock = AccountDeletionViewControllerPresenterMock()
        let out = AccountDeletionService(api: apiMock, doh: dohMock)
        dohMock.getAccountHostStub.bodyIs { _ in "https://proton.unittests/account" }
        apiMock.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/users/delete") {
                completion(nil, .success(["Code": 1000]))
            } else {
                completion(nil, .success([:]))
            }
        }
        apiMock.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks") {
                completion(nil, .success(AuthService.ForkSessionResponse.from(["Code": 1000, "Selector": "happy_test_selector"])))
            } else {
                completion(nil, .success([:]))
            }
        }
        
        presenterMock.presentStub.bodyIs { _, viewController, _, _ in
            guard let navigationController = viewController as? UINavigationController,
                  let webView = navigationController.topViewController as? AccountDeletionWebView else { XCTFail(); return }
            webView.viewModel.deleteAccountWasClosed()
        }

        let result = await withCheckedContinuation { continuation in
            out.initiateAccountDeletionProcess(presenter: presenterMock, completion: continuation.resume(returning:))
        }
        
        XCTAssertTrue(presenterMock.presentStub.wasCalledExactlyOnce)
        guard case .failure(.closedByUser) = result else { XCTFail(); return }
        guard let navigationController = presenterMock.presentStub.lastArguments?.first as? UINavigationController,
              let webView = navigationController.topViewController as? AccountDeletionWebView else { XCTFail(); return }
        XCTAssertEqual(webView.viewModel.getURLRequest.url?.absoluteString,
                       "https://proton.unittests/account/lite?action=delete-account&language=en_US#selector=happy_test_selector")
    }
    
    // MARK: - AccountDeletionWebView tests
    
    func testAccountDeletionWebViewDoNotPassMessageToViewModelIfNotForiOS() {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        let message = WKScriptMessageMock(name: "test name", body: "test body")
        webView.userContentController(WKUserContentController(), didReceive: message)
        XCTAssertTrue(viewModelMock.interpretMessageStub.wasNotCalled)
    }
    
    func testAccountDeletionWebViewDoPassMessageToViewModelIfForiOS() {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        let message = WKScriptMessageMock(name: "iOS", body: "test body")
        webView.userContentController(WKUserContentController(), didReceive: message)
        XCTAssertTrue(viewModelMock.interpretMessageStub.wasCalled)
    }
    
    func testAccountDeletionWebViewPresentsLoadingOnLoadingMessage() {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        webView.loader.startAnimating()
        viewModelMock.interpretMessageStub.bodyIs { _, _, loading, _, _, _ in loading() }
        let message = WKScriptMessageMock(name: "iOS", body: "test body")
        webView.userContentController(WKUserContentController(), didReceive: message)
        
        XCTAssertFalse(webView.loader.isAnimating)
    }
    
    func testAccountDeletionWebViewPresentsBannerOnNotification() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)
        viewModelMock.interpretMessageStub.bodyIs { _, _, _, notification, _, _ in notification(.info, "test message") }
        let message = WKScriptMessageMock(name: "iOS", body: "test body")
        webView.userContentController(WKUserContentController(), didReceive: message)
        
        XCTAssertEqual(webView.banner?.style as? PMBannerNewStyle, .info)
        XCTAssertEqual(webView.banner?.message, "test message")
    }
    
    func testAccountDeletionWebViewPresentsBannerOnSuccess() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)
        viewModelMock.interpretMessageStub.bodyIs { _, _, _, _, success, _ in success() }
        let message = WKScriptMessageMock(name: "iOS", body: "test body")
        webView.userContentController(WKUserContentController(), didReceive: message)
        
        XCTAssertEqual(webView.banner?.message, ADTranslation.delete_account_success.l10n)
    }
    
    func testAccountDeletionWebViewClosesOnCloseMessage() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        webView.stronglyKeptDelegate = webViewDelegateMock
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)
        var completionBlockWasCalled = false
        let completionBlock: () -> Void = { completionBlockWasCalled = true }
        viewModelMock.interpretMessageStub.bodyIs { _, _, _, _, _, close in close(completionBlock) }
        let message = WKScriptMessageMock(name: "iOS", body: "test body")
        webView.userContentController(WKUserContentController(), didReceive: message)
        
        XCTAssertFalse(completionBlockWasCalled)
        XCTAssertTrue(webViewDelegateMock.shouldCloseWebViewStub.wasCalledExactlyOnce)
        webViewDelegateMock.shouldCloseWebViewStub.lastArguments?.second()
        XCTAssertTrue(completionBlockWasCalled)
    }
    
    func testAccountDeletionPassesWebLoadingErrorToViewModelAfterLoadingStarted() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)
        
        _ = webView.view
        
        enum LoadingError: Error, Equatable { case someError }
        webView.webView(WKWebView(), didFail: navigation, withError: LoadingError.someError)

        XCTAssertTrue(viewModelMock.shouldRetryFailedLoadingStub.wasCalledExactlyOnce)
        XCTAssertEqual(viewModelMock.shouldRetryFailedLoadingStub.lastArguments?.second as? LoadingError, LoadingError.someError)
    }
    
    func testAccountDeletionDoesNotPassWebLoadingErrorToViewModelBeforeLoadingStarted() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)
        
        enum LoadingError: Error, Equatable { case someError }
        webView.webView(WKWebView(), didFail: navigation, withError: LoadingError.someError)

        XCTAssertTrue(viewModelMock.shouldRetryFailedLoadingStub.wasNotCalled)
    }
    
    func testAccountDeletionSetupsWebViewConfigurationBeforeLoading() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)

        _ = webView.view
        
        XCTAssertTrue(viewModelMock.setupStub.wasCalledExactlyOnce)
    }
    
    func testAccountDeletionClosesScreenAndCompletesWithErrorOnUnretriedLoadingError() throws {
        let webView = AccountDeletionWebView(viewModel: viewModelMock)
        webView.stronglyKeptDelegate = webViewDelegateMock
        viewModelMock.getURLRequestStub.fixture = try URLRequest(url: "https://example.com", method: .get)
        viewModelMock.shouldRetryFailedLoadingStub.bodyIs { _, _, _, completion in completion(.dontRetry) }
        webViewDelegateMock.shouldCloseWebViewStub.bodyIs { _, _, completion in completion() }
        
        _ = webView.view
        
        enum LoadingError: Error, Equatable { case someError }
        webView.webView(WKWebView(), didFail: navigation, withError: LoadingError.someError)

        XCTAssertTrue(viewModelMock.shouldRetryFailedLoadingStub.wasCalledExactlyOnce)
        XCTAssertEqual(viewModelMock.shouldRetryFailedLoadingStub.lastArguments?.second as? LoadingError, LoadingError.someError)
        XCTAssertTrue(webViewDelegateMock.shouldCloseWebViewStub.wasCalledExactlyOnce)
        XCTAssertTrue(viewModelMock.deleteAccountDidErrorOutStub.wasCalledExactlyOnce)
        XCTAssertEqual(viewModelMock.deleteAccountDidErrorOutStub.lastArguments?.value, LoadingError.someError.localizedDescription)
    }
    
    // MARK: - AccountDeletionViewModel tests
    
    func testAccountDeletionViewModelSetsSchemesInWKWebViewConfiguration() {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        let configuration = WKWebViewConfiguration()
        viewModel.setup(webViewConfiguration: configuration)
        for (custom, _) in AlternativeRoutingRequestInterceptor.schemeMapping {
            XCTAssertTrue(configuration.urlSchemeHandler(forURLScheme: custom) is AlternativeRoutingRequestInterceptor)
        }
    }
    
    func testAccountDeletionViewModelCallCompletionOnClosed() async {
        let result: Result<AccountDeletionSuccess, AccountDeletionError> = await withCheckedContinuation { continuation in
            let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                     performBeforeClosingAccountDeletionScreen: { _ in },
                                                     callCompletionBlockUsing: .immediateExecutor,
                                                     completion: continuation.resume(returning:))
            viewModel.deleteAccountWasClosed()
        }
        guard case .failure(.closedByUser) = result else { XCTFail(); return }
    }
    
    func testAccountDeletionViewModelCallCompletionOnError() async {
        let result: Result<AccountDeletionSuccess, AccountDeletionError> = await withCheckedContinuation { continuation in
            let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                     performBeforeClosingAccountDeletionScreen: { _ in },
                                                     callCompletionBlockUsing: .immediateExecutor,
                                                     completion: continuation.resume(returning:))
            viewModel.deleteAccountDidErrorOut(message: "test message")
        }
        guard case .failure(.deletionFailure("test message")) = result else { XCTFail(); return }
    }
    
    func testAccountDeletionViewModelPassesErrorToDoH() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        apiMock.sessionUIDStub.fixture = "test session ID"
        dohMock.getAccountHeadersStub.bodyIs { _ in [:] }
        dohMock.handleErrorResolvingProxyDomainIfNeededWithExecutorWithSessionIdStub.bodyIs { _, _, _, sessionId, error, _, completion in
            XCTAssertEqual(sessionId, "test session ID")
            XCTAssertEqual((error as? NSError)?.code, 444)
            completion(true)
        }
        
        let result: AccountDeletionRetryCheckResult = await withCheckedContinuation { continuation in
            viewModel.shouldRetryFailedLoading(host: "https://proton.unittests",
                                               error: NSError(domain: NSURLErrorDomain, code: 444),
                                               shouldReloadWebView: continuation.resume(returning:))
        }
        
        XCTAssertEqual(result, .retry)
    }

    func testAccountDeletionViewModelAddsLanguageHeaderExplicitly() {
        dohMock.getAccountHostStub.bodyIs { _ in "https://proton.unittests/account" }
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 preferredLanguage: "fr",
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        XCTAssert(viewModel.getURLRequest.url!.absoluteString.contains("language=fr"))
    }

    func testAccountDeletionViewModelAddsLanguageHeaderImplicitly() {
        dohMock.getAccountHostStub.bodyIs { _ in "https://proton.unittests/account" }
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        XCTAssert(viewModel.getURLRequest.url!.absoluteString.contains("language=en_US"))
    }
    
    func testAccountDeletionDoesNotCallAnyBlockIfMessageInvalid() {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        let message = WKScriptMessageMock(name: "test name", body: "")
        viewModel.interpretMessage(message,
                                   loadedPresentation: { XCTFail() },
                                   notificationPresentation: { _, _ in XCTFail() },
                                   successPresentation: { XCTFail() },
                                   closeWebView: { _ in XCTFail() })
    }
    
    func testAccountDeletionCallLoadedBlockIfLoadedMessage() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        let message = WKScriptMessageMock(name: "test name", body: "{\"type\":\"LOADED\"}")
        
        let _: Void = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: continuation.resume,
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: { XCTFail() },
                                       closeWebView: { _ in XCTFail() })
        }
    }
    
    func testAccountDeletionCallCloseBlockIfCloseMessage() async {
        let completionExpectation = expectation(description: "should call completion block")
        var result: Result<AccountDeletionSuccess, AccountDeletionError>?
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { completionExpectation.fulfill(); result = $0 })
        let message = WKScriptMessageMock(name: "test name", body: "{\"type\":\"CLOSE\"}")
        
        let _: () -> Void = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: { XCTFail() },
                                       closeWebView: continuation.resume)
        }
        wait(for: [completionExpectation], timeout: 1.0)
        guard case .failure(.closedByUser) = result else { XCTFail(); return }
    }
    
    func testAccountDeletionCausesCompletionWithNetworkingErrorIfNoErrorMessageInPayload() async {
        let message = WKScriptMessageMock(name: "test name", body: "{\"type\":\"ERROR\"}")
        var result: Result<AccountDeletionSuccess, AccountDeletionError>?
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { result = $0 })
        
        let _: () -> Void = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: { XCTFail() },
                                       closeWebView: { $0(); continuation.resume(returning: $0) })
        }
        
        guard case .failure(.deletionFailure(message: ADTranslation.delete_network_error.l10n)) = result else { XCTFail(); return }
    }
    
    func testAccountDeletionCallErrorBlockWithMessageFromPayload() async {
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"ERROR\", \"payload\": { \"message\": \"error message\" }}")
        
        var result: Result<AccountDeletionSuccess, AccountDeletionError>?
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { result = $0 })
        
        let _: () -> Void = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: { XCTFail() },
                                       closeWebView: { $0(); continuation.resume(returning: $0) })
        }
        guard case .failure(.deletionFailure("error message")) = result else { XCTFail(); return }
    }
    
    func testAccountDeletionCallNotificationBlockOnNotificationMessage() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"NOTIFICATION\", \"payload\": { \"type\": \"info\", \"text\": \"notification message\" }}")
        
        let result: (NotificationType, String) = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { continuation.resume(returning: ($0, $1)) },
                                       successPresentation: { XCTFail() },
                                       closeWebView: { _ in XCTFail() })
        }
        
        XCTAssertEqual(result.0, .info)
        XCTAssertEqual(result.1, "notification message")
    }
    
    func testAccountDeletionCallNotificationBlockDefaultsToWarningIfNothingSpecified() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"NOTIFICATION\", \"payload\": { \"text\": \"notification message\" }}")
        
        let result: (NotificationType, String) = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { continuation.resume(returning: ($0, $1)) },
                                       successPresentation: { XCTFail() },
                                       closeWebView: { _ in XCTFail() })
        }
        
        XCTAssertEqual(result.0, .warning)
        XCTAssertEqual(result.1, "notification message")
    }
    
    func testAccountDeletionCallNotificationBlockNotCalledIfNoMessage() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"NOTIFICATION\", \"payload\": { \"type\": \"info\" }}")
        
        viewModel.interpretMessage(message,
                                   loadedPresentation: { XCTFail() },
                                   notificationPresentation: { _, _ in XCTFail() },
                                   successPresentation: { XCTFail() },
                                   closeWebView: { _ in XCTFail() })
    }
    
    func testAccountDeletionCallSuccessBlockOnSuccessMessage() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"SUCCESS\", \"payload\": { \"message\": \"error message\" }}")
        
        let _: Void = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: continuation.resume,
                                       closeWebView: { _ in XCTFail() })
        }
    }
    
    func testAccountDeletionDoesNotCallSuccessBlockOnSecondSuccessMessage() async {
        let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                 performBeforeClosingAccountDeletionScreen: { _ in },
                                                 callCompletionBlockUsing: .immediateExecutor,
                                                 completion: { _ in })
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"SUCCESS\", \"payload\": { \"message\": \"error message\" }}")
        
        let _: Void = await withCheckedContinuation { continuation in
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: continuation.resume,
                                       closeWebView: { _ in XCTFail() })
        }
        
        viewModel.interpretMessage(message,
                                   loadedPresentation: { XCTFail() },
                                   notificationPresentation: { _, _ in XCTFail() },
                                   successPresentation: { XCTFail() },
                                   closeWebView: { _ in XCTFail() })
    }
    
    func testAccountDeletionCallPerformBeforeClosingAccountDeletionScreenOnSuccessMessage() async {
        let message = WKScriptMessageMock(name: "test name",
                                          body: "{\"type\":\"SUCCESS\", \"payload\": { \"message\": \"error message\" }}")
        
        let _: () -> Void = await withCheckedContinuation { continuation in
            
            let viewModel = AccountDeletionViewModel(forkSelector: "happy_for_selector", apiService: apiMock, doh: dohMock,
                                                     performBeforeClosingAccountDeletionScreen: continuation.resume(returning:),
                                                     callCompletionBlockUsing: .immediateExecutor,
                                                     completion: { _ in })
            
            viewModel.interpretMessage(message,
                                       loadedPresentation: { XCTFail() },
                                       notificationPresentation: { _, _ in XCTFail() },
                                       successPresentation: { },
                                       closeWebView: { _ in XCTFail() })
        }
    }
    
}

#endif
