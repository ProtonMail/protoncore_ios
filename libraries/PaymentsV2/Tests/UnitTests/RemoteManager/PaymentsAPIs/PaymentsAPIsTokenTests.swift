//
//  PaymentsAPIsTokenTests.swift
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

final class PaymentsAPIsTokenTests: XCTestCase {

    var sut: PaymentsAPIs!
    var doh = PaymentsDoH()

    override func setUp() {
        super.setUp()
        sut = PaymentsAPIs(doh: doh)
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    private func validateJsonBody(expectedJSON: [String: Any], testBodyJSON: [String: Any]?) {

        guard let requestBody = testBodyJSON else {
            return
        }

        let payload = try? JSONSerialization.data(withJSONObject: requestBody)
        let jsonPayload = try? JSONSerialization.jsonObject(with: payload!)

        guard let test = jsonPayload as? [String: Any] else {
            return
        }

        XCTAssertTrue(NSDictionary(dictionary: test).isEqual(to: expectedJSON))
    }

    // MARK: Token
    func test_createToken() throws {

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/tokens") else {
            return
        }

        let expectedToken = Token(amount: 100,
                                  currency: "EUR",
                                  payment: PaymentReceipt(details:
                                                            ReceiptDetails(bundleID: "bundle",
                                                                           productID: "123asd",
                                                                           receipt: "22211sd",
                                                                           transactionID: "778787"),
                                                          type: "apple-recurring"),
                                  paymentMethodID: nil)

        let expectedJSONBody: [String: Any] = [
            "Amount": 100,
            "Currency": "EUR",
            "Payment": [
                "Details": [
                    "BundleID": "bundle",
                    "ProductID": "123asd",
                    "Receipt": "22211sd",
                    "TransactionID": "778787",
                ],
                "Type": "apple-recurring"
            ],
            "PaymentMethodID": NSNull()
        ]

        let result = try? sut.url(for: .createToken(token: expectedToken))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        validateJsonBody(expectedJSON: expectedJSONBody, testBodyJSON: result?.body)
    }

    func test_checkToken() throws {

        let expectedToken = "asdaskdlo12je9120e9dj1029djaosdj0129dj0"
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/tokens/\(expectedToken)") else {
            return
        }

        let result = try? sut.url(for: .checkToken(token: expectedToken))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }

    // MARK: Subscriptions
    func test_createSubscription() throws {

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription") else {
            return
        }

        let expectedJSONBody: [String: Any] = [
            "Cycle": 24,
            "Currency": "USD",
            "CurrencyID": 1,
            "Plans": NSNull(),
            "PlanIDs": [101, 102],
            "Codes": ["CODE1", "CODE2"],
            "CouponCode": "discountCode",
            "GiftCode": "giftCode",
            "Amount": 2,
            "PaymentMethodID": NSNull(),
            "Payments": NSNull(),
            "PaymentToken": NSNull()
        ]

        let newSub = NewSubscription(newValues: NewSubscriptionValues(amount: 2,
                                                                      paymentMethodID: nil,
                                                                      payments: nil,
                                                                      paymentToken: nil),
                                     subscription: Subscription(cycle: 24,
                                                                currency: "USD",
                                                                currencyID: 1,
                                                                plans: nil,
                                                                planIDs: [101, 102],
                                                                codes: ["CODE1", "CODE2"],
                                                                couponCode: "discountCode",
                                                                giftCode: "giftCode"))

        let result = try? sut.url(for: .createSubscription(newSubscription: newSub))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        validateJsonBody(expectedJSON: expectedJSONBody, testBodyJSON: result?.body)
    }

    func test_checkSubscription() throws {

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription/check") else {
            return
        }

        let expectedJSONBody: [String: Any] = [
            "Cycle": 24,
            "Currency": "USD",
            "CurrencyID": 1,
            "Plans": NSNull(),
            "PlanIDs": [101, 102],
            "Codes": ["CODE1", "CODE2"],
            "CouponCode": "discountCode",
            "GiftCode": "giftCode"
        ]

        let subscription = Subscription(cycle: 24,
                                        currency: "USD",
                                        currencyID: 1,
                                        plans: nil,
                                        planIDs: [101, 102],
                                        codes: ["CODE1", "CODE2"],
                                        couponCode: "discountCode",
                                        giftCode: "giftCode")

        let result = try? sut.url(for: .checkSubscription(subscription: subscription))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        validateJsonBody(expectedJSON: expectedJSONBody, testBodyJSON: result?.body)
    }

    func test_subscription_latest() throws {

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription/latest") else {
            return
        }
        let result = try? sut.url(for: .subscriptionLatest)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }

    func test_change_renew_subscription() throws {

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription/renew") else {
            return
        }

        let expectedJSONBody: [String: Any] = [
            "RenewalState": 2,
            "CancellationFeedback": NSNull()
        ]

        let renewSub = RenewSubscription(renewalState: 2,
                                         cancellationFeedback: nil)

        let result = try? sut.url(for: .changeRenewSubscription(renewSubscription: renewSub))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        validateJsonBody(expectedJSON: expectedJSONBody, testBodyJSON: result?.body)
    }

    // MARK: Payments
    func test_payment_status() throws {

        let vendor = "Apple"
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/status/\(vendor)") else {
            return
        }

        let result = try? sut.url(for: .paymentStatus(vendor: .Apple))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }

    // MARK: Plans
    func test_availablePlans() throws {

        let expectedQuery = "plans?Currency=USD&State=1&Timestamp=123124&Vendor=Apple"

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/\(expectedQuery)") else {
            return
        }

        let result = try? sut.url(for: .availablePlans(currency: "USD", vendor: "Apple", state: 1, timeStamp: 123124))

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }

    // MARK: Transaction UUID

    func test_transactionUUID() throws {

        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/auth/v4/sessions/uuid") else {
            return
        }
        let result = try? sut.url(for: .userTransactionUUID)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }
}
