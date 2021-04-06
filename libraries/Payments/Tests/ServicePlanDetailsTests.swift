//
//  ServicePlanDetailsTests.swift
//  ProtonCore-Payments-Tests - Created on 21/12/2020.
//
//  Copyright (c) 2020 Proton Technologies AG
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

@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class ServicePlanDetailsTests: XCTestCase {
    
    lazy var plus = ServicePlanDetails(features: 0,
                                       iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                                       maxAddresses: 5,
                                       maxDomains: 1,
                                       maxMembers: 1,
                                       maxSpace: 5368709120,
                                       maxVPN: 0,
                                       name: "plus",
                                       quantity: 1,
                                       services: 1,
                                       title: "ProtonMail Plus",
                                       type: 1)
    lazy var pro = ServicePlanDetails(features: 1,
                                       iD: "rDox3cZuqa4_sMMlxcVZg8pCaUQsMN3IrOLk9kBtO8tZ6t8hiqFwCRIAM09A8U9a0HNNlrTgr8CzXKce58815A==",
                                       maxAddresses: 10,
                                       maxDomains: 2,
                                       maxMembers: 1,
                                       maxSpace: 5368709120,
                                       maxVPN: 0,
                                       name: "professional",
                                       quantity: 1,
                                       services: 1,
                                       title: "ProtonMail Professional",
                                       type: 1)
    lazy var address5 = ServicePlanDetails(features: 1,
                                      iD: "BzHqSTaqcpjIY9SncE5s7FpjBrPjiGOucCyJmwA6x4nTNqlElfKvCQFr9xUa2KgQxAiHv4oQQmAkcA56s3ZiGQ==",
                                      maxAddresses: 5,
                                      maxDomains: 0,
                                      maxMembers: 0,
                                      maxSpace: 0,
                                      maxVPN: 0,
                                      name: "5address",
                                      quantity: 1,
                                      services: 1,
                                      title: "+5 Addresses",
                                      type: 0)

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
        
        let plans: [ServicePlanDetails]? = parser.availableServicePlans
        XCTAssertNotNil(plans, "Failed to parse plans list")
        XCTAssertFalse(plans!.isEmpty, "Failed to parse plans list")
        
        // no id arrived
        let plus = plans?.first(where: { $0.name == "plus" })
        XCTAssertEqual(plus, self.plus)
        
        // everything good
        let pro = plans?.first(where: { $0.name == "professional" })
        XCTAssertEqual(pro, self.pro)
    }
    
    func testMerge() {
        // TODO: when merge logic will be implemented
    }
    
    func testSubscription() {
        let subscription = ServicePlanSubscription(start: .distantPast,
                                        end: .distantFuture,
                                        planDetails: [self.address5, self.pro],
                                        defaultPlanDetails: nil,
                                        paymentMethods: [.init(iD: "424242", type: .card)])
        
        XCTAssertEqual(subscription.plans, [.pro])
        XCTAssertEqual(subscription.details, [self.address5, self.pro].merge())
        XCTAssertTrue(subscription.hadOnlinePayments)
    }
}
