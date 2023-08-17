//
//  PMChallengeTests.swift
//  ProtonCore-Challenge-Tests - Created on 6/19/20.
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

#if os(iOS)

import XCTest
import UIKit
import ProtonCoreLog
@testable import ProtonCoreUIFoundations
@testable import ProtonCoreChallenge

final class PMChallengeTests: XCTestCase {
    func testSingleton() {
        let shared1 = PMChallenge.shared()
        let addr1 = Unmanaged.passUnretained(shared1).toOpaque()
        
        let shared2 = PMChallenge.shared()
        let addr2 = Unmanaged.passUnretained(shared2).toOpaque()
        XCTAssertTrue(addr1 == addr2)
    }
    
    func testRelease() {
        let shared1 = PMChallenge.shared()
        let addr1 = Unmanaged.passUnretained(shared1).toOpaque()
        PMChallenge.release()
        
        let shared2 = PMChallenge.shared()
        let addr2 = Unmanaged.passUnretained(shared2).toOpaque()
        XCTAssertTrue(addr1 != addr2)
    }
    
    func testStorageCapacity() {
        let capacity = FileManager.deviceCapacity()
        XCTAssertNotNil(capacity, "Capacity is nil, find another way to fetch it")
    }
    
    func testIsJailbreak() {
        let isJailbreak = FileManager.isJailbreak()
        XCTAssertNotNil(isJailbreak, "isJailbreak is nil, find another way to fetch it")
    }
    
    func testTextFieldDelegateInterceptor() {
        let obj = MockObject()
        let textField = UITextField()
        textField.delegate = obj
        XCTAssertNoThrow(try PMChallenge.shared().observeTextField(textField, type: .username), "Should not throw error")
        let interceptor = textField.delegate as? TextFieldDelegateInterceptor
        XCTAssertNotNil(interceptor, "Replace textfield delegate failed")
        XCTAssertEqual(interceptor?.type, PMChallenge.TextFieldType.username, "TextField type is not equal")
    }
    
    func testChallengeFetchValue() {
        final class TestDevice: UIDevice {
            override var name: String { "test device" }
        }
        var challenge = PMChallenge.Challenge()
        let device = TestDevice()
        let locale = Locale(identifier: "en_US")
        let timeZone = TimeZone(identifier: "Europe/Zurich")!
        challenge.fetchValues(device: device, locale: locale, timeZone: timeZone)
        XCTAssertEqual(challenge.deviceFingerprint.deviceName, "test device".rollingHash(), "device name")
        XCTAssertEqual(challenge.deviceFingerprint.appLang, "en", "app lang")
        XCTAssertEqual(challenge.deviceFingerprint.regionCode, "US", "region code")
        XCTAssertEqual(challenge.deviceFingerprint.timezone, "Europe/Zurich", "timezone")
        XCTAssertEqual(challenge.deviceFingerprint.timezoneOffset, -1 * (timeZone.secondsFromGMT() / 60), "timezone offset")
        XCTAssertNotEqual(challenge.deviceFingerprint.keyboards, [], "keyboard")
    }
    
    func testChallengeFetchValueDictionary() {
        final class TestDevice: UIDevice {
            override var name: String { "test device" }
        }
        var challenge = PMChallenge.Challenge()
        let device = TestDevice()
        let locale = Locale(identifier: "en_US")
        let timeZone = TimeZone(identifier: "Europe/Zurich")!
        challenge.fetchValues(device: device, locale: locale, timeZone: timeZone)
        let dictionary = try? challenge.asDictionary()
        XCTAssertEqual(dictionary?["deviceName"] as? Int, "test device".rollingHash(), "device name")
        XCTAssertEqual(dictionary?["appLang"] as? String, "en", "app lang")
        XCTAssertEqual(dictionary?["regionCode"] as? String, "US", "region code")
        XCTAssertEqual(dictionary?["timezone"] as? String, "Europe/Zurich", "timezone")
        XCTAssertEqual(dictionary?["deviceName"] as? Int, "test device".rollingHash(), "device name")
        XCTAssertEqual(dictionary?["timezoneOffset"] as? Int, -1 * (timeZone.secondsFromGMT() / 60), "timezone offset")
        XCTAssertNotEqual(dictionary?["keyboards"] as? [String], [], "keyboard")
        XCTAssertEqual(dictionary?["cellulars"] as? [String], [], "cellulars")
        XCTAssertNotEqual(dictionary?["preferredContentSize"] as? String, "", "preferredContentSize")
        XCTAssertNotNil(dictionary?["preferredContentSize"] as? String, "preferredContentSize")
        XCTAssertNotNil(dictionary?["isDarkmodeOn"] as? Int, "isDarkmodeOn")
        XCTAssertNotEqual(dictionary?["uuid"] as? String, "", "uuid")
        XCTAssertNotNil(dictionary?["uuid"] as? String, "uuid")
        XCTAssertNotEqual(dictionary?["v"] as? String, "", "version")
        XCTAssertNotNil(dictionary?["v"] as? String, "version")
    }
    
    func testChallengeExport() {
        var challenge = PMChallenge.Challenge()
        challenge.fetchValues()
        
        XCTAssertNoThrow(try challenge.asString())
        XCTAssertNoThrow(try challenge.asDictionary())
    }
    
    func testTypeUsername() {
        let challenge = PMChallenge.shared()
        let textField = PMTextField()
        let gr = UIGestureRecognizer()
        XCTAssertNoThrow(try textField.setUpChallenge(challenge, type: .username))
        guard let interceptor = challenge.getInterceptor(textField: textField.textField) else {
            XCTFail("Interceptor not found")
            return
        }
        
        // begin editing textField
        _ = interceptor.textField?.delegate?.textFieldShouldBeginEditing?(textField.textField)
        _ = interceptor.textField?.delegate?.textFieldDidBeginEditing?(textField.textField)
        
        // click on textField 2x
        _ = interceptor.gestureRecognizerShouldBegin(gr)
        _ = interceptor.gestureRecognizerShouldBegin(gr)
        
        // type a, b, c
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "b")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "c")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)

        let expectation1 = self.expectation(description: "Wait for delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation1.fulfill()
            
            // end editing textField
            _ = interceptor.textField?.delegate?.textFieldShouldEndEditing?(textField.textField)
            _ = interceptor.textField?.delegate?.textFieldDidEndEditing?(textField.textField)
            
            let dictArray = PMChallenge.shared().export().allFingerprintDict()
            guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"), let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
                XCTFail("username, or recovery frame not found")
                return
            }
            let nameDict = dictArray[nameIndex]
            XCTAssertNotNil(nameDict["timeUsername"])
            XCTAssertEqual(nameDict["timeUsername"] as? [Int], [1])
            XCTAssertNotNil(nameDict["clickUsername"])
            XCTAssertEqual(nameDict["clickUsername"] as? Int, 2)
            XCTAssertNotNil(nameDict["keydownUsername"])
            XCTAssertEqual(nameDict["keydownUsername"] as? [String], ["a", "b", "c"])
            XCTAssertNotNil(nameDict["pasteUsername"])
            XCTAssertEqual(nameDict["pasteUsername"] as? [String], [])
            XCTAssertNotNil(nameDict["copyUsername"])
            XCTAssertEqual(nameDict["copyUsername"] as? [String], [])
            XCTAssertNil(nameDict["timeRecovery"])
            XCTAssertNil(nameDict["clickRecovery"])
            XCTAssertNil(nameDict["keydownRecovery"])
            XCTAssertNil(nameDict["pasteRecovery"])
            XCTAssertNil(nameDict["copyRecovery"])
            let recoveryDict = dictArray[recoveryIndex]
            XCTAssertNotNil(recoveryDict["timeRecovery"])
            XCTAssertEqual(recoveryDict["timeRecovery"] as? [Int], [])
            XCTAssertNotNil(recoveryDict["clickRecovery"])
            XCTAssertEqual(recoveryDict["clickRecovery"] as? Int, 0)
            XCTAssertNotNil(recoveryDict["keydownRecovery"])
            XCTAssertEqual(recoveryDict["keydownRecovery"] as? [String], [])
            XCTAssertNotNil(recoveryDict["pasteRecovery"])
            XCTAssertEqual(recoveryDict["pasteRecovery"] as? [String], [])
            XCTAssertNotNil(recoveryDict["copyRecovery"])
            XCTAssertEqual(recoveryDict["copyRecovery"] as? [String], [])
            XCTAssertNil(recoveryDict["timeUsername"])
            XCTAssertNil(recoveryDict["clickUsername"])
            XCTAssertNil(recoveryDict["keydownUsername"])
            XCTAssertNil(recoveryDict["pasteUsername"])
            XCTAssertNil(recoveryDict["copyUsername"])
        }
        self.waitForExpectations(timeout: 2) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testPasteUsername() {
        let challenge = PMChallenge.shared()
        let textField = PMTextField()
        XCTAssertNoThrow(try textField.setUpChallenge(challenge, type: .username))
        guard let interceptor = challenge.getInterceptor(textField: textField.textField) else {
            XCTFail("Interceptor not found")
            return
        }
        
        // begin editing textField
        _ = interceptor.textField?.delegate?.textFieldShouldBeginEditing?(textField.textField)
        _ = interceptor.textField?.delegate?.textFieldDidBeginEditing?(textField.textField)
        
        // click on textField
        _ = interceptor.gestureRecognizerShouldBegin(UIGestureRecognizer())
        
        // paste aabbcc
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "aabbcc")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)

        // type c
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "c")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)

        let expectation1 = self.expectation(description: "Wait for delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation1.fulfill()
            
            // end editing textField
            _ = interceptor.textField?.delegate?.textFieldShouldEndEditing?(textField.textField)
            _ = interceptor.textField?.delegate?.textFieldDidEndEditing?(textField.textField)
            
            let dictArray = PMChallenge.shared().export().allFingerprintDict()
            guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"), let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
                XCTFail("username, or recovery frame not found")
                return
            }
            let nameDict = dictArray[nameIndex]
            XCTAssertNotNil(nameDict["timeUsername"])
            XCTAssertEqual(nameDict["timeUsername"] as? [Int], [1])
            XCTAssertNotNil(nameDict["clickUsername"])
            XCTAssertEqual(nameDict["clickUsername"] as? Int, 1)
            XCTAssertNotNil(nameDict["keydownUsername"])
            XCTAssertEqual(nameDict["keydownUsername"] as? [String], ["Paste", "c"])
            XCTAssertNotNil(nameDict["pasteUsername"])
            XCTAssertEqual(nameDict["pasteUsername"] as? [String], ["aabbcc"])
            XCTAssertNotNil(nameDict["copyUsername"])
            XCTAssertEqual(nameDict["copyUsername"] as? [String], [])
            XCTAssertNil(nameDict["timeRecovery"])
            XCTAssertNil(nameDict["clickRecovery"])
            XCTAssertNil(nameDict["keydownRecovery"])
            XCTAssertNil(nameDict["pasteRecovery"])
            XCTAssertNil(nameDict["copyRecovery"])
            let recoveryDict = dictArray[recoveryIndex]
            XCTAssertNotNil(recoveryDict["timeRecovery"])
            XCTAssertEqual(recoveryDict["timeRecovery"] as? [Int], [])
            XCTAssertNotNil(recoveryDict["clickRecovery"])
            XCTAssertEqual(recoveryDict["clickRecovery"] as? Int, 0)
            XCTAssertNotNil(recoveryDict["keydownRecovery"])
            XCTAssertEqual(recoveryDict["keydownRecovery"] as? [String], [])
            XCTAssertNotNil(recoveryDict["pasteRecovery"])
            XCTAssertEqual(recoveryDict["pasteRecovery"] as? [String], [])
            XCTAssertNotNil(recoveryDict["copyRecovery"])
            XCTAssertEqual(recoveryDict["copyRecovery"] as? [String], [])
            XCTAssertNil(recoveryDict["timeUsername"])
            XCTAssertNil(recoveryDict["clickUsername"])
            XCTAssertNil(recoveryDict["keydownUsername"])
            XCTAssertNil(recoveryDict["pasteUsername"])
            XCTAssertNil(recoveryDict["copyUsername"])
        }
        self.waitForExpectations(timeout: 2) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTypeRecovery() {
        let challenge = PMChallenge.shared()
        let textField = PMTextField()
        let gr = UIGestureRecognizer()
        XCTAssertNoThrow(try textField.setUpChallenge(challenge, type: .recoveryMail))
        guard let interceptor = challenge.getInterceptor(textField: textField.textField) else {
            XCTFail("Interceptor not found")
            return
        }
        
        // begin editing textField
        _ = interceptor.textField?.delegate?.textFieldShouldBeginEditing?(textField.textField)
        _ = interceptor.textField?.delegate?.textFieldDidBeginEditing?(textField.textField)
        
        // click on textField 2x
        _ = interceptor.gestureRecognizerShouldBegin(gr)
        _ = interceptor.gestureRecognizerShouldBegin(gr)
        
        // type x, y, z
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "x")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "y")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "z")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)

        let expectation1 = self.expectation(description: "Wait for delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation1.fulfill()
        
            // end editing textField
            _ = interceptor.textField?.delegate?.textFieldShouldEndEditing?(textField.textField)
            _ = interceptor.textField?.delegate?.textFieldDidEndEditing?(textField.textField)
            
            let dictArray = PMChallenge.shared().export().allFingerprintDict()
            guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"), let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
                XCTFail("username, or recovery frame not found")
                return
            }
            let nameDict = dictArray[nameIndex]
            XCTAssertNotNil(nameDict["timeUsername"])
            XCTAssertEqual(nameDict["timeUsername"] as? [Int], [])
            XCTAssertNotNil(nameDict["clickUsername"])
            XCTAssertEqual(nameDict["clickUsername"] as? Int, 0)
            XCTAssertNotNil(nameDict["keydownUsername"])
            XCTAssertEqual(nameDict["keydownUsername"] as? [String], [])
            XCTAssertNotNil(nameDict["pasteUsername"])
            XCTAssertEqual(nameDict["pasteUsername"] as? [String], [])
            XCTAssertNotNil(nameDict["copyUsername"])
            XCTAssertEqual(nameDict["copyUsername"] as? [String], [])
            XCTAssertNil(nameDict["timeRecovery"])
            XCTAssertNil(nameDict["clickRecovery"])
            XCTAssertNil(nameDict["keydownRecovery"])
            XCTAssertNil(nameDict["pasteRecovery"])
            XCTAssertNil(nameDict["copyRecovery"])
            let recoveryDict = dictArray[recoveryIndex]
            XCTAssertNotNil(recoveryDict["timeRecovery"])
            XCTAssertEqual(recoveryDict["timeRecovery"] as? [Int], [1])
            XCTAssertNotNil(recoveryDict["clickRecovery"])
            XCTAssertEqual(recoveryDict["clickRecovery"] as? Int, 2)
            XCTAssertNotNil(recoveryDict["keydownRecovery"])
            XCTAssertEqual(recoveryDict["keydownRecovery"] as? [String], ["x", "y", "z"])
            XCTAssertNotNil(recoveryDict["pasteRecovery"])
            XCTAssertEqual(recoveryDict["pasteRecovery"] as? [String], [])
            XCTAssertNotNil(recoveryDict["copyRecovery"])
            XCTAssertEqual(recoveryDict["copyRecovery"] as? [String], [])
            XCTAssertNil(recoveryDict["timeUsername"])
            XCTAssertNil(recoveryDict["clickUsername"])
            XCTAssertNil(recoveryDict["keydownUsername"])
            XCTAssertNil(recoveryDict["pasteUsername"])
            XCTAssertNil(recoveryDict["copyUsername"])
        }
        self.waitForExpectations(timeout: 2) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testPasteRecovery() {
        let challenge = PMChallenge.shared()
        let textField = PMTextField()
        XCTAssertNoThrow(try textField.setUpChallenge(challenge, type: .recoveryPhone))
        guard let interceptor = challenge.getInterceptor(textField: textField.textField) else {
            XCTFail("Interceptor not found")
            return
        }
        
        // begin editing textField
        _ = interceptor.textField?.delegate?.textFieldShouldBeginEditing?(textField.textField)
        _ = interceptor.textField?.delegate?.textFieldDidBeginEditing?(textField.textField)
        
        // click on textField
        _ = interceptor.gestureRecognizerShouldBegin(UIGestureRecognizer())
        
        // type 1
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "1")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)
        // paste 008800
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "008800")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)
        // type 9
        _ = interceptor.textField?.delegate?.textField!(textField.textField, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "9")
        _ = interceptor.textField?.delegate?.textFieldDidChangeSelection?(textField.textField)

        let expectation1 = self.expectation(description: "Wait for delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation1.fulfill()
            
            // end editing textField
            _ = interceptor.textField?.delegate?.textFieldShouldEndEditing?(textField.textField)
            _ = interceptor.textField?.delegate?.textFieldDidEndEditing?(textField.textField)
            
            let dictArray = PMChallenge.shared().export().allFingerprintDict()
            guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"), let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
                XCTFail("username, or recovery frame not found")
                return
            }
            let nameDict = dictArray[nameIndex]
            XCTAssertNotNil(nameDict["timeUsername"])
            XCTAssertEqual(nameDict["timeUsername"] as? [Int], [])
            XCTAssertNotNil(nameDict["clickUsername"])
            XCTAssertEqual(nameDict["clickUsername"] as? Int, 0)
            XCTAssertNotNil(nameDict["keydownUsername"])
            XCTAssertEqual(nameDict["keydownUsername"] as? [String], [])
            XCTAssertNotNil(nameDict["pasteUsername"])
            XCTAssertEqual(nameDict["pasteUsername"] as? [String], [])
            XCTAssertNotNil(nameDict["copyUsername"])
            XCTAssertEqual(nameDict["copyUsername"] as? [String], [])
            XCTAssertNil(nameDict["timeRecovery"])
            XCTAssertNil(nameDict["clickRecovery"])
            XCTAssertNil(nameDict["keydownRecovery"])
            XCTAssertNil(nameDict["pasteRecovery"])
            XCTAssertNil(nameDict["copyRecovery"])
            let recoveryDict = dictArray[recoveryIndex]
            XCTAssertNotNil(recoveryDict["timeRecovery"])
            XCTAssertEqual(recoveryDict["timeRecovery"] as? [Int], [1])
            XCTAssertNotNil(recoveryDict["clickRecovery"])
            XCTAssertEqual(recoveryDict["clickRecovery"] as? Int, 1)
            XCTAssertNotNil(recoveryDict["keydownRecovery"])
            XCTAssertEqual(recoveryDict["keydownRecovery"] as? [String], ["1", "Paste", "9"])
            XCTAssertNotNil(recoveryDict["pasteRecovery"])
            XCTAssertEqual(recoveryDict["pasteRecovery"] as? [String], ["008800"])
            XCTAssertNotNil(recoveryDict["copyRecovery"])
            XCTAssertEqual(recoveryDict["copyRecovery"] as? [String], [])
            XCTAssertNil(recoveryDict["timeUsername"])
            XCTAssertNil(recoveryDict["clickUsername"])
            XCTAssertNil(recoveryDict["keydownUsername"])
            XCTAssertNil(recoveryDict["pasteUsername"])
            XCTAssertNil(recoveryDict["copyUsername"])
        }
        self.waitForExpectations(timeout: 2) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testTypeUsernameAndRecovery() {
        let challenge = PMChallenge.shared()
        let usernameTextField = PMTextField()
        let recoveryMailTextField = PMTextField()
        let usernameGr = UIGestureRecognizer()
        let recoveryMailGr = UIGestureRecognizer()
        XCTAssertNoThrow(try usernameTextField.setUpChallenge(challenge, type: .username))
        XCTAssertNoThrow(try recoveryMailTextField.setUpChallenge(challenge, type: .recoveryMail))
        guard let usernameInterceptor = challenge.getInterceptor(textField: usernameTextField.textField),
              let recoveryMailInterceptor = challenge.getInterceptor(textField: recoveryMailTextField.textField) else {
            XCTFail("Interceptor not found")
            return
        }

        // begin editing username textField
        _ = usernameInterceptor.textField?.delegate?.textFieldShouldBeginEditing?(usernameTextField.textField)
        _ = usernameInterceptor.textField?.delegate?.textFieldDidBeginEditing?(usernameTextField.textField)

        // click on username textField
        _ = usernameInterceptor.gestureRecognizerShouldBegin(usernameGr)

        // type username a, b
        _ = usernameInterceptor.textField?.delegate?.textField!(usernameTextField.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a")
        _ = usernameInterceptor.textField?.delegate?.textFieldDidChangeSelection?(usernameTextField.textField)
        _ = usernameInterceptor.textField?.delegate?.textField!(usernameTextField.textField, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "b")
        _ = usernameInterceptor.textField?.delegate?.textFieldDidChangeSelection?(usernameTextField.textField)

        let usernameExpectation = self.expectation(description: "Wait for username delay")
        let recoveryMailExpectation = self.expectation(description: "Wait for recoveryMail delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            usernameExpectation.fulfill()

            // end editing username textField
            _ = usernameInterceptor.textField?.delegate?.textFieldShouldEndEditing?(usernameTextField.textField)
            _ = usernameInterceptor.textField?.delegate?.textFieldDidEndEditing?(usernameTextField.textField)

            // begin editing recoveryMail textField
            _ = recoveryMailInterceptor.textField?.delegate?.textFieldShouldBeginEditing?(recoveryMailTextField.textField)
            _ = recoveryMailInterceptor.textField?.delegate?.textFieldDidBeginEditing?(recoveryMailTextField.textField)

            // click on recoveryMail textField
            _ = recoveryMailInterceptor.gestureRecognizerShouldBegin(recoveryMailGr)

            // type recoveryMail c, d
            _ = recoveryMailInterceptor.textField?.delegate?.textField!(recoveryMailTextField.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "c")
            _ = recoveryMailInterceptor.textField?.delegate?.textFieldDidChangeSelection?(recoveryMailTextField.textField)
            _ = recoveryMailInterceptor.textField?.delegate?.textField!(recoveryMailTextField.textField, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "d")
            _ = recoveryMailInterceptor.textField?.delegate?.textFieldDidChangeSelection?(recoveryMailTextField.textField)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                recoveryMailExpectation.fulfill()

                // end editing recoveryMail textField
                _ = recoveryMailInterceptor.textField?.delegate?.textFieldShouldEndEditing?(recoveryMailTextField.textField)
                _ = recoveryMailInterceptor.textField?.delegate?.textFieldDidEndEditing?(recoveryMailTextField.textField)
                
                let dictArray = PMChallenge.shared().export().allFingerprintDict()
                guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"), let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
                    XCTFail("username, or recovery frame not found")
                    return
                }
                let nameDict = dictArray[nameIndex]
                XCTAssertNotNil(nameDict["timeUsername"])
                XCTAssertEqual(nameDict["timeUsername"] as? [Int], [1])
                XCTAssertNotNil(nameDict["clickUsername"])
                XCTAssertEqual(nameDict["clickUsername"] as? Int, 1)
                XCTAssertNotNil(nameDict["keydownUsername"])
                XCTAssertEqual(nameDict["keydownUsername"] as? [String], ["a", "b"])
                XCTAssertNotNil(nameDict["pasteUsername"])
                XCTAssertEqual(nameDict["pasteUsername"] as? [String], [])
                XCTAssertNotNil(nameDict["copyUsername"])
                XCTAssertEqual(nameDict["copyUsername"] as? [String], [])
                XCTAssertNil(nameDict["timeRecovery"])
                XCTAssertNil(nameDict["clickRecovery"])
                XCTAssertNil(nameDict["keydownRecovery"])
                XCTAssertNil(nameDict["pasteRecovery"])
                XCTAssertNil(nameDict["copyRecovery"])
                let recoveryDict = dictArray[recoveryIndex]
                XCTAssertNotNil(recoveryDict["timeRecovery"])
                XCTAssertEqual(recoveryDict["timeRecovery"] as? [Int], [1])
                XCTAssertNotNil(recoveryDict["clickRecovery"])
                XCTAssertEqual(recoveryDict["clickRecovery"] as? Int, 1)
                XCTAssertNotNil(recoveryDict["keydownRecovery"])
                XCTAssertEqual(recoveryDict["keydownRecovery"] as? [String], ["c", "d"])
                XCTAssertNotNil(recoveryDict["pasteRecovery"])
                XCTAssertEqual(recoveryDict["pasteRecovery"] as? [String], [])
                XCTAssertNotNil(recoveryDict["copyRecovery"])
                XCTAssertEqual(recoveryDict["copyRecovery"] as? [String], [])
                XCTAssertNil(recoveryDict["timeUsername"])
                XCTAssertNil(recoveryDict["clickUsername"])
                XCTAssertNil(recoveryDict["keydownUsername"])
                XCTAssertNil(recoveryDict["pasteUsername"])
                XCTAssertNil(recoveryDict["copyUsername"])
            }
        }
        self.waitForExpectations(timeout: 4) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func test_allFingerprintDict_keysSet() {
        let dictArray = PMChallenge.shared().export().allFingerprintDict()
        guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"),
              let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
            XCTFail("username, or recovery frame not found")
            return
        }
        let nameDict = dictArray[nameIndex]
        let recoveryDict = dictArray[recoveryIndex]
        XCTAssertEqual(nameDict.keysSet, Set(["isDarkmodeOn", "deviceName", "appLang", "keydownUsername", "timezone", "uuid", "regionCode", "copyUsername", "frame", "pasteUsername", "keyboards", "storageCapacity", "isJailbreak", "v", "timeUsername", "clickUsername", "preferredContentSize", "cellulars", "timezoneOffset"]))
        XCTAssertEqual(recoveryDict.keysSet, Set(["isDarkmodeOn", "deviceName", "appLang", "timezone", "uuid", "regionCode", "frame", "keyboards", "storageCapacity", "isJailbreak", "clickRecovery", "timeRecovery", "pasteRecovery", "v", "preferredContentSize", "cellulars", "keydownRecovery", "timezoneOffset", "copyRecovery"]))
    }
    
    func test_deviceFingerprintDict_keysSet() {
        let dictArray = PMChallenge.shared().export().deviceFingerprintDict()
        guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"),
              let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
            XCTFail("username, or recovery frame not found")
            return
        }
        let nameDict = dictArray[nameIndex]
        let recoveryDict = dictArray[recoveryIndex]
        XCTAssertEqual(nameDict.keysSet, Set(["preferredContentSize", "appLang", "storageCapacity", "deviceName", "isJailbreak", "isDarkmodeOn", "frame", "uuid", "timezone", "cellulars", "timezoneOffset", "regionCode", "keyboards"]))
        XCTAssertEqual(recoveryDict.keysSet, Set(["preferredContentSize", "appLang", "storageCapacity", "deviceName", "isJailbreak", "isDarkmodeOn", "frame", "uuid", "timezone", "cellulars", "timezoneOffset", "regionCode", "keyboards"]))
    }
    
    func test_behaviouralFingerprintDict_keysSet() {
        let dictArray = PMChallenge.shared().export().behaviouralFingerprintDict()
        guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"),
              let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
            XCTFail("username, or recovery frame not found")
            return
        }
        let nameDict = dictArray[nameIndex]
        let recoveryDict = dictArray[recoveryIndex]
        XCTAssertEqual(nameDict.keysSet, Set(["pasteUsername", "v", "frame", "clickUsername", "keydownUsername", "timeUsername", "copyUsername"]))
        XCTAssertEqual(recoveryDict.keysSet, Set(["pasteRecovery", "v", "frame", "clickRecovery", "timeRecovery", "copyRecovery", "keydownRecovery"]))
    }
    
    func test_deviceFingerprintDict_keysValue() {
        let dictArray = PMChallenge.shared().export().deviceFingerprintDict()
        guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username") else {
            XCTFail("username, or recovery frame not found")
            return
        }
        
        let nameDict = dictArray[nameIndex]
        
        XCTAssertEqual(nameDict["isJailbreak"] as? Bool, false)
        XCTAssertEqual(nameDict["isDarkmodeOn"] as? Bool, false)
        
        XCTAssertTrue(matches(pattern: "[a-zA-Z_]+", inputString: nameDict["appLang"] as? String))
        XCTAssertTrue(matches(pattern: "UICTContentSizeCategory[a-zA-Z]+", inputString: nameDict["preferredContentSize"] as? String))
        XCTAssertTrue(matches(pattern: "[A-Z]+", inputString: nameDict["regionCode"] as? String))
        XCTAssertTrue(matches(pattern: "-?([0-9]+[.])?[0-9]+", inputString: String(nameDict["storageCapacity"] as? Double ?? 0)))
        XCTAssertTrue(matches(pattern: "-?([0-9]+)", inputString: String(nameDict["deviceName"] as? Int ?? 0)))
        XCTAssertTrue(matches(pattern: #"^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$"#, inputString: nameDict["uuid"] as? String))
        XCTAssertTrue(matches(pattern: "[A-Z]+[a-z]?(/[A-Z]+[a-z]?)?", inputString: nameDict["timezone"] as? String))
        XCTAssertTrue(matches(pattern: "-?([0-9]+)", inputString: String(nameDict["timezoneOffset"] as? Int ?? 0)))
        (nameDict["keyboards"] as! [String]).forEach { keyboard in
            XCTAssertTrue(matches(pattern: "[a-zA-Z_]+@sw=[a-zA-Z]+.*", inputString: keyboard))
        }
    }
    
    func test_behaviouralFingerprintDict_keysValue() {
        let dictArray = PMChallenge.shared().export().behaviouralFingerprintDict()
        guard let nameIndex = self.findIndex(dictArray: dictArray, frameName: "username"),
              let recoveryIndex = self.findIndex(dictArray: dictArray, frameName: "recovery") else {
            XCTFail("username, or recovery frame not found")
            return
        }
        let nameDict = dictArray[nameIndex]
        let recoveryDict = dictArray[recoveryIndex]
        XCTAssertEqual(nameDict["pasteUsername"] as? [String], [])
        XCTAssertEqual(nameDict["v"] as? String, "2.0.3")
        
        XCTAssertEqual(nameDict["clickUsername"] as? Int, 0)
        XCTAssertEqual(nameDict["keydownUsername"] as? [String], [])
        XCTAssertEqual(nameDict["timeUsername"] as? [Int], [])
        XCTAssertEqual(nameDict["copyUsername"] as? [String], [])
        XCTAssertEqual(recoveryDict["pasteRecovery"] as? [String], [])
        XCTAssertEqual(recoveryDict["clickRecovery"] as? Int, 0)
        XCTAssertEqual(recoveryDict["timeRecovery"] as? [Int], [])
        XCTAssertEqual(recoveryDict["copyRecovery"] as? [String], [])
        XCTAssertEqual(recoveryDict["keydownRecovery"] as? [String], [])
    }
}

// MARK: - Tools
extension PMChallengeTests {
    private func matches(pattern: String, inputString: String?) -> Bool {
        guard let string = inputString else { return false }
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.firstMatch(in: string, options: [], range: range) != nil
        } catch {
            return false
        }
    }
    
    private func findIndex(dictArray: [[String: Any]], frameName: String) -> Int? {
        for (index, dict) in dictArray.enumerated() {
            let frame = dict["frame"] as? [String: String]
            if frameName == frame?["name"] {
                PMLog.debug("\(index)")
                return index
            }
        }
        return nil
    }
}

private extension Dictionary where Key == String, Value == Any {
    var keysSet: Set<String> {
        self.keys
            .compactMap { String($0) }
            .reduce(Set<String>()) {
                var set = $0
                set.insert($1)
                return set
            }
    }
}

#endif
