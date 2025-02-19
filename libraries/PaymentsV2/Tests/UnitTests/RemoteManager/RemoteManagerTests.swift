//
//  RemoteManagerTests.swift
//  ProtonCore-PaymentsV2Test - Created on 15/10/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

@testable import ProtonCorePaymentsV2
import XCTest

final class RemoteManagerTests: XCTestCase, @unchecked Sendable {

    private var paymentsAPI: PaymentsAPIs!
    private var urlSessionConfig: URLSessionConfiguration!
    private var sut: RemoteManager!
    private var mockRemoteManager: MockedRemoteManager!

    override func setUp() {
        super.setUp()

        mockRemoteManager = MockedRemoteManager()
        sut = mockRemoteManager.remoteManager
        paymentsAPI = mockRemoteManager.paymentsAPI
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        paymentsAPI = nil
        mockRemoteManager.destroy()
        mockRemoteManager = nil
    }

    func XCTAssertThrowsErrorAsync<T, R>(
        _ expression: @autoclosure () async throws -> T,
        _ errorThrown: @autoclosure () -> R,
        _ message: @autoclosure () -> String = "This method should fail",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async where R: Equatable, R: Error  {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            XCTAssertEqual(error as? R, errorThrown())
        }
    }
}

// MARK: Token
extension RemoteManagerTests {

    func test_check_token_status_unusable_token() async throws {

        let mockResponse: [String: Any] = [
            "Code": 1000,
            "Status": 0
        ]

        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        guard let request = try? paymentsAPI.url(for: .checkToken(token: "1234214sdasd")) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let tokenStatus: TokenStatus = try await sut.getFromURL(request.url)

        XCTAssertEqual(tokenStatus.code, 1000)
        XCTAssertEqual(tokenStatus.status, 0)
        XCTAssertFalse(tokenStatus.tokenUsable)
    }

    func test_check_token_status_usable_token() async throws {

        let mockResponse: [String: Any] = [
            "Code": 1000,
            "Status": 1
        ]

        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        guard let request = try? paymentsAPI.url(for: .checkToken(token: "1234214sdasd")) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let tokenStatus: TokenStatus = try await sut.getFromURL(request.url)

        XCTAssertEqual(tokenStatus.code, 1000)
        XCTAssertEqual(tokenStatus.status, 1)
        XCTAssertTrue(tokenStatus.tokenUsable)
    }

    func test_create_payment_token() async throws {

        let mockResponse: [String: Any] = [
            "Code": 1000,
            "Status": 1,
            "Token": "IM_A_TOKEN",
            "Data": NSNull()
        ]

        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let token = Token(amount: 200, currency: "USD", payment: nil, paymentMethodID: nil)
        guard let request = try? paymentsAPI.url(for: .createToken(token: token)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let tokenStatus: NewToken = try await sut.postToURL(request: request)

        XCTAssertEqual(tokenStatus.code, 1000)
        XCTAssertEqual(tokenStatus.status, 1)
        XCTAssertEqual(tokenStatus.token, "IM_A_TOKEN")
    }

    func test_create_payment_token_code_only() async throws {

        let mockResponse: [String: Any] = [
            "Code": 1000,
        ]

        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let token = Token(amount: 200, currency: "USD", payment: nil, paymentMethodID: nil)
        guard let request = try? paymentsAPI.url(for: .createToken(token: token)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let tokenStatus: StatusResponse = try await sut.postToURL(request: request)

        XCTAssertEqual(tokenStatus.code, 1000)
    }

    func test_create_payment_token_no_response() async throws {

        mockRemoteManager.setupURLSessionMock()

        let token = Token(amount: 200, currency: "USD", payment: nil, paymentMethodID: nil)
        guard let request = try? paymentsAPI.url(for: .createToken(token: token)) else {
            XCTFail("Unable to generate the expected request")
            return
        }

        try await sut.postToURL(request: request)
        XCTAssertTrue(true)
    }

    func test_create_payment_token_no_response_fail() async throws {

        let expectedErrorCode = 500

        let token = Token(amount: 200, currency: "USD", payment: nil, paymentMethodID: nil)
        guard let request = try? paymentsAPI.url(for: .createToken(token: token)) else {
            XCTFail("Unable to generate the expected request")
            return
        }

        mockRemoteManager.setupURLSessionMock(urlPath: request.url.absoluteString, responseStatusCode: expectedErrorCode)

        await XCTAssertThrowsErrorAsync(
            try await sut.postToURL(request: request),
            RemoteError.responseReturnedError(errorCode: expectedErrorCode, urlString: request.url.absoluteString)
        )
    }
}

// MARK: Subscription
extension RemoteManagerTests {

    func test_get_current_Subscription() async throws {

        let mockResponse = Bundle.main.loadJsonDataToDic(from: "current_sub_response.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)
        guard let request = try? paymentsAPI.url(for: .getCurrentSubscription) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let currentSub: CurrentSubscription = try await sut.getFromURL(request.url)

        XCTAssertEqual(currentSub.code, 1000)
        XCTAssertEqual(currentSub.upcomingSubscriptions?[0].cycle, 1)
    }

    func test_create_new_Subscription() async throws {

        let mockResponse = Bundle.main.loadJsonDataToDic(from: "new_sub_payload.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let payload = NewSubscription(newValues:
                                        NewSubscriptionValues(
                                            amount: 123,
                                            paymentMethodID: "encrypted-id",
                                            payments: nil,
                                            paymentToken: "payment-token"),
                                      subscription:
                                        Subscription(
                                            cycle: 12,
                                            currency: "USD",
                                            currencyID: 1,
                                            plans: nil,
                                            planIDs: [101, 102],
                                            codes: ["CODE1", "CODE2"],
                                            couponCode: "BUNDLE2022",
                                            giftCode: "123abc"))

        guard let request = try? paymentsAPI.url(for: .createSubscription(newSubscription: payload)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let newSub: NewSubscriptionResponse = try await sut.postToURL(request: request)

        XCTAssertEqual(newSub.code, 1000)
        XCTAssertEqual(newSub.subscription.renew, 1)
        XCTAssertNil(newSub.upcomingSubscriptions)
    }

    func test_cancel_current_subscription() async throws {

        let mockResponse: [String: Any] = [
            "Code": 1000,
        ]

        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let payload = CancelSubscription(reason: "TEMPORARY",
                                         score: 7,
                                         context: "vpn",
                                         feedback: "I need a computer.",
                                         reasonDetails: "I do not have a computer.")

        guard let request = try? paymentsAPI.url(for: .cancelSubscription(cancelSubscription: payload)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let responseStatus: StatusResponse = try await sut.deleteToURL(request: request)

        XCTAssertEqual(responseStatus.code, 1000)
    }

    func test_check_subscription() async throws {

        let mockResponse = Bundle.main.loadJsonDataToDic(from: "check_sub_payload.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let payload = Subscription(cycle: 24,
                                   currency: "USD",
                                   currencyID: 1,
                                   plans: nil,
                                   planIDs: [101, 102],
                                   codes: ["CODE1", "CODE2"],
                                   couponCode: "discountCode",
                                   giftCode: "giftCode")
        guard let request = try? paymentsAPI.url(for: .checkSubscription(subscription: payload)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let subValidationResponse: ValidateSubscriptionResponse = try await sut.postToURL(request: request)

        XCTAssertEqual(subValidationResponse.code, 1000)
        XCTAssertEqual(subValidationResponse.proration, -1448)
        XCTAssertEqual(subValidationResponse.coupon.code, "TEST2022")
    }

    func test_latest_subscription() async throws {
        let mockResponse: [String: Any] = [
            "Code": 1000,
            "LastSubscriptionEnd": 1531519200
        ]
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        guard let request = try? paymentsAPI.url(for: .subscriptionLatest) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let latestSub: LastSubscription = try await sut.getFromURL(request.url)

        XCTAssertEqual(latestSub.code, 1000)
        XCTAssertEqual(latestSub.lastSubscriptionEnd, 1531519200)
    }

    func test_change_renew_subscription() async throws {
        let mockResponse: [String: Any] = [
            "Code": 1000
        ]
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let payload = RenewSubscription(renewalState: 1,
                                        cancellationFeedback: "{\n            \"Reason\":\"QUALITY_ISSUE\",\n            \"Feedback\":\"I need a computer.\",\n            \"ReasonDetails\":\"I am Amish\",\n            \"Context\":\"mail\"\n          }")

        guard let request = try? paymentsAPI.url(for: .changeRenewSubscription(renewSubscription: payload)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let response: StatusResponse = try await sut.putToURL(request: request)

        XCTAssertEqual(response.code, 1000)
    }

    func test_userTransactionUUID() async throws {
        let mockResponse: [String: Any] = [
            "Code": 1000,
            "UUID": "adq2d12dp12od1p2odmp12od"
        ]
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        guard let request = try? paymentsAPI.url(for: .userTransactionUUID) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let userTransactionUUID: UserTransactionUUIDResponse = try await sut.getFromURL(request.url)

        XCTAssertEqual(userTransactionUUID.code, 1000)
        XCTAssertEqual(userTransactionUUID.uuid, "adq2d12dp12od1p2odmp12od")
    }
}

// MARK: Payment Status
extension RemoteManagerTests {

    func test_payment_status() async throws {
        let mockResponse = Bundle.main.loadJsonDataToDic(from: "payment_status_payload.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        guard let request = try? paymentsAPI.url(for: .paymentStatus(vendor: .Apple)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let paymentStatus: PaymentsStatus = try await sut.getFromURL(request.url)
        XCTAssertEqual(paymentStatus.vendorStates.inApp, 1)
        XCTAssertEqual(paymentStatus.vendorStates.bitcoin, 0)
    }
}

extension RemoteManagerTests {

    func test_APIError_code_handling() async throws {
        let mockResponse: [String: Any] = [
            "Code": 5003
        ]
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)

        let payload = RenewSubscription(renewalState: 1,
                                        cancellationFeedback: "dasdas")
        guard let request = try? paymentsAPI.url(for: .changeRenewSubscription(renewSubscription: payload)) else {
            XCTFail("Unable to generate the expected request")
            return
        }

        await XCTAssertThrowsErrorAsync(
            try await sut.putToURL(request: request),
            APICodeError.badAppVersion
        )
    }
}

// MARK: Plans
extension RemoteManagerTests {

    func test_get_available_plans() async throws {
        let mockResponse = Bundle.main.loadJsonDataToDic(from: "availablePlans.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: mockResponse)
        guard let request = try? paymentsAPI.url(for: .availablePlans(currency: "USD", vendor: "Apple", state: 1, timeStamp: 123124)) else {
            XCTFail("Unable to generate the expected request")
            return
        }
        let availablePlans: AvailablePlans = try await sut.getFromURL(request.url)

        XCTAssertEqual(availablePlans.code, 1000)
        XCTAssertEqual(availablePlans.defaultCycle, 12)
        XCTAssertEqual(availablePlans.plans[0].name, "bundle2022")
        XCTAssertEqual(availablePlans.plans[0].instances[0].vendors.apple?.productID, "iosvpn_bundle2022_12_usd_auto_renewing")
        XCTAssertEqual(availablePlans.plans[0].id, "6QeHIh44j9R3b8kckYBHvp84UGeLt3yliLxZWhqVULXfuSNRDRwULijb5e4kpr5wvfluBXmtyCHWe0nYweWRpg==")
    }
}
