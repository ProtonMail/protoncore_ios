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

import ProtonCore_Doh

struct CreatedAccountDetails {
    let details: String
    let id: String
    let account: AccountAvailableForCreation
}

enum CreateAccountError: Error {
    case cannotConstuctUrl
    case cannotDecodeResponseBody
    case cannotFindAccountDetailsInResponseBody
    case actualError(Error)
    
    var messageForTheUser: String {
        switch self {
        case .cannotConstuctUrl: return "cannot construct url"
        case .cannotDecodeResponseBody: return "cannot decode response body"
        case .cannotFindAccountDetailsInResponseBody: return "cannot find account details in response body"
        case .actualError(let error): return "actual error: \(error.messageForTheUser)"
        }
    }
}

func create(account: AccountAvailableForCreation,
            doh: DoH & ServerConfig,
            completion: @escaping (Result<CreatedAccountDetails, CreateAccountError>) -> Void) {
    var urlString = "\(doh.getCurrentlyUsedHostUrl())/internal/quark/user:create?-N=\(account.username)&-p=\(account.password)"
    if let mailboxPassword = account.mailboxPassword { urlString.append("&-m=\(mailboxPassword)") }
    
    guard let url = URL(string: urlString) else { completion(.failure(.cannotConstuctUrl)); return }
    
    let completion: (Result<CreatedAccountDetails, CreateAccountError>) -> Void = { result in
        DispatchQueue.main.async { completion(result) }
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, let input = String(data: data, encoding: .utf8) else {
            guard let error = error else { completion(.failure(.cannotDecodeResponseBody)); return }
            completion(.failure(.actualError(error)))
            return
        }
        
        let detailsRegex = "\\s?ID\\s\\(decrypt\\):[\\s\\S]*</span>"
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

