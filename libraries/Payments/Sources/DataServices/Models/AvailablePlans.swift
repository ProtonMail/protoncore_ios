//
//  AvailablePlans.swift
//  ProtonCorePayments - Created on 13.07.23.
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

public struct AvailablePlans: Codable, Equatable {
    var code: Int
    var plans: [AvailablePlan]
    
    public struct AvailablePlan: Codable, Equatable {
        var instances: [Instance]
        var type: Int
        var name: String
        var title: String
        var state: Int
        var entitlements: [Entitlements]
        var offers: [Offer]?
        var decorations: [Decoration]
        
        public struct Instance: Codable, Equatable {
            var month: Int
            var ID: String
            var description: String
            var periodEnd: Int
            var price: [Price]
            var vendors: Vendors?
            
            struct Price: Codable, Equatable {
                var currency: String
                var current: Int
                var `default`: Int
            }
            
            struct Vendors: Codable, Equatable {
                var google: Vendor
                var apple: Vendor
                
                struct Vendor: Codable, Equatable {
                    var ID: String
                    var customerID: String
                }
            }
        }
        
        struct Entitlements: Codable, Equatable {
            var type: String
            var text: String
            var icon: String
            var hint: String?
        }
        
        struct Offer: Codable, Equatable {
            var name: String
            var startTime: Int
            var endTime: Int
            var months: Int
            var price: [Price]
            
            struct Price: Codable, Equatable {
                var currency: String
                var current: Int
            }
        }
        
        struct Decoration: Codable, Equatable {
            var type: String
            var icon: String?
            var color: String?
        }
    }
}
