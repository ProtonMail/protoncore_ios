//
//  ServicePlanDataService.swift
//  ProtonCore-Payments - Created on 17/08/2018.
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

import PromiseKit

extension ServicePlanDataServiceProtocol {
    
    @available(*, deprecated, message: "ProtonCore is moving away from PromiseKit. Please switch to other available APIs")
    func updateServicePlans() -> Promise<Void> {
        Promise { seal in
            updateServicePlans {
                seal.fulfill(())
            } failure: { error in
                seal.reject(error)
            }
        }
    }
    
    @available(*, deprecated, message: "ProtonCore is moving away from PromiseKit. Please switch to other available APIs")
    func updateCurrentSubscription(updateCredits: Bool) -> Promise<Void> {
        Promise { seal in
            updateCurrentSubscription(updateCredits: updateCredits) {
                seal.fulfill(())
            } failure: { error in
                seal.reject(error)
            }
        }
    }
}
