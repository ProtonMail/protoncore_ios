//
//  APIServiceRequest.swift
//  ProtonCore-APIClient - Created on 6/18/15.
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

// swiftlint:disable identifier_name todo

import Foundation
import PromiseKit
import AwaitKit
import ProtonCore_Networking
import ProtonCore_Services

@available(*, deprecated, message: "this will be removed. use `APIService` for api requests")
extension ApiRequestNew {

    @available(*, deprecated, message: "ProtonCore is moving away from PromiseKit. Please switch to other available APIs")
    open func run() -> Promise<T> {
        // 1 make a request , 2 wait for the respons async 3. valid response 4. parse data into response 5. some data need save into database.
        let deferred = Promise<T>.pending()
        let completionWrapper: CompletionBlock = { task, responseDict, error in

            switch T.parseNetworkCallResults(to: T.self, response: task?.response, responseDict: responseDict, error: error) {
            case (_, let networkingError?):
                deferred.resolver.reject(networkingError)
            case (let response, nil):
                deferred.resolver.fulfill(response)
            }
        }

        // TODO:: missing auth
        apiService.request(method: self.method(), path: self.path(),
                           parameters: self.toDictionary(), headers: [:],
                           authenticated: self.getIsAuthFunction(), autoRetry: self.authRetry(),
                           customAuthCredential: self.authCredential, completion: completionWrapper)

        return deferred.promise

    }
}
