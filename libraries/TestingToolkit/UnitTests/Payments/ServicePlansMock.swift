//
//  ServicePlansMock.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

public class ServicePlansMock {
    
    public init() {
    }
    
    public var statusAnswer = """
    {
        "Paypal" : true,
        "Paymentwall" : false,
        "Stripe" : true,
        "Blockchain.info" : true,
        "Code" : 1000,
        "Apple" : true
    }
    """
    
    public var plansAnswer = """
    {
        "Plans" : [
          {
            "Amount" : 4800,
            "Name" : "plus",
            "ID" : "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==",
            "MaxAddresses" : 5,
            "MaxMembers" : 1,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 500,
              "12" : 4800,
              "24" : 7900
            },
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
          },
          {
            "Amount" : 4800,
            "Name" : "vpnbasic",
            "ID" : "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==",
            "MaxAddresses" : 0,
            "MaxMembers" : 0,
            "MaxTier" : 1,
            "Pricing" : {
              "1" : 500,
              "12" : 4800,
              "24" : 7900
            },
            "MaxDomains" : 0,
            "MaxSpace" : 0,
            "Services" : 4,
            "Cycle" : 12,
            "Type" : 1,
            "Title" : "ProtonVPN Basic",
            "MaxVPN" : 2,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 7500,
            "Name" : "professional",
            "ID" : "R0wqZrMt5moWXl_KqI7ofCVzgV0cinuz-dHPmlsDJjwoQlu6_HxXmmHx94rNJC1cNeultZoeFr7RLrQQCBaxcA==",
            "MaxAddresses" : 10,
            "MaxMembers" : 1,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 800,
              "12" : 7500,
              "24" : 12900
            },
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
          },
          {
            "Amount" : 9600,
            "Name" : "business",
            "ID" : "ARy95iNxhniEgYJrRrGvagmzRdnmvxCmjArhv3oZhlevziltNm07euTTWeyGQF49RxFpMqWE_ZGDXEvGV2CEkA==",
            "MaxAddresses" : 5,
            "MaxMembers" : 2,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 1000,
              "12" : 9600
            },
            "MaxDomains" : 1,
            "MaxSpace" : 10737418240,
            "Services" : 1,
            "Cycle" : 12,
            "Type" : 1,
            "Title" : "Business",
            "MaxVPN" : 0,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 9600,
            "Name" : "vpnplus",
            "ID" : "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==",
            "MaxAddresses" : 0,
            "MaxMembers" : 0,
            "MaxTier" : 2,
            "Pricing" : {
              "1" : 1000,
              "12" : 9600,
              "24" : 15900
            },
            "MaxDomains" : 0,
            "MaxSpace" : 0,
            "Services" : 4,
            "Cycle" : 12,
            "Type" : 1,
            "Title" : "ProtonVPN Plus",
            "MaxVPN" : 5,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 28800,
            "Name" : "visionary",
            "ID" : "m-dPNuHcP8N4xfv6iapVg2wHifktAD1A1pFDU95qo5f14Vaw8I9gEHq-3GACk6ef3O12C3piRviy_D43Wh7xxQ==",
            "MaxAddresses" : 50,
            "MaxMembers" : 6,
            "MaxTier" : 2,
            "Pricing" : {
              "1" : 3000,
              "12" : 28800,
              "24" : 47900
            },
            "MaxDomains" : 10,
            "MaxSpace" : 21474836480,
            "Services" : 5,
            "Cycle" : 12,
            "Type" : 1,
            "Title" : "Visionary",
            "MaxVPN" : 10,
            "Features" : 1,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 900,
            "Name" : "1gb",
            "ID" : "vUZGQHCgdhbDi3qBKxtnuuagOsgaa08Wpu0WLdaqVIKGI5FM7KwIrDB4IprPbhThXJ_5Pb90bkGlHM1ARMYYrQ==",
            "MaxAddresses" : 0,
            "MaxMembers" : 0,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 100,
              "12" : 900,
              "24" : 1600
            },
            "MaxDomains" : 0,
            "MaxSpace" : 1073741824,
            "Services" : 1,
            "Cycle" : 12,
            "Type" : 0,
            "Title" : "+1 GB",
            "MaxVPN" : 0,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 900,
            "Name" : "5address",
            "ID" : "BzHqSTaqcpjIY9SncE5s7FpjBrPjiGOucCyJmwA6x4nTNqlElfKvCQFr9xUa2KgQxAiHv4oQQmAkcA56s3ZiGQ==",
            "MaxAddresses" : 5,
            "MaxMembers" : 0,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 100,
              "12" : 900,
              "24" : 1600
            },
            "MaxDomains" : 0,
            "MaxSpace" : 0,
            "Services" : 1,
            "Cycle" : 12,
            "Type" : 0,
            "Title" : "+5 Addresses",
            "MaxVPN" : 0,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 1800,
            "Name" : "1domain",
            "ID" : "Xz2wY0Wq9cg1LKwchjWR05vF62QUPZ3h3Znku2ramprCLWOr_5kB8mcDFxY23lf7QspHOWWflejL6kl04f-a-Q==",
            "MaxAddresses" : 0,
            "MaxMembers" : 0,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 200,
              "12" : 1800,
              "24" : 3200
            },
            "MaxDomains" : 1,
            "MaxSpace" : 0,
            "Services" : 1,
            "Cycle" : 12,
            "Type" : 0,
            "Title" : "+1 Domain",
            "MaxVPN" : 0,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 1800,
            "Name" : "1vpn",
            "ID" : "IJWo5UWjbv8T71AAqcBtYuIGf8aKDLXUVLW82IHJDlaLYzrA5lO_rbrQdVueMrT4AIDYgLRtcJykf6PvS8LE2Q==",
            "MaxAddresses" : 0,
            "MaxMembers" : 0,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 200,
              "12" : 1800,
              "24" : 3200
            },
            "MaxDomains" : 0,
            "MaxSpace" : 0,
            "Services" : 4,
            "Cycle" : 12,
            "Type" : 0,
            "Title" : "+1 VPN Connection",
            "MaxVPN" : 1,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          },
          {
            "Amount" : 7500,
            "Name" : "1member",
            "ID" : "1H8EGg3J1QpSDL6K8hGsTvwmHXdtQvnxplUMePE7Hruen5JsRXvaQ75-sXptu03f0TCO-he3ymk0uhrHx6nnGQ==",
            "MaxAddresses" : 5,
            "MaxMembers" : 1,
            "MaxTier" : 0,
            "Pricing" : {
              "1" : 800,
              "12" : 7500,
              "24" : 12900
            },
            "MaxDomains" : 0,
            "MaxSpace" : 5368709120,
            "Services" : 1,
            "Cycle" : 12,
            "Type" : 0,
            "Title" : "+1 User",
            "MaxVPN" : 0,
            "Features" : 0,
            "Currency" : "USD",
            "Quantity" : 1
          }
        ],
        "Code" : 1000
      }
    """
    
    public var defaultPlansAnswer = """
    {
      "Plans" : [
        {
          "Amount" : 0,
          "Name" : "free",
          "MaxAddresses" : 1,
          "MaxMembers" : 1,
          "MaxDomains" : 0,
          "MaxSpace" : 524288000,
          "Services" : 1,
          "Cycle" : null,
          "Type" : 1,
          "Title" : "ProtonMail Free",
          "MaxVPN" : 0,
          "Features" : 0,
          "Currency" : null,
          "Quantity" : 1
        },
        {
          "Amount" : 0,
          "Name" : "vpnfree",
          "MaxAddresses" : 0,
          "MaxMembers" : 0,
          "MaxDomains" : 0,
          "MaxSpace" : 0,
          "Services" : 4,
          "Cycle" : null,
          "Type" : 1,
          "Title" : "ProtonVPN Free",
          "MaxVPN" : 1,
          "Features" : 0,
          "Currency" : null,
          "Quantity" : 1
        }
      ],
      "Code" : 1000
    }
    """
    
    public var freeSubscriptionAnswer = """
    {
      "Code" : 22110
    }
    """
    
    public var mailSubscriptionAnswer = """
    {
      "Code" : 1000,
      "Subscription" : {
        "InvoiceID" : "H27NKF2SNXEVNaZ3DJcc3bgDoQj44tSaTXkrrRzsnWP4s-SKWIDzZ8ezNx5FJC8DPBs0kxIL7jPZ8VT84uBaDg==",
        "PeriodEnd" : 1639753199,
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
    
    public var appleAnswer = """
    {
      "Proceeds" : "49.00",
      "Currency" : "USD",
      "Price" : "69.99",
      "Country" : "US",
      "Code" : 1000
    }
    """
}
