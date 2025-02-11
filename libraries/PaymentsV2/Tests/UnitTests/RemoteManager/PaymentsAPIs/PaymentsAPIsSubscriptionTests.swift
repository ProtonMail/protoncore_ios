//
//  PaymentsAPIsSubscriptionTests.swift
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

final class PaymentsAPIsSubscriptionTests: XCTestCase {

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

    private func assertPayload(expectedPayload: [String: Any], generatedPayload: Any?) {
        guard let test = generatedPayload as? [String: Any] else {
            XCTFail("unable to convert generatedPayload to dictionary")
            return
        }

        XCTAssertTrue(NSDictionary(dictionary: test).isEqual(to: expectedPayload))
    }

    // MARK: Tests
    func testGetCurrentSubscriptionRequest() throws {
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription") else {
            return
        }

        let result = try? sut.url(for: .getCurrentSubscription)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }

    func testCancelSubscriptionRequest() throws {
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription") else {
            return
        }

        let cancelSubscription = CancelSubscription(reason: "I want to live on the edge",
                                                    score: 10,
                                                    context: "VPN",
                                                    feedback: "I love the product!",
                                                    reasonDetails: "I want to risk my e-ID")
        let expectedJSONBody: [String: Any] = [
            "Reason": "I want to live on the edge",
            "Score": 10,
            "Context": "VPN",
            "Feedback": "I love the product!",
            "ReasonDetails": "I want to risk my e-ID"
        ]

        let result = try? sut.url(for: .cancelSubscription(cancelSubscription: cancelSubscription))
        let payload = try? JSONSerialization.data(withJSONObject: result!.body!)
        let jsonPayload = try? JSONSerialization.jsonObject(with: payload!)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        assertPayload(expectedPayload: expectedJSONBody, generatedPayload: jsonPayload)
    }

    func testCreateNewSubscription() throws {
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription") else {
            return
        }

        let newSub = NewSubscription(newValues: NewSubscriptionValues(amount: 1500,
                                                                      paymentMethodID: "adoj-id",
                                                                      payments: nil,
                                                                      paymentToken: "payment-token"),
                                     subscription: Subscription(cycle: 24,
                                                                currency: "USD",
                                                                currencyID: 1,
                                                                plans: ["mail2022": 1],
                                                                planIDs: [100, 101],
                                                                codes: ["CODE1", "CODE2"],
                                                                couponCode: "BUNDLE2022",
                                                                giftCode: "123abc"))

        let expectedJSONBody: [String: Any] = [
            "Amount": 1500,
            "PaymentMethodID": "adoj-id",
            "Payments": NSNull(),
            "PaymentToken": "payment-token",
            "Cycle": 24,
            "Currency": "USD",
            "CurrencyID": 1,
            "Plans": ["mail2022": 1],
            "PlanIDs": [100, 101],
            "Codes": ["CODE1", "CODE2"],
            "CouponCode": "BUNDLE2022",
            "GiftCode": "123abc"
        ]

        let result = try? sut.url(for: .createSubscription(newSubscription: newSub))
        let payload = try? JSONSerialization.data(withJSONObject: result!.body!)
        let jsonPayload = try? JSONSerialization.jsonObject(with: payload!)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        assertPayload(expectedPayload: expectedJSONBody, generatedPayload: jsonPayload)
    }

    func testCheckSubscriptionRequest() throws {
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription/check") else {
            return
        }

        let subscription = Subscription(cycle: 24,
                                        currency: "USD",
                                        currencyID: 1,
                                        plans: nil,
                                        planIDs: [100, 101],
                                        codes: ["CODE1", "CODE2"],
                                        couponCode: "BUNDLE2022",
                                        giftCode: "123abc")

        let expectedJSONBody: [String: Any] = [
            "Cycle": 24,
            "Currency": "USD",
            "CurrencyID": 1,
            "Plans": NSNull(),
            "PlanIDs": [100, 101],
            "Codes": ["CODE1", "CODE2"],
            "CouponCode": "BUNDLE2022",
            "GiftCode": "123abc"
        ]

        let result = try? sut.url(for: .checkSubscription(subscription: subscription))
        let payload = try? JSONSerialization.data(withJSONObject: result!.body!)
        let jsonPayload = try? JSONSerialization.jsonObject(with: payload!)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        assertPayload(expectedPayload: expectedJSONBody, generatedPayload: jsonPayload)
    }

    func testRenewSubscriptionRequest() throws {
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription/renew") else {
            return
        }

        let renewSub = RenewSubscription(renewalState: 2,
                                         cancellationFeedback: "{\n            \"Reason\":\"QUALITY_ISSUE\",\n            \"Feedback\":\"I need a computer.\",\n            \"ReasonDetails\":\"I am Amish\",\n            \"Context\":\"mail\"\n          }")

        let expectedJSONBody: [String: Any] = [
            "RenewalState": 2,
            "CancellationFeedback": "{\n            \"Reason\":\"QUALITY_ISSUE\",\n            \"Feedback\":\"I need a computer.\",\n            \"ReasonDetails\":\"I am Amish\",\n            \"Context\":\"mail\"\n          }"
        ]

        let result = try? sut.url(for: .changeRenewSubscription(renewSubscription: renewSub))
        let payload = try? JSONSerialization.data(withJSONObject: result!.body!)
        let jsonPayload = try? JSONSerialization.jsonObject(with: payload!)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNotNil(result?.body)
        assertPayload(expectedPayload: expectedJSONBody, generatedPayload: jsonPayload)
    }

    func testSubscriptionLatestRequest() throws {
        guard let expectedResult = URL(string: doh.getCurrentlyUsedHostUrl() + "/payments/v5/subscription/latest") else {
            return
        }

        let result = try? sut.url(for: .subscriptionLatest)

        XCTAssertEqual(expectedResult, result?.url)
        XCTAssertNil(result?.body)
    }
}
