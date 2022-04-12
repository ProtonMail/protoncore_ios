//
//  ServicePlanDetailsTests.swift
//  ProtonCore-Payments-Tests - Created on 21/12/2020.
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

import ProtonCore_TestingToolkit
@testable import ProtonCore_Payments

final class ServicePlanDetailsTests: XCTestCase {

    lazy var plus = Plan(name: "plus",
                         iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                         maxAddresses: 5,
                         maxMembers: 1,
                         pricing: ["12": 4800, "24": 7900, "1": 500],
                         maxDomains: 1,
                         maxSpace: 5368709120,
                         maxRewardsSpace: nil,
                         type: 1,
                         title: "Proton Mail Plus",
                         maxVPN: 0,
                         maxTier: 0,
                         features: 0,
                         maxCalendars: nil,
                         state: nil,
                         cycle: 12)

    lazy var pro = Plan(name: "professional",
                        iD: "R0wqZrMt5moWXl_KqI7ofCVzgV0cinuz-dHPmlsDJjwoQlu6_HxXmmHx94rNJC1cNeultZoeFr7RLrQQCBaxcA==",
                        maxAddresses: 10,
                        maxMembers: 1,
                        pricing: ["24": 12900, "1": 800, "12": 7500],
                        maxDomains: 2,
                        maxSpace: 5368709120,
                        maxRewardsSpace: nil,
                        type: 1,
                        title: "Proton Mail Professional",
                        maxVPN: 0,
                        maxTier: 0,
                        features: 1,
                        maxCalendars: nil,
                        state: nil,
                        cycle: 12)

    lazy var address5 = Plan(name: "5address",
                             iD: "BzHqSTaqcpjIY9SncE5s7FpjBrPjiGOucCyJmwA6x4nTNqlElfKvCQFr9xUa2KgQxAiHv4oQQmAkcA56s3ZiGQ==",
                             maxAddresses: 5,
                             maxMembers: 0,
                             pricing: nil,
                             maxDomains: 0,
                             maxSpace: 0,
                             maxRewardsSpace: nil,
                             type: 0,
                             title: "+5 Addresses",
                             maxVPN: 0,
                             maxTier: nil,
                             features: 1,
                             maxCalendars: nil,
                             state: nil,
                             cycle: 12)

    func testDecode() {
        let servicePlans = ServicePlansMock()
        guard let data = servicePlans.plansAnswer.data(using: .utf8),
              let dictionary = ((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) as [String: Any]??) else
        {
            XCTAssertTrue(false, "Failed to serialize mock data")
            return
        }

        let parser = PlansResponse()
        XCTAssertTrue(parser.ParseResponse(dictionary), "Failed to parse plans list")

        let plans: [Plan]? = parser.availableServicePlans
        XCTAssertNotNil(plans, "Failed to parse plans list")
        XCTAssertFalse(plans!.isEmpty, "Failed to parse plans list")

        // no id arrived
        let plus = plans?.first(where: { $0.name == "plus" })
        XCTAssertEqual(plus, self.plus)

        // everything good
        let pro = plans?.first(where: { $0.name == "professional" })
        XCTAssertEqual(pro, self.pro)
    }

    func testSubscription() {
        let subscription = Subscription(start: .distantPast,
                                        end: .distantFuture,
                                        planDetails: [self.address5, self.pro],
                                        amount: nil,
                                        currency: nil)

        XCTAssertEqual(subscription.planDetails, [self.address5, self.pro])
        XCTAssertEqual(subscription.computedPresentationDetails(shownPlanNames: ["professional"]), Plan.combineDetailsDroppingPricing([self.address5, self.pro]))
    }
}
