//
//  AvailablePlan+Fixture.swift
//  ProtonCore-TestingToolkit - Created on 07/09/2023.
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


public extension AvailablePlans.AvailablePlan {
    static var dummy: AvailablePlans.AvailablePlan {
        AvailablePlans.AvailablePlan(ID: .empty,
                                     type: nil,
                                     name: .empty,
                                     title: .empty,
                                     description: .empty,
                                     instances: [],
                                     entitlements: [],
                                     decorations: [])
    }
    func updated(ID: String? = nil,
                 type: Int? = nil,
                 name: String? = nil,
                 title: String? = nil,
                 description: String? = nil,
                 instances: [Instance]? = nil,
                 entitlements: [Entitlement]? = nil,
                 decorations: [Decoration]? = nil) -> AvailablePlans.AvailablePlan {
        AvailablePlans.AvailablePlan(ID: ID ?? self.ID,
                                     type: type ?? self.type,
                                     name: name ?? self.name,
                                     title: title ?? self.title,
                                     description: description ?? self.description,
                                     instances: instances ?? self.instances,
                                     entitlements: entitlements ?? self.entitlements,
                                     decorations: decorations ?? self.decorations)
    }
    
}

