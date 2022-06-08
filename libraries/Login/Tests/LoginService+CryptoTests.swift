//
//  LoginService+CryptoTests.swift
//  ProtonCore-Login-Tests - Created on 07/06/2022.
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

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_DataModel
import ProtonCore_Services
@testable import ProtonCore_Login

class LoginServiceCryptoTests: XCTestCase {
    
    var login: LoginService!
    
    override func setUp() {
        super.setUp()
        let api = PMAPIService(doh: DohMock(), sessionUID: "test session ID")
        let authDelegate = AuthManager()
        api.authDelegate = authDelegate
        login = LoginService(api: api, authManager: authDelegate, clientApp: .other(named: "TestAPP"), sessionId: "test session ID", minimumAccountType: .internal)
    }
    
    let privateKey = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: ProtonMail\n\nxcMGBF8rv5oBCACnZM0wl0BAFcq3SJDyKYCzgK++n3Hum77oSQ7xtVaA9YKj\niomsEJ44c7iU4YXFE+kztrwZDkVEmmN7XsuwRYdwQMMcUdls0RX8yn7GAuvT\ncf4dBlgGYtqms28b2/lIpKNxkN2NJ/+t+nKiw2jtjTT86FDZBdVWq04U8kC1\nsKAcFIr67HGt+nEp6qYb5Izfw4fwrp2R3f2uizajSYOkfDIcxmgmHnLfikDa\nWH5fg12oeRCZa6QgU8f3QwkrSGJyC/uz3mLMD+pTk4BvfAChyarckE9+TcWe\n28moE9qHAjpm0fPzeqW0TxamzUlBcKPu+qy/jJyzFG4YtNcd7uISARx5ABEB\nAAH+CQMI9Q3+w7+KI+1gB6F4EuRIBrb3qcItbegP7Eh3I0T+6w5dh/0rFC7R\npwp2X9L8DDlDe0ayaspP0mSp9EtG1D9UNCLPmFTm9hEqCbegoFljSY1nHV+R\nuBwKWTrFhpaTIPJT/EyXhXy5naxlrdxCp+W+ESR6Ljcm9K9n6vkO18xw6WDR\noHGCfI/91S4aOL9lfWrJhmrDDS8FH90y5RWs2/D89k05K59jElcJcqAHhkku\nZAnTNhkxDeDQzRksPv1BYJs+WxrLiFcE1HN4+Jqox68/ofsXnswH3uECoMfe\nfYkbMxS6ZMVPTLZhX60o5R+hzTgMuozAiUiB72B1G9MRO5bi/oVlG+UFBaxs\nMQeJLgNTK5bVOyaLwzUGDIxSnO1wTcTF7q545K5nlKtMIyVXBxNpib0zCs/q\nwPTOI6/VVQm28cP3UbyMEF2wlzU8d5xR9Gj7sV3127dJICghhv1sObdWNqI8\n+9UcK28VvZRhsexX66zopy0mydpSzgEAKb3fKnOjxA40aLOKlt+dGgWlxW4w\nRvImppssiRnWmhyVg25bKiPm3JOw20f6Rv8orpHbphc8V5/CWAg2LEfiPo3U\n9Vmuc3URGJRGEImGxCTNwNWHN17DceBa5ziMNh6AKsVmf54l67AEfRoMwTgX\njumQtYmVBnOPOl5Y4cRPAXSLaYg0mzMtPmiE084lBAiVckcJLuHly8eCwA7/\n+pXk3pZBXiR3vpdvuSojNrfhFqbIAPBNx+0P5+3PoA1NuwzQ0oGBzdNHmF8d\neRWaV0tj9H2qYrN35cMwrhOUMpeOQFD2dqcSTGUa+nzdZ1CYJxAgZP87DaYJ\noO49zrPYw1SKhktjLIhchWd2ugf9ZoEsXs0mjxhMCnHkGi88Z5uVlZw2Nzia\nNRYRv9dmKeJDpojNVOeVBvwAQRppwwPgzTMxUGFzc1VzZXJAcHJvdG9ubWFp\nbC5jb20gPDFQYXNzVXNlckBwcm90b25tYWlsLmNvbT7CwI0EEAEIACAFAl8r\nv5oGCwkHCAMCBBUICgIEFgIBAAIZAQIbAwIeAQAhCRDdkOL4OLn9jBYhBP8q\n6hL2cuz8z47SG92Q4vg4uf2MwuoIAJ/MnaqsB6TdT/307pmlh6f9f4KUDRZ3\nDfTHYAbZjyvmXNA6nsuqFufMLi6MlyVYRTLn4MyBsQaAxfF1YEOGBFniskfO\ngcJat142MDbpqC6unPHJscyWpXNWuAbpJkdruBi9Bp+oOc1U/TVXqEbluFoX\nkO9IXCG3pEMGSTVTPWqLzPpIlMSys6xiQtPkue8sH0fKOAMusZzXloGkaf/0\n3hP5k+vcEE7n0dWmwL4lcFEv1cxlafCcss3vUAbKfNnkEmur2BVy0Ks7F0aL\nLAPX2IVwpQn3EIaL6Tub59KeW559SXX2kGEBWabjile4xQNNBUcR8Vf3NcyT\nK24rltQu6O3HwwYEXyu/mgEIAKDdUpNj6w8zALA9UHFjZuxAQiRvwJfVtu+x\nXHyF6I8fn4fzSBC415Y6nb6edqQOo70rQ4u30xT55trRwAbO8rjJoHDoi4Ov\n10vo/+I2UvD6BNRDh7Go+oIDGW+PVYeoCwv/5VDSzqPVK90nrIny4eduIv+7\nVZpHpcS1JGjquwgZnDivKar3898iilvFhrOdFIrVjyR54SzIfVrP8PLzQR0P\n+3FELzjcDuR7dNXNo50l7/BPR0onxt6TL+tJrnnrhENLarPickQO5Zcd5x0o\nxahKG+82IPkCRZxM+CVS04dCqp5BuvIyvIofHbY5RlIK++TdaOtk0+neHqwm\nAErWYfUAEQEAAf4JAwhpNc75yj4Bf2D3V2EuIFofN0yxJtTbVqr45bKptXvE\n+1Rq/0etv/HNGVM2MH10xFy4TIZsArCKnmF0fhlAQRfsjdDipfUyx9O1CQl3\nd+4p5Hi78T5XoOyc7EpAJxKWy+nRl86yEpizN0LgfvVEhYcGtpOf67KKVPML\naL61zCOaHB+1tjyL+Op1jYpV46OIf4u+RDLc4duM8QyljTWXwlBXpAEHL6n7\ndrExHSxHeoBb2QICf/Ma6yapzoXIARFlreeQtg/uohKN7TOdnXvLNFdCcbm7\nMkq3jMV2rMdW8T7YJpwIblIAHF9NpCk3tvH/N3eZ5VPaPAUtQd324ZnJtSLH\nOAx8pBVprEbYxTNdfXFcq68ppB9e9HGCZvEnGwpbNPqDaoemEokjkpc7FV2R\n1tFVH5O3rCAkEuhWK75TY7FfyqFeoqpkNo5ccYVHltEedmMNME6NAuxwozZE\nCWvvK1RGf5cKczGahRkdh1uICOVUJ8TL+G5QvBpUdwmh6dNQDhct1aM39pgJ\nYT7gD2HO92H+JM36z8XGq8gAuiwCMGmvZ6BxJ74JwoSdJtSj9ovD79oPQPp0\nGVKAuQtJTH1myC0mEY4ENApA/ljznj17Wn4inxJE+Q47G13fGp4t8QkatYWz\nnZIgZDSsvqoziLy0+Akajv7g1aQyfHQ5a8R0M869BWC+r9q8WWiVk/JLprSu\n06L9+rugdNgt8uySrCg4e8B3IH/4iu1bpv6R4Djwv80nCmQmyAK8JWqijDd/\nBTN6M86ODCRpuYBDXSISvlb03TDxUYHG+GPnmH3PtBP0KlHm6Wr5HPVlummf\nTRUsnlyxijJxnybuNQtqh8z0aZcpyndGzf7IUnT6/hq/nKMXZumzBa09xhHQ\np/LGoqO9oZ++xFgOZ1cVt6/EdmOAMlVEjyDcx9qV65LCwHYEGAEIAAkFAl8r\nv5oCGwwAIQkQ3ZDi+Di5/YwWIQT/KuoS9nLs/M+O0hvdkOL4OLn9jIwLB/9k\n11AQw25xYquNeC2ndM5bDM3VFTYwoEUBiZ7yG15muIiDNeyzP2BXzkvSVFee\nW3g6JfvqIK9Dp8YxCbSV3aqiAO4Ha8PxE2EOqGaqwcVOne2T1XOEFebM7twv\nkikDOy0pOXh4WwU6lJGfkOTKTd6FgF93umrUYXxjc7SB7bEdp0csw/FsMoWd\n/GqXxwm0qOjVfEPy7OVCPkHTgVwDxDz/dxiQsMGW/JpQj9lZJ2v6uDRBg9lO\nsLserfx7/DbtvFEvu3T2IMMEUrJK7dPu+zMWgMLdq53XPXn6VV5WNHA0o/qG\n7MJucqSOgVL7zO+qEBiDP5OotxdXabeT2iYyZIjc\n=3020\n-----END PGP PRIVATE KEY BLOCK-----\n"
    
    let passphrase = "VMjDEvsx8n2EMr/pBxMN1bbFdGXPixa"
    
    // ValidateMailboxPassword tests
    
    func test_1Passphrase_1Key_Matched_PrimaryKey() {
        let passphrases = ["keyID": passphrase]
        let key1 = Key(keyID: "keyID", privateKey: privateKey, primary: 1)
        
        let result = login.validateMailboxPassword(passphrases: passphrases, userKeys: [key1])
        XCTAssertTrue(result)
    }
    
    func test_2Passphrases_1Key_Matched_PrimaryKey() {
        let passphrases = ["keyID": passphrase, "keyID2": "passphrase 2"]
        let key1 = Key(keyID: "keyID", privateKey: privateKey, primary: 1)

        let result = login.validateMailboxPassword(passphrases: passphrases, userKeys: [key1])
        XCTAssertTrue(result)
    }

    func test_2Passphrases_2Keys_Matched_PrimaryKey() {
        let passphrases = ["keyID": "passphrase", "keyID2": passphrase]
        let key1 = Key(keyID: "keyIDX", privateKey: "privateKeyX", primary: 1)
        let key2 = Key(keyID: "keyID2", privateKey: privateKey, primary: 1)

        let result = login.validateMailboxPassword(passphrases: passphrases, userKeys: [key1, key2])
        XCTAssertTrue(result)
    }

    func test_1Passphrase_2Keys_Matched_PrimaryKey() {
        let passphrases = ["keyID": passphrase]
        let key1 = Key(keyID: "keyID", privateKey: privateKey, primary: 1)
        let key2 = Key(keyID: "keyID2", privateKey: "privateKey2", primary: 1)

        let result = login.validateMailboxPassword(passphrases: passphrases, userKeys: [key1, key2])
        XCTAssertTrue(result)
    }

    func test_1Passphrase_1Key_NotMatched_PrimaryKey() {
        let passphrases = ["keyIDX": passphrase]
        let key1 = Key(keyID: "keyID", privateKey: "privateKey", primary: 1)

        let result = login.validateMailboxPassword(passphrases: passphrases, userKeys: [key1])
        XCTAssertFalse(result)
    }

    func test_1Passphrase_1Key_Matched_NoPrimaryKey() {
        let passphrases = ["keyID": passphrase]
        let key1 = Key(keyID: "keyID", privateKey: privateKey, primary: 0)

        let result = login.validateMailboxPassword(passphrases: passphrases, userKeys: [key1])
        XCTAssertFalse(result)
    }
}
