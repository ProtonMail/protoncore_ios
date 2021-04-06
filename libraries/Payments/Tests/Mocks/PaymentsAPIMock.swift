//
//  PaymentsApiMock.swift
//  ProtonCore-Payments-Tests - Created on 16/03/2021.
//
//  Copyright (c) 2020 Proton Technologies AG
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
import OHHTTPStubs
import AwaitKit
import StoreKit

import ProtonCore_DataModel
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_Payments

class PaymentsApiMock: PaymentsApiImplementation {
    private let servicePlansMock = ServicePlansMock()
    
    let hostName = "test.xyz"
    var subscriptionRequestAnswer: SubscriptionRequestAnswer = .free
    var creditAnswer: CreditAnswer = .success
    var tokenAnswer: TokenAnswer = .success
    var tokenStatusAnswer: TokenStatusAnswer = .chargeable
    var validateSubscription: ValidateSubscription = .success(amountDue: 0)
    var subscriptionAnswer: SubscriptionAnswer = .success
    var usersAnswer: UsersAnswer = .credit(0)
    
    override init() {
        // setup HTTPStubs
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in }
    }
    
    deinit {
        HTTPStubs.removeAllStubs()
    }
    
    override func statusRequest(api: APIService) -> StatusRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/status")) { request in
            let body = self.servicePlansMock.statusAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.statusRequest(api: api)
    }
    
    override func methodsRequest(api: APIService) -> MethodsRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/methods")) { request in
            let body = self.servicePlansMock.paymentMethodsAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.methodsRequest(api: api)
    }
    
    var lastAmount: Int?

    override func buySubscriptionRequest(api: APIService, planId: String, amount: Int, paymentAction: PaymentAction) throws -> SubscriptionRequest? {
        stub(condition: isHost(hostName) && isMethodPOST() && isPath("/api/payments/subscription")) { request in
            let body = self.subscriptionAnswer.getAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            let requestBody = request.ohhttpStubs_httpBody!
            do {
                let dict = try JSONSerialization.jsonObject(with: requestBody, options: []) as! [String: Any]
                if let value = dict["Amount"] as? Int {
                    self.lastAmount = value
                }
            } catch {

            }
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        self.lastAmount = nil
        return try super.buySubscriptionRequest(api: api, planId: planId, amount: amount, paymentAction: paymentAction)
    }

    override func getSubscriptionRequest(api: APIService) -> GetSubscriptionRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/subscription")) { request in
            let body = self.subscriptionRequestAnswer.getAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.getSubscriptionRequest(api: api)
    }

    override func appleRequest(api: APIService, currency: String, country: String) -> AppleRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/apple") && containsQueryParams(["Country": "US", "Currency": "USD", "Tier": "54"])) { request in
            let body = self.servicePlansMock.appleAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.appleRequest(api: api, currency: currency, country: country)
    }

    override func defaultPlanRequest(api: APIService) -> DefaultPlanRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/plans/default")) { request in
            let body = self.servicePlansMock.defaultPlansAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.defaultPlanRequest(api: api)
    }

    override func plansRequest(api: APIService) -> PlansRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/plans") && containsQueryParams(["Currency": "USD", "Cycle": "12"])) { request in
            let body = self.servicePlansMock.plansAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.plansRequest(api: api)
    }

    override func creditRequest(api: APIService, amount: Int, paymentAction: PaymentAction) -> CreditRequest<CreditResponse> {
        stub(condition: isHost(hostName) && isMethodPOST() && isPath("/api/payments/credit")) { request in
            let body = self.creditAnswer.getAnswer.data(using: String.Encoding.utf8)!
            if case .errorNextState(_, let nextState) = self.creditAnswer {
                self.creditAnswer = nextState
            }
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.creditRequest(api: api, amount: amount, paymentAction: paymentAction)
    }

    override func tokenRequest(api: APIService, amount: Int, receipt: String) -> TokenRequest {
        stub(condition: isHost(hostName) && isMethodPOST() && isPath("/api/payments/tokens")) { request in
            let body = self.tokenAnswer.getAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.tokenRequest(api: api, amount: amount, receipt: receipt)
    }

    override func tokenStatusRequest(api: APIService, token: PaymentToken) -> TokenStatusRequest {
        stub(condition: isHost(hostName) && isMethodGET() && isPath("/api/payments/tokens/\(token.token)")) { request in
            let body = self.tokenStatusAnswer.getAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            if case .pending(let nextState) = self.tokenStatusAnswer {
                if let nextState = nextState {
                    self.tokenStatusAnswer = nextState
                }
            } else if case .failed(let nextState) = self.tokenStatusAnswer {
                if let nextState = nextState {
                    self.tokenStatusAnswer = nextState
                }
            } else if case .consumed(let nextState) = self.tokenStatusAnswer {
                if let nextState = nextState {
                    self.tokenStatusAnswer = nextState
                }
            } else if case .notSupported(let nextState) = self.tokenStatusAnswer {
                if let nextState = nextState {
                    self.tokenStatusAnswer = nextState
                }
            }
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.tokenStatusRequest(api: api, token: token)
    }

    override func validateSubscriptionRequest(api: APIService, planId: String) -> ValidateSubscriptionRequest {
        stub(condition: isHost(hostName) && isMethodPUT() && isPath("/api/payments/subscription/check")) { request in
            let body = self.validateSubscription.getAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.validateSubscriptionRequest(api: api, planId: planId)
    }
    
    override func getUser(api: APIService, completion: @escaping (Result<User, Error>) -> Void) {
        stub(condition: isHost(hostName) && isPath("/api/users")) { request in
            let body = self.usersAnswer.getAnswer.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }
        return super.getUser(api: api, completion: completion)
    }
}

enum SubscriptionRequestAnswer {
    case free
    case mailPlus(periodEnd: TimeInterval? = nil)
    case mailPlus1m
    case mailPlus2y
    case mailPlusAddons(periodEnd: TimeInterval? = nil)
    case vpnBasic
    case vpnBasicAddons
    case vpnPlus
    case vpnPlusAddons
    case professional(periodEnd: TimeInterval? = nil)
    case visionary(periodEnd: TimeInterval? = nil)
    
    var getAnswer: String {
        switch self {
        case .free: return freeSubscriptionAnswer
        case .mailPlus(let periodEnd): return mailPlusSubscriptionAnswer(periodEnd: periodEnd)
        case .mailPlus1m: return mailPlus1mSubscriptionAnswer
        case .mailPlus2y: return mailPlus2ySubscriptionAnswer
        case .mailPlusAddons(let periodEnd): return mailPlusAddonsSubscriptionAnswer(periodEnd: periodEnd)
        case .vpnBasic: return vpnBasicSubscriptionAnswer
        case .vpnBasicAddons: return vpnBasicAddonsSubscriptionAnswer
        case .vpnPlus: return vpnPlusSubscriptionAnswer
        case .vpnPlusAddons: return vpnPlusAddonsSubscriptionAnswer
        case .professional(let periodEnd): return professionalSubscriptionAnswer(periodEnd: periodEnd)
        case .visionary(let periodEnd): return visionarySubscriptionAnswer(periodEnd: periodEnd)
        }
    }
    
    var freeSubscriptionAnswer: String { """
        {
          "Code" : 22110
        }
        """
    }
    
    func mailPlusSubscriptionAnswer(periodEnd: TimeInterval? = nil) -> String {
        return """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "H27NKF2SNXEVNaZ3DJcc3bgDoQj44tSaTXkrrRzsnWP4s-SKWIDzZ8ezNx5FJC8DPBs0kxIL7jPZ8VT84uBaDg==",
            "PeriodEnd" : \(periodEnd ?? 1639753199),
            "Amount" : 4800,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "USD",
            "PeriodStart" : 1608217199,
            "ID" : "SnpAJexryx0KfMNLFbzAs0_1tjTWR0cEC9nOaKXxesMAmzJv3pxb_iy_tIdNDxk-Ps0dTeu7HEfNeEIZTVCp2Q==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "plus",
                "ID" : "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                "MaxAddresses" : 5,
                "MaxMembers" : 1,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 5368709120,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonMail Plus",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "USD",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    var mailPlus1mSubscriptionAnswer: String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "H27NKF2SNXEVNaZ3DJcc3bgDoQj44tSaTXkrrRzsnWP4s-SKWIDzZ8ezNx5FJC8DPBs0kxIL7jPZ8VT84uBaDg==",
            "PeriodEnd" : 1639753199,
            "Amount" : 4800,
            "Cycle" : 1,
            "CouponCode" : null,
            "Currency" : "USD",
            "PeriodStart" : 1608217199,
            "ID" : "SnpAJexryx0KfMNLFbzAs0_1tjTWR0cEC9nOaKXxesMAmzJv3pxb_iy_tIdNDxk-Ps0dTeu7HEfNeEIZTVCp2Q==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "plus",
                "ID" : "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                "MaxAddresses" : 5,
                "MaxMembers" : 1,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 5368709120,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonMail Plus",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "USD",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    var mailPlus2ySubscriptionAnswer: String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "H27NKF2SNXEVNaZ3DJcc3bgDoQj44tSaTXkrrRzsnWP4s-SKWIDzZ8ezNx5FJC8DPBs0kxIL7jPZ8VT84uBaDg==",
            "PeriodEnd" : 1639753199,
            "Amount" : 4800,
            "Cycle" : 24,
            "CouponCode" : null,
            "Currency" : "USD",
            "PeriodStart" : 1608217199,
            "ID" : "SnpAJexryx0KfMNLFbzAs0_1tjTWR0cEC9nOaKXxesMAmzJv3pxb_iy_tIdNDxk-Ps0dTeu7HEfNeEIZTVCp2Q==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "plus",
                "ID" : "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                "MaxAddresses" : 5,
                "MaxMembers" : 1,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 5368709120,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonMail Plus",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "USD",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    func mailPlusAddonsSubscriptionAnswer(periodEnd: TimeInterval? = nil) -> String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "8-pQv-30LD_k8Kja4q4ByEwvENeCTcjO6Y9OMd_gRcdq8x577b55kLZQM6lRYdcvLpp-qz3ZjKA7YfJ2Hybx2g==",
            "PeriodEnd" : \(periodEnd ?? 1647351910),
            "Amount" : 8400,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "EUR",
            "PeriodStart" : 1615815910,
            "ID" : "6UWOYYAt9Y2wiEJ23AcFcLZQQnxFb4pN-UFmD2REn6gL1qyQxacfDAB5ywwFNYONG8CUG_rlyXUgm84FJgvZHA==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "plus",
                "ID" : "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                "MaxAddresses" : 5,
                "MaxMembers" : 1,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 5368709120,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonMail Plus",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              },
              {
                "Amount" : 1800,
                "Name" : "1domain",
                "ID" : "Xz2wY0Wq9cg1LKwchjWR05vF62QUPZ3h3Znku2ramprCLWOr_5kB8mcDFxY23lf7QspHOWWflejL6kl04f-a-Q==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 0,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 0,
                "Title" : "+1 Domain",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              },
              {
                "Amount" : 900,
                "Name" : "5address",
                "ID" : "BzHqSTaqcpjIY9SncE5s7FpjBrPjiGOucCyJmwA6x4nTNqlElfKvCQFr9xUa2KgQxAiHv4oQQmAkcA56s3ZiGQ==",
                "MaxAddresses" : 5,
                "MaxMembers" : 0,
                "MaxTier" : 0,
                "MaxDomains" : 0,
                "MaxSpace" : 0,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 0,
                "Title" : "+5 Addresses",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              },
              {
                "Amount" : 900,
                "Name" : "1gb",
                "ID" : "vUZGQHCgdhbDi3qBKxtnuuagOsgaa08Wpu0WLdaqVIKGI5FM7KwIrDB4IprPbhThXJ_5Pb90bkGlHM1ARMYYrQ==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 0,
                "MaxDomains" : 0,
                "MaxSpace" : 1073741824,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 0,
                "Title" : "+1 GB",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    var vpnBasicSubscriptionAnswer: String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "qYlP7OtqoNE56ZMrZ3qBVgkhH63qJ2ecnKlKSu8whAXSneYobSe-isYuvattDWt60aaCKIow26jvgRJPFu-8OQ==",
            "PeriodEnd" : 1647435234,
            "Amount" : 4800,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "EUR",
            "PeriodStart" : 1615899234,
            "ID" : "fVakDqDxOAfWfrTW4xvf_RXYqsEHlZgdR0vkIPFmfMXoSJ9wpI2GlSvRgCN7ALuikquoiUe_9layMR96nduqOA==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "vpnbasic",
                "ID" : "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 1,
                "MaxDomains" : 0,
                "MaxSpace" : 0,
                "Services" : 4,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonVPN Basic",
                "MaxVPN" : 2,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    var vpnBasicAddonsSubscriptionAnswer: String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "qYlP7OtqoNE56ZMrZ3qBVgkhH63qJ2ecnKlKSu8whAXSneYobSe-isYuvattDWt60aaCKIow26jvgRJPFu-8OQ==",
            "PeriodEnd" : 1647435234,
            "Amount" : 4800,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "EUR",
            "PeriodStart" : 1615899234,
            "ID" : "fVakDqDxOAfWfrTW4xvf_RXYqsEHlZgdR0vkIPFmfMXoSJ9wpI2GlSvRgCN7ALuikquoiUe_9layMR96nduqOA==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "vpnbasic",
                "ID" : "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 1,
                "MaxDomains" : 0,
                "MaxSpace" : 0,
                "Services" : 4,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonVPN Basic",
                "MaxVPN" : 2,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              },
              {
                "Amount" : 1800,
                "Name" : "1domain",
                "ID" : "Xz2wY0Wq9cg1LKwchjWR05vF62QUPZ3h3Znku2ramprCLWOr_5kB8mcDFxY23lf7QspHOWWflejL6kl04f-a-Q==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 0,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 0,
                "Title" : "+1 Domain",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    var vpnPlusSubscriptionAnswer: String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "3Al67zVhzrc8Kox4xvoedoecRz-ecsP85caWNh5jlJ8kS-3o00irupTiel-EAwqOkVnIs0cDxRF9i-YVS0JZmw==",
            "PeriodEnd" : 1647435850,
            "Amount" : 9600,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "EUR",
            "PeriodStart" : 1615899850,
            "ID" : "tRsLUqLjehUN0UsPIVOt-s-XtH2tCjqcSSiQzVdys9kXJdG0aO-JkFyGFELSzyxvofQAWkbOUI6uXcPldgpUBw==",
            "Plans" : [
              {
                "Amount" : 9600,
                "Name" : "vpnplus",
                "ID" : "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 2,
                "MaxDomains" : 0,
                "MaxSpace" : 0,
                "Services" : 4,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonVPN Plus",
                "MaxVPN" : 5,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

    var vpnPlusAddonsSubscriptionAnswer: String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "3Al67zVhzrc8Kox4xvoedoecRz-ecsP85caWNh5jlJ8kS-3o00irupTiel-EAwqOkVnIs0cDxRF9i-YVS0JZmw==",
            "PeriodEnd" : 1647435850,
            "Amount" : 9600,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "EUR",
            "PeriodStart" : 1615899850,
            "ID" : "tRsLUqLjehUN0UsPIVOt-s-XtH2tCjqcSSiQzVdys9kXJdG0aO-JkFyGFELSzyxvofQAWkbOUI6uXcPldgpUBw==",
            "Plans" : [
              {
                "Amount" : 9600,
                "Name" : "vpnplus",
                "ID" : "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 2,
                "MaxDomains" : 0,
                "MaxSpace" : 0,
                "Services" : 4,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonVPN Plus",
                "MaxVPN" : 5,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              },
              {
                "Amount" : 1800,
                "Name" : "1domain",
                "ID" : "Xz2wY0Wq9cg1LKwchjWR05vF62QUPZ3h3Znku2ramprCLWOr_5kB8mcDFxY23lf7QspHOWWflejL6kl04f-a-Q==",
                "MaxAddresses" : 0,
                "MaxMembers" : 0,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 0,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 0,
                "Title" : "+1 Domain",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "EUR",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }
    
    func professionalSubscriptionAnswer(periodEnd: TimeInterval? = nil) -> String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "I6Es-BS5-Uo80kgpF0y9dw250d42KyViUu06Eg8BbAODwigPrsjSepTO9duv1bove8_cV6JapTbXneIHEUJvgg==",
            "PeriodEnd" : \(periodEnd ?? 1656185527),
            "Amount" : 7500,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "USD",
            "PeriodStart" : 1624649527,
            "ID" : "M2Q7EeCBnmXU8QCRa9HzWWoz_VYooD2Os_m1UJuIQ8B1EriuD5WI2wiXBXMB0m9JQNM5Z8AVycHL121n2abA-g==",
            "Plans" : [
              {
                "Amount" : 7500,
                "Name" : "professional",
                "ID" : "R0wqZrMt5moWXl_KqI7ofCVzgV0cinuz-dHPmlsDJjwoQlu6_HxXmmHx94rNJC1cNeultZoeFr7RLrQQCBaxcA==",
                "MaxAddresses" : 10,
                "MaxMembers" : 1,
                "MaxTier" : 0,
                "MaxDomains" : 2,
                "MaxSpace" : 5368709120,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonMail Professional",
                "MaxVPN" : 0,
                "Features" : 1,
                "Currency" : "USD",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }
    
    func visionarySubscriptionAnswer(periodEnd: TimeInterval? = nil) -> String { """
        {
          "Code" : 1000,
          "Subscription" : {
            "InvoiceID" : "QCM8kUtswbIcSdsFO0ZpYxXWEXnS4OjRAk0iiizD64FwRbi7DgRC_nYeS4jLB9Eh9CuaqGi-72YCIyHhmj9bgg==",
            "PeriodEnd" : \(periodEnd ?? 1655801265),
            "Amount" : 28800,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "CHF",
            "PeriodStart" : 1624265265,
            "ID" : "y0APGMLlVvZjMTXBaACXSNmYQvPnXBwJaYGfHePMr4zzsVlY1MSvj_UhCCgPvDXpHTrdc99p70ALFLyq3rP6Xg==",
            "Plans" : [
              {
                "Amount" : 28800,
                "Name" : "visionary",
                "ID" : "m-dPNuHcP8N4xfv6iapVg2wHifktAD1A1pFDU95qo5f14Vaw8I9gEHq-3GACk6ef3O12C3piRviy_D43Wh7xxQ==",
                "MaxAddresses" : 50,
                "MaxMembers" : 6,
                "MaxTier" : 2,
                "MaxDomains" : 10,
                "MaxSpace" : 21474836480,
                "Services" : 5,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "Visionary",
                "MaxVPN" : 10,
                "Features" : 1,
                "Currency" : "CHF",
                "Quantity" : 1
              }
            ]
          }
        }
        """
    }

}

protocol MockAnwerProtocol {
    var getAnswer: String { get }
}

indirect enum CreditAnswer: MockAnwerProtocol {
    case success
    case errorAlredyRegistered
    case errorAmountMismatch
    case error(Int)
    case errorNextState(Int, nextState: CreditAnswer)
    
    var getAnswer: String {
        switch self {
        case .success: return successAnswer
        case .errorAlredyRegistered: return errorAlreadyRegistered
        case .errorAmountMismatch: return errorAmountMismatch
        case .error(let code): return error(code: code)
        case .errorNextState(let code, _): return error(code: code)
        }
    }
    
    static let errorAmountMismatchCode: Int = 22101
    static let errorAlreadyRegisteredCode: Int = 22916
    
    var successAnswer: String {
        error(code: 1000)
    }
    
    var errorAlreadyRegistered: String {
        error(code: CreditAnswer.errorAlreadyRegisteredCode)
    }
    
    var errorAmountMismatch: String {
        error(code: CreditAnswer.errorAmountMismatchCode)
    }
    
    func error(code: Int) -> String {
        return "{\"Code\": \(code)}"
    }
}

enum TokenAnswer: MockAnwerProtocol {
    case success
    case errorSandboxReceipt
    case errorAlreadyRegistered
    case error(Int)
    
    var getAnswer: String {
        switch self {
        case .success: return successAnswer
        case .errorSandboxReceipt: return errorSandboxReceipt
        case .errorAlreadyRegistered: return errorAlreadyRegistered
        case .error(let code): return error(code: code)
        }
    }
    
    var successAnswer: String { """
        {
          "Token" : "o7U5OisbLfCzA_Le0cnrhHNE",
          "Code" : 1000,
          "Status" : 1
        }
        """
    }
    
    var errorSandboxReceipt: String {
        error(code: 22914)
    }
    
    var errorAlreadyRegistered: String {
        error(code: 22916)
    }
    
    func error(code: Int) -> String {
        return "{\"Code\": \(code)}"
    }
}

indirect enum TokenStatusAnswer: MockAnwerProtocol {
    case pending(nextState: TokenStatusAnswer? = nil)
    case chargeable
    case failed(nextState: TokenStatusAnswer? = nil)
    case consumed(nextState: TokenStatusAnswer? = nil)
    case notSupported(nextState: TokenStatusAnswer? = nil)
    
    var getIndex: Int {
        switch self {
        case .pending: return 0
        case .chargeable: return 1
        case .failed: return 2
        case .consumed: return 3
        case .notSupported: return 4
        }
    }
    
    var getAnswer: String {
        return answer(status: getIndex)
    }
    
    func answer(status: Int) -> String {
        return "{\"Status\": \(status), \"Code\": 1000}"
    }
}

enum ValidateSubscription: MockAnwerProtocol {
    case success(amountDue: Int)
    case error(Int)
    
    var getAnswer: String {
        switch self {
        case .success(let amountDue): return successAnswer(amountDue: amountDue)
        case .error(let code): return errorAnswer(code: code)
        }
    }
    
    func successAnswer(amountDue: Int) -> String {
        return "{\"AmountDue\": \(amountDue), \"Code\": 1000}"
    }
        
    func errorAnswer(code: Int) -> String {
        return "{\"Code\": \(code)}"
    }
}

enum SubscriptionAnswer: MockAnwerProtocol {
    case success
    case successWithNoSubscription
    case errorAmountMismatch
    case errorAlreadyRegistered
    case error(Int)
    
    var getAnswer: String {
        switch self {
        case .success: return successAnswer
        case .successWithNoSubscription: return successWithNoSubscription
        case .errorAmountMismatch: return errorAmountMismatch
        case .errorAlreadyRegistered: return errorAlreadyRegistered
        case .error(let code): return error(code: code)
        }
    }
    
    var successAnswer: String { """
        {
          "Subscription" : {
            "InvoiceID" : "SKhICvkxYLs-TqZBpvHn9feBblFYXw1LpwJ0LXHRm9lFvrYds7OjJostTsR-PpMQEyYz9QAgEcxaOS9HF7Av2g==",
            "PeriodEnd" : 1640171352,
            "Amount" : 4800,
            "Cycle" : 12,
            "CouponCode" : null,
            "Currency" : "USD",
            "PeriodStart" : 1608635352,
            "ID" : "tByq2l1-VS9UUHpK56HRO7v0tzX3ImQZW6hGftBhwNB8tjwUfFP04FWzFAKkBWKptjgf1818jjfVxEb-03LXig==",
            "Plans" : [
              {
                "Amount" : 4800,
                "Name" : "plus",
                "ID" : "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
                "MaxAddresses" : 5,
                "MaxMembers" : 1,
                "MaxTier" : 0,
                "MaxDomains" : 1,
                "MaxSpace" : 5368709120,
                "Services" : 1,
                "Cycle" : 12,
                "Type" : 1,
                "Title" : "ProtonMail Plus",
                "MaxVPN" : 0,
                "Features" : 0,
                "Currency" : "USD",
                "Quantity" : 1
              }
            ]
          },
          "Code" : 1000
        }
        """
    }
    
    var successWithNoSubscription: String { """
        {
            "Code" : 1000
        }
        """
    }
    
    var errorAmountMismatch: String {
        return error(code: 22101)
    }
    
    var errorAlreadyRegistered: String {
        return error(code: 22916)
    }
    
    func error(code: Int) -> String {
        return "{\"Code\": \(code)}"
    }
}

enum UsersAnswer: MockAnwerProtocol {
    case credit(Int)

    var getAnswer: String {
        switch self {
        case .credit(let credit): return usersCredit0Answer(credit: credit)
        }
    }

    func usersCredit0Answer(credit: Int) -> String { """
        {
          "User" : {
            "Role" : 2,
            "Private" : 1,
            "UsedSpace" : 678693,
            "Subscribed" : 1,
            "Name" : "abc",
            "ID" : "abc==",
            "MaxUpload" : 26214400,
            "Credit" : \(credit),
            "Delinquent" : 0,
            "Keys" : [
              {
                "ID" : "123==",
                "Version" : 3,
                "PrivateKey" : "123",
                "Fingerprint" : "123",
                "Primary" : 1
              }
            ],
            "Email" : "abc@xyz",
            "DisplayName" : "abc",
            "MaxSpace" : 5368709120,
            "Services" : 1,
            "Currency" : "USD",
            "DriveEarlyAccess" : 0
          },
          "Code" : 1000
        }
        """
    }
}
