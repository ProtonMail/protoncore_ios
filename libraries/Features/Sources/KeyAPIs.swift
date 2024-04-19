//
//  KeyAPIs.swift
//  ProtonCore-Features - Created on 08.03.2021.
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
import ProtonCoreCryptoGoInterface
import ProtonCoreDataModel
import ProtonCoreKeyManager
import ProtonCoreNetworking
import ProtonCoreServices

extension Array where Element: Request {
    func performConcurrentlyAndWaitForResults<T: Response>(api: APIService, response: T.Type) -> [Result<T, Error>] {

        assert(Thread.isMainThread == false, "This is a blocking call, should never be called from the main thread")

        let group = DispatchGroup()

        var results: [(UUID, Result<T, Error>)] = []
        let requests = map { (UUID(), $0) }
        let uuids = requests.map(\.0)
        requests.forEach { uuid, request in
            let responseObject: T = T()
            group.enter()
            api.perform(request: request, response: responseObject) { (_, response: T) in
                if let responseError = response.error {
                    results.append((uuid, .failure(responseError)))
                } else {
                    results.append((uuid, .success(response)))
                }
                group.leave()
            }
        }
        group.wait()

        return results.sorted { lhs, rhs in
            guard let lhIndex = uuids.firstIndex(of: lhs.0), let rhIndex = uuids.firstIndex(of: rhs.0) else {
                assertionFailure("Should never happen — the UUIDs associated with requests must not be changed")
                return true
            }
            return lhIndex < rhIndex
        }.map { $0.1 }
    }
}
