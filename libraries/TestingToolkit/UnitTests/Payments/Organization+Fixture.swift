//
//  Organization+Fixture.swift
//  ProtonCore-TestingToolkit - Created on 09/09/2021.
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

import Foundation
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import ProtonCorePayments

public extension Organization {
    static var dummy: Organization {
        Organization(maxDomains: .zero, maxAddresses: .zero, maxSpace: .zero,
                     maxMembers: .zero, maxVPN: .zero, maxCalendars: nil, usedDomains: .zero, usedAddresses: .zero, usedSpace: .zero, usedMembers: .zero, usedCalendars: .zero)

    }

    func updated(maxDomains: Int? = nil,
                 maxAddresses: Int? = nil,
                 maxSpace: Int64? = nil,
                 maxMembers: Int? = nil,
                 maxVPN: Int? = nil,
                 maxCalendars: Int? = nil,
                 usedDomains: Int?,
                 usedAddresses: Int?,
                 usedSpace: Int64?,
                 usedMembers: Int?,
                 usedCalendars: Int?) -> Organization {

        Organization(maxDomains: maxDomains ?? self.maxDomains,
                     maxAddresses: maxAddresses ?? self.maxAddresses,
                     maxSpace: maxSpace ?? self.maxSpace,
                     maxMembers: maxMembers ?? self.maxMembers,
                     maxVPN: maxVPN ?? self.maxVPN,
                     maxCalendars: maxCalendars ?? self.maxCalendars,
                     usedDomains: usedDomains ?? self.usedDomains,
                     usedAddresses: usedAddresses ?? self.usedAddresses,
                     usedSpace: usedSpace ?? self.usedSpace,
                     usedMembers: usedMembers ?? self.usedMembers,
                     usedCalendars: usedCalendars ?? self.usedCalendars)

    }
}
