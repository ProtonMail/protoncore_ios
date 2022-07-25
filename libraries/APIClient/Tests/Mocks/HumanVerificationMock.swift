//
//  HumanVerificationAPITests.swift
//  ProtonCore-APIClient-Tests - Created on 16/11/20.
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

import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_APIClient

class HumanCheckHelperMock: HumanVerifyDelegate {
    fileprivate let resultSuccess: Bool
    fileprivate let resultHeaders: [[String: Any]]?
    fileprivate let delay: TimeInterval
    fileprivate let resultClosure: ((@escaping(Bool) -> Void) -> Void)?
    
    var version: HumanVerificationVersion = .v3
    
    init(apiService: APIService, resultSuccess: Bool, resultHeaders: [[String: Any]]? = nil, delay: TimeInterval = 0, resultClosure: ((@escaping(Bool) -> Void) -> Void)? = nil) {
        self.resultSuccess = resultSuccess
        self.resultHeaders = resultHeaders
        self.delay = delay
        self.resultClosure = resultClosure
    }

    func onHumanVerify(parameters: HumanVerifyParameters, currentURL: URL?, completion: (@escaping (HumanVerifyFinishReason) -> Void)) {
        let verificationBlock: SendVerificationCodeBlock = { (res, error, finish) in
           finish?()
        }
        
        func execute() {
            if resultSuccess {
                if let resultHeaders = resultHeaders {
                    var index = 0.0
                    resultHeaders.forEach { header in
                        index += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay * index) {
                            completion(.verification(header: header, verificationCodeBlock: verificationBlock))
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    completion(.close)
                }
            }
        }
        
        if let resultClosure = resultClosure {
            resultClosure({ res in
                if res == true {
                    execute()
                }
            })
        } else {
            execute()
        }
    }
    
    func getSupportURL() -> URL {
        return URL(string: "www.protonmail.com")!
    }
}
