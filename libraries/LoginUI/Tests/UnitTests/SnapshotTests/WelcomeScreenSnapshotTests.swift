//
//  WelcomeScreenSnapshotTests.swift
//  ProtonCore-LoginUI-V5-Unit-TestsUsingCrypto - Created on 13/10/22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#if os(iOS)

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreChallenge
import ProtonCoreUIFoundations
import ProtonCoreEnvironment
import ProtonCoreDataModel
import ProtonCoreLogin
@testable import ProtonCoreLoginUI
import SnapshotTesting

@available(iOS 13, *)
class WelcomeScreenSnapshotTests: ProtonCoreTestingToolkitUnitTestsCore.SnapshotTestCase {

    let defaultPrecision: Float = 0.98

    fileprivate func welcomeScreenSnapshotTests(
        variant: WelcomeScreenVariant, inAppTheme: InAppTheme = .default, name: String = #function
    ) {
        WelcomeViewLayout.allCases.flatMap { layout in
            let devicesAndNames: [(ViewImageConfig, String)]
            let traits: UITraitCollection
            switch layout {
            case .big:
                devicesAndNames = [
                    (.iPadMini(.portrait), "iPadMini.portrait"),
                    (.iPadMini(.landscape), "iPadMini.landscape")
                ]
                traits = .iPadMini
            case .regular:
                devicesAndNames = [(.iPhone13, "iPhone13")]
                traits = .iPhone13(.portrait)
            case .small:
                devicesAndNames = [(.iPhoneSe, "iPhoneSe")]
                traits = .iPhoneSe(.portrait)
            }
            return devicesAndNames.map { (layout, $0.0, traits, $0.1) }
        }.forEach { layout, device, traits, deviceName in
            Bool.allCases.forEach {
                let clientApp = ClientApp.other(named: "test")
                let apiService = APIServiceMock()
                apiService.authDelegateStub.fixture = nil
                apiService.dohInterfaceStub.fixture = Environment.black.doh
                apiService.challengeParametersProviderStub.fixture = .forAPIService(clientApp: clientApp, challenge: PMChallenge())
                let coordinator = LoginCoordinator(
                    container: Container(appName: "test", clientApp: clientApp, apiService: apiService, minimumAccountType: .internal),
                    isCloseButtonAvailable: false,
                    isSignupAvailable: $0,
                    customization: .init(inAppTheme: { inAppTheme })
                )
                let welcomeScreen = coordinator.createWelcomeViewController(variant: variant)
                welcomeScreen.layout = layout
                checkSnapshots(controller: welcomeScreen,
                               device: device,
                               traits: traits,
                               perceptualPrecision: defaultPrecision,
                               name: "\(name).\(deviceName).\($0 ? "" : ".justSignin")")
            }
        }
    }

    func testMailWelcomeScreen() {
        let body = "This is a test message for the welcome screen snapshot tests of the Mail screen variant"
        welcomeScreenSnapshotTests(variant: .mail(WelcomeScreenTexts(body: body)))
    }

    func testDriveWelcomeScreen() {
        let body = "This is a test message for the welcome screen snapshot tests of the Drive screen variant"
        welcomeScreenSnapshotTests(variant: .drive(WelcomeScreenTexts(body: body)))
    }

    func testCalendarWelcomeScreen() {
        let body = "This is a test message for the welcome screen snapshot tests of the Calendar screen variant"
        welcomeScreenSnapshotTests(variant: .calendar(WelcomeScreenTexts(body: body)))
    }

    func testVPNWelcomeScreen() {
        let body = "This is a test message for the welcome screen snapshot tests of the VPN screen variant"
        welcomeScreenSnapshotTests(variant: .vpn(WelcomeScreenTexts(body: body)))
    }

    func testPassWelcomeScreen() {
        let body = "This is a test message for the welcome screen snapshot tests of the Pass screen variant"
        welcomeScreenSnapshotTests(variant: .pass(WelcomeScreenTexts(body: body)))
    }

    func testWalletWelcomeScreen() {
        let body = "This is a test message for the welcome screen snapshot tests of the Wallet screen variant"
        welcomeScreenSnapshotTests(variant: .wallet(WelcomeScreenTexts(body: body)))
    }

}

extension Bool: CaseIterable {
    public static var allCases: [Bool] { [true, false] }
}

#endif
