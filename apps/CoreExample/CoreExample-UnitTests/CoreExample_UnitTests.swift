//
//  CoreExample_UnitTests.swift
//  CoreExample-UnitTests - Created on 24/05/2021.
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

import XCTest
import ProtonCore_Authentication
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_TestingToolkit

class SampleDelegateMock: APIServiceDelegate {
    var locale: String { return "en_US" }
    
    @FuncStub(SampleDelegateMock.asd as (SampleDelegateMock) -> (Any) -> Void) var completionWithResultStub
    func asd<T>(dsa: T) {
//        let dsa = SampleDelegateMock.asd
        completionWithResultStub(dsa)
        return // completionWithResultStub(dsa)
    }

    @FuncStub(SampleDelegateMock.onUpdate) var onUpdateStub
    func onUpdate(serverTime: Int64) { onUpdateStub(serverTime) }

    @FuncStub(SampleDelegateMock.isReachable, initialReturn: .crash) var isReachableStub
    func isReachable() -> Bool { isReachableStub() }

    @PropertyStub(\SampleDelegateMock.appVersion, initialGet: .empty) var appVersionStub
    var appVersion: String { get { appVersionStub() } set { appVersionStub(newValue) } }

    var userAgent: String?

    func onDohTroubleshot() {}

}

struct SampleServiceUsingSomeCoreObjects {

    weak var delegate: APIServiceDelegate? = nil
    let authenticator: AuthenticatorInterface

    func trueIfReachable() -> Bool {
        delegate?.isReachable() ?? false
    }

    func fetchUser(completion: @escaping (Result<User, AuthErrors>) -> Void) {
        authenticator.getUserInfo(completion: completion)
    }
}

final class SampleTestingToolkitTestsTests: XCTestCase {

    func testFalseIfNoDelegate() {
        let out = SampleServiceUsingSomeCoreObjects(authenticator: AuthenticatorMock())
        XCTAssertFalse(out.trueIfReachable())
    }

    func testFalseIfDelegateIsNotReachable() {
        let delegateMock = SampleDelegateMock()
        var out = SampleServiceUsingSomeCoreObjects(authenticator: AuthenticatorMock())
        out.delegate = delegateMock
        delegateMock.asd(dsa: 1)
        delegateMock.isReachableStub.bodyIs { _ in false }
        XCTAssertFalse(out.trueIfReachable())
        XCTAssertTrue(delegateMock.isReachableStub.wasCalledExactlyOnce)
    }

    func testTrueIfDelegateIsReachable() {
        let delegateMock = SampleDelegateMock()
        var out = SampleServiceUsingSomeCoreObjects(authenticator: AuthenticatorMock())
        out.delegate = delegateMock
        delegateMock.isReachableStub.bodyIs { _ in true }
        XCTAssertTrue(out.trueIfReachable())
        XCTAssertTrue(delegateMock.isReachableStub.wasCalledExactlyOnce)
    }

    func testIfFetchingUserGetsUserInfo() {
        let authenticatorMock = AuthenticatorMock()
        let out = SampleServiceUsingSomeCoreObjects(delegate: SampleDelegateMock(), authenticator: authenticatorMock)
        out.fetchUser { _ in }
        XCTAssertTrue(authenticatorMock.getUserInfoStub.wasCalledExactlyOnce)
    }

    func testIfFetchingUserPassesTheUserFromAPI() {
        let authenticatorMock = AuthenticatorMock()
        let out = SampleServiceUsingSomeCoreObjects(delegate: SampleDelegateMock(), authenticator: authenticatorMock)
        let testUser: User = .dummy.updated(ID: "test id for \(#function)")
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }
        out.fetchUser { result in
            guard case let .success(resultUser) = result else { XCTFail(); return }
            XCTAssertEqual(resultUser.ID, testUser.ID)
        }
    }

    func testIfFetchingUserPassesTheErrorFromAPI() {
        let authenticatorMock = AuthenticatorMock()
        let out = SampleServiceUsingSomeCoreObjects(delegate: SampleDelegateMock(), authenticator: authenticatorMock)
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.failure(.notImplementedYet(#function))) }
        out.fetchUser { result in
            guard case let .failure(error) = result else { XCTFail(); return }
            XCTAssertEqual(error.localizedDescription, #function)
        }
    }
}
