//
//  KeychainTests.swift
//  ProtonCore-ProtonCore-Keymaker - Created on 08/07/2019.
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

import XCTest

@testable import ProtonCore_Keymaker

struct MockSettingsProvider: SettingsProvider {
    var lockTime: AutolockTimeout
}

class MockTimeProvider: TimeProvider {
    private(set) var date: Date
    private(set)var deviceUptime: TimeInterval

    init(date: Date, uptime: TimeInterval) {
        self.date = date
        self.deviceUptime = uptime
    }

    func addSecondsToDateAndUptime(seconds: Int) {
        date = date.addingTimeInterval(TimeInterval(seconds))
        deviceUptime += TimeInterval(seconds)
    }

    func addSecondsOnlyToDate(seconds: Int) {
        date = date.addingTimeInterval(TimeInterval(seconds))
    }
}

class AutolockerTests: XCTestCase {
    private var sut: Autolocker!
    private var mockTimeProvider: MockTimeProvider!
    
    private let autolockTimeInMinutes: Int = 5
    private var autolockTimeInSeconds: Int {
        autolockTimeInMinutes * 60
    }

    override func setUp() {
        super.setUp()
        mockTimeProvider = MockTimeProvider(date: Date(), uptime: 1)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockTimeProvider = nil
    }
    
    private func createSUT(autolockTimeout: AutolockTimeout) {
        let mockSettingsProvider = MockSettingsProvider(lockTime: autolockTimeout)
        sut = Autolocker(lockTimeProvider: mockSettingsProvider, timeProvider: mockTimeProvider)
    }
    
    func testShouldAutolockNow_lockTime_always() {
        createSUT(autolockTimeout: .always)
        XCTAssert(sut.shouldAutolockNow() == true)
    }
    
    func testShouldAutolockNow_lockTime_never() {
        createSUT(autolockTimeout: .never)
        XCTAssert(sut.shouldAutolockNow() == false)
    }
    
    func testShouldAutolockNow_lockTime_minutes_countdownNotStarted() {
        createSUT(autolockTimeout: .minutes(autolockTimeInMinutes))
        XCTAssert(sut.shouldAutolockNow() == false)
    }
    
    func testShouldAutolockNow_lockTime_minutes_countdownReleased() {
        createSUT(autolockTimeout: .minutes(autolockTimeInMinutes))
        sut.startCountdown()
        mockTimeProvider.addSecondsToDateAndUptime(seconds: autolockTimeInSeconds + 1)
        sut.releaseCountdown()
        XCTAssert(sut.shouldAutolockNow() == false)
    }

    func testShouldAutolockNow_lockTime_minutes_whenTimeHasPassed() {
        createSUT(autolockTimeout: .minutes(autolockTimeInMinutes))
        sut.startCountdown()
        mockTimeProvider.addSecondsToDateAndUptime(seconds: autolockTimeInSeconds + 1)
        XCTAssert(sut.shouldAutolockNow() == true)
    }

    func testShouldAutolockNow_lockTime_minutes_whenTimeHasNotPassed() {
        createSUT(autolockTimeout: .minutes(autolockTimeInMinutes))
        sut.startCountdown()
        mockTimeProvider.addSecondsToDateAndUptime(seconds: autolockTimeInSeconds - 1)
        XCTAssert(sut.shouldAutolockNow() == false)
    }

    func testShouldAutolockNow_lockTime_minutes_whenTimeHasNotPassedButTimeWasTampered() {
        createSUT(autolockTimeout: .minutes(autolockTimeInMinutes))
        sut.startCountdown()
        mockTimeProvider.addSecondsOnlyToDate(seconds: autolockTimeInSeconds - 1)
        XCTAssert(sut.shouldAutolockNow() == true)
    }

    func testShouldAutolockNow_lockTime_minutes_whenNoSignsOfTamperingButDateIsInThePast() {
        createSUT(autolockTimeout: .minutes(autolockTimeInMinutes))
        sut.startCountdown()
        mockTimeProvider.addSecondsToDateAndUptime(seconds: -100)
        XCTAssert(sut.shouldAutolockNow() == true)
    }
}
