//
//  PlansData.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import ProtonCore_Payments
@testable import ProtonCore_PaymentsUI
@testable import ProtonCore_TestingToolkit

class PlansData {

    static func planFree(isSelectable: Bool = true, title: PlanTitle = .price(nil)) -> Plan {
        return Plan(
            name: "Free",
            title: title,
            details: [
                "1 user",
                "500 MB storage",
                "1 address"],
            isSelectable: isSelectable,
            endDate: nil,
            accountPlan: .free)
    }

    static func planPlus(isSelectable: Bool = true, endDateString: String? = nil, title: PlanTitle = .price("$60.00")) -> Plan {
        return Plan(
            name: "Plus",
            title: title,
            details: [
                "1 user",
                "5 GB storage *",
                "5 addresses",
                "Unlimited folders / labels / filters",
                "Custom email addresses"],
            isSelectable: isSelectable,
            endDate: endDateString == nil ? nil : NSAttributedString(string: endDateString!),
            accountPlan: .mailPlus)
    }
    
    static func planPro(endDateString: String? = nil, title: PlanTitle = .price(nil)) -> Plan {
        return Plan(
            name: "Professional",
            title: title,
            details: [
                "1 user",
                "5 GB storage *",
                "10 addresses",
                "Unlimited folders / labels / filters",
                "Custom email addresses"],
            isSelectable: false,
            endDate: endDateString == nil ? nil : NSAttributedString(string: endDateString!),
            accountPlan: .pro)
    }
    
    static func planVisionary(endDateString: String? = nil, title: PlanTitle = .price(nil)) -> Plan {
        return Plan(
            name: "Visionary",
            title: title,
            details: [
                "6 users",
                "20 GB storage *",
                "50 addresses",
                "Unlimited folders / labels / filters",
                "Custom email addresses"],
            isSelectable: false,
            endDate: endDateString == nil ? nil : NSAttributedString(string: endDateString!),
            accountPlan: .visionary)
    }
    
    struct DateData {
        let endDate: TimeInterval
        let endDateString: String
    }
    
    static func getEndDate(paymentsApiMock: PaymentsApiMock, component: Calendar.Component, value: Int) -> DateData {
        let today = Date()
        let date = Calendar.current.date(byAdding: component, value: value, to: today)!
        let timeInterval = TimeInterval(UInt(date.timeIntervalSince1970))
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus(periodEnd: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let endDateString = dateFormatter.string(from: date)
        return DateData(endDate: timeInterval, endDateString: endDateString)
    }
}

extension Plan: Equatable {
    public static func == (lhs: Plan, rhs: Plan) -> Bool {
        lhs.title == rhs.title
            && lhs.isSelectable == rhs.isSelectable
            && lhs.accountPlan == rhs.accountPlan
            && lhs.details == rhs.details
            && lhs.name == rhs.name
            && lhs.endDate?.string == rhs.endDate?.string
    }
}
