//
//  CreateUserAPI.swift
//  ExampleApp - Created on 11/12/2021.
//  
//  Copyright (c) 2021 Proton Technologies AG
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

import ProtonCore_Log

public struct CreatedAccountDetails {
    public let details: String
    public let id: String
    public let account: AccountAvailableForCreation
}

public enum CreateAccountError: Error {
    case cannotConstructUrl
    case cannotDecodeResponseBody
    case cannotFindAccountDetailsInResponseBody
    case actualError(Error)
    
    public var userFacingMessageInQuarkCommands: String {
        switch self {
        case .cannotConstructUrl: return "cannot construct url"
        case .cannotDecodeResponseBody: return "cannot decode response body"
        case .cannotFindAccountDetailsInResponseBody: return "cannot find account details in response body"
        case .actualError(let error): return "actual error: \(error.messageForTheUser)"
        }
    }
}

extension QuarkCommands {
    static public func create(account: AccountAvailableForCreation,
                              currentlyUsedHostUrl host: String,
                              callCompletionBlockOn: DispatchQueue = .main,
                              completion: @escaping (Result<CreatedAccountDetails, CreateAccountError>) -> Void) {
        
        var urlString: String
        switch account.type {
        case .free:
            urlString = "\(host)/internal/quark/user:create?-N=\(account.username)&-p=\(account.password)"
        case .subuser(let alsoPublic):
            urlString = "\(host)/internal/quark/user:create:subuser?-N=\(account.username)&-p=\(account.password)&--private=\(alsoPublic ? 0 : 1)&ownerUserID=787&ownerPassword=a"
        case .plan(let protonPlanName):
            urlString = "/internal/quark/payments:seed-delinquent?username=\(account.username)&password=\(account.password)&plan=\(protonPlanName)&cycle=12"
        }
        
        if let mailboxPassword = account.mailboxPassword { urlString.append("&-m=\(mailboxPassword)") }
        
        switch account.address {
        case .noAddress:
            break
        case .addressButNoKeys:
            urlString.append("&--create-address=null")
        case .addressWithKeys:
            urlString.append("&-k=Curve25519")
        }
        
        guard let url = URL(string: urlString) else { completion(.failure(.cannotConstructUrl)); return }
        
        let completion: (Result<CreatedAccountDetails, CreateAccountError>) -> Void = { result in
            callCompletionBlockOn.async { completion(result) }
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let input = String(data: data, encoding: .utf8) else {
                guard let error = error else { completion(.failure(.cannotDecodeResponseBody)); return }
                completion(.failure(.actualError(error)))
                return
            }
            
            let detailsRegex = "\\s?ID.*:[\\s\\S]*</span>"
            guard let detailsRange = input.range(of: detailsRegex, options: .regularExpression) else {
                print(input)
                completion(.failure(.cannotFindAccountDetailsInResponseBody)); return
            }
            let detailsString = input[detailsRange].dropLast(7)

            guard let idRange = detailsString.range(of: "ID:\\s.*", options: .regularExpression) else {
                print(input)
                completion(.failure(.cannotFindAccountDetailsInResponseBody)); return
            }
            let idString = detailsString[idRange].dropFirst(4)

            let created = CreatedAccountDetails(details: String(detailsString), id: String(idString), account: account)
            completion(.success(created))
        }.resume()
    }
    
}

@available(*, deprecated, message: "Use asynchronous variant: create(account:currentlyUsedHostUrl:completion:)")
public func createVPNUser(host: String, username: String, password: String) -> (username: String, password: String) {
    createUser(accountType: .freeNoAddressNoKeys, currentlyUsedHostUrl: host)
}

@available(*, deprecated, message: "Use asynchronous variant: create(account:currentlyUsedHostUrl:completion:)")
public func createUserWithAddressNoKeys(host: String, username: String, password: String) -> (username: String, password: String) {
    createUser(accountType: .freeWithAddressAndKeys, currentlyUsedHostUrl: host)
}

@available(*, deprecated, message: "Use asynchronous variant: create(account:currentlyUsedHostUrl:completion:)")
public func createOrgUser(host: String, username: String, password: String, createPrivateUser: Bool) -> (username: String, password: String) {
    createUser(accountType: .subuserPublic, currentlyUsedHostUrl: host)
}

private func createUser(accountType: AccountAvailableForCreation, currentlyUsedHostUrl: String) -> (username: String, password: String) {
    let semaphore = DispatchSemaphore(value: 0)
    var result: (username: String, password: String) = ("user was not created, quark command failed", "")
    QuarkCommands.create(account: accountType,
                         currentlyUsedHostUrl: currentlyUsedHostUrl,
                         callCompletionBlockOn: .global(qos: .userInitiated)) { completion in
        switch completion {
        case .failure: break
        case .success(let details): result = (username: details.account.username, details.account.password)
        }
        semaphore.signal()
    }
    semaphore.wait()
    return result
}
