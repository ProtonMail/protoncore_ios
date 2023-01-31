//
//  AuthHelperTests.swift
//  ProtonCore-Authentication-Tests - Created on 24/08/2022.
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

import ProtonCore_APIClient
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_TestingToolkit
import ProtonCore_DataModel
@testable import ProtonCore_Authentication
import GoLibs

@available(iOS 13.0.0, *)
class AuthHelperTests: XCTestCase {
    
    let initialCredential = Credential(UID: "test session", accessToken: "test access", refreshToken: "test refresh", userName: "test user name", userID: "test user id", scopes: ["test scope"])
    let initialAuthCredential: AuthCredential = {
        let authCredential = AuthCredential(sessionID: "test session", accessToken: "test access", refreshToken: "test refresh", userName: "test user name", userID: "test user id", privateKey: "test private key", passwordKeySalt: "test salt")
        authCredential.udpate(password: "test password")
        return authCredential
    }()
    
    /// TODO: validation tests???

    /// * that returns initial credentials

    func testAuthHelperReturnsInitialCredential() throws {
        let out = AuthHelper(credential: initialCredential)
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, initialCredential)
        XCTAssertTrue(AuthCredential.areEqualFieldwise(fetchedAuthCredential, AuthCredential(initialCredential)))
    }
    
    /// * that returns initial auth credentials
    
    func testAuthHelperReturnsInitialAuthCredential() throws {
        let out = AuthHelper(authCredential: initialAuthCredential)
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, Credential(initialAuthCredential))
        XCTAssertEqual(fetchedAuthCredential, initialAuthCredential)
    }
    
    /// * that returns initial both credentials
    
    func testAuthHelperReturnsInitialBothCredentials() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, initialCredential)
        XCTAssertEqual(fetchedAuthCredential, initialAuthCredential)
    }
    
    /// * that returns nil if initiated with nil
    
    func testAuthHelperReturnsNilIfInitiatedWithNil() throws {
        let out = AuthHelper()
        XCTAssertNil(out.credential(sessionUID: "test session"))
        XCTAssertNil(out.authCredential(sessionUID: "test session"))
    }
    
    /// * that returns nil if initiated with not matching credentials nil
    
    func testAuthHelperReturnsNilIfInitiatedWithNotMatchingCredentials() throws {
        let out1 = AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential.updated(UID: "wrong session")))
        XCTAssertNil(out1)
        let out2 = AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential.updated(accessToken: "wrong token")))
        XCTAssertNil(out2)
        let out3 = AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential.updated(refreshToken: "wrong token")))
        XCTAssertNil(out3)
        let out4 = AuthHelper(initialBothCredentials: (initialAuthCredential.updated(userName: "wrong user name"), initialCredential))
        XCTAssertNil(out4)
        let out5 = AuthHelper(initialBothCredentials: (initialAuthCredential.updated(userID: "wrong user id"), initialCredential))
        XCTAssertNil(out5)
    }
    
    /// * that returns nil if asked with wrong session
    
    func testAuthHelperReturnsNilIfAskedForWrongSession() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        XCTAssertNil(out.credential(sessionUID: "wrong session"))
        XCTAssertNil(out.authCredential(sessionUID: "wrong session"))
    }
    
    /// * that clears on logout with right session
    
    func testAuthHelperClearsCredentialsOnLogout() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.onLogout(sessionUID: "test session")
        XCTAssertNil(out.credential(sessionUID: "test session"))
        XCTAssertNil(out.authCredential(sessionUID: "test session"))
    }
    
    /// * that doesn't clear on logout with wrong session
    
    func testAuthHelperDoesNotClearCredentialsOnLogoutForWrongSession() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.onLogout(sessionUID: "wrong session")
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, initialCredential)
        XCTAssertEqual(fetchedAuthCredential, initialAuthCredential)
    }
    
    /// * that sets credentials on authentication if no previous credentials
    
    func testAuthHelperSetsCredentialsIfNoPreviousCredentialsWereSet() throws {
        let out = AuthHelper()
        let newCredentials: Credential = .init(UID: "other session", accessToken: "other token", refreshToken: "other refresh", userName: "other username", userID: "other userID", scopes: ["other"])
        
        out.onAuthentication(credential: newCredentials, service: nil)
        
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: newCredentials.UID))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: newCredentials.UID))
        XCTAssertEqual(fetchedCredential, newCredentials)
        XCTAssertTrue(AuthCredential.areEqualFieldwise(fetchedAuthCredential, AuthCredential(newCredentials)))
    }
    
    /// * that sets credentials on authentication if previous credentials of different session
    
    func testAuthHelperSetsCredentialsIfPreviousCredentialsWereWithDifferentSession() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        let newCredentials: Credential = .init(UID: "other session", accessToken: "other token", refreshToken: "other refresh", userName: "other username", userID: "other userID", scopes: ["other"])
        
        out.onAuthentication(credential: newCredentials, service: nil)
        
        XCTAssertNil(out.credential(sessionUID: initialCredential.UID))
        XCTAssertNil(out.authCredential(sessionUID: initialAuthCredential.sessionID))
        
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: newCredentials.UID))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: newCredentials.UID))
        XCTAssertEqual(fetchedCredential, newCredentials)
        XCTAssertTrue(AuthCredential.areEqualFieldwise(fetchedAuthCredential, AuthCredential(newCredentials)))
    }
    
    /// * that sets credentials on authentication if previous credentials of same session
    
    func testAuthHelperSetsCredentialsIfPreviousCredentialsWereWithSameSession() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        let newCredentials: Credential = .init(UID: initialCredential.UID, accessToken: "other token", refreshToken: "other refresh", userName: "other username", userID: "other userID", scopes: ["other"])
        
        out.onAuthentication(credential: newCredentials, service: nil)
        
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: initialCredential.UID))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: initialCredential.UID))
        XCTAssertEqual(fetchedCredential, newCredentials)
        XCTAssertTrue(AuthCredential.areEqualFieldwise(fetchedAuthCredential, AuthCredential(newCredentials)))
    }
    
    /// * that on authentication sets sessionId if api service is provided
    
    func testAuthHelperSetsSessionIdIfApiServiceIsProvided() throws {
        let out = AuthHelper()
        let api = APIServiceMock()
        let newCredentials: Credential = .init(UID: "other session", accessToken: "other token", refreshToken: "other refresh", userName: "other username", userID: "other userID", scopes: ["other"])
        
        out.onAuthentication(credential: newCredentials, service: api)
        
        XCTAssertTrue(api.setSessionUIDStub.wasCalledExactlyOnce)
        XCTAssertEqual(api.setSessionUIDStub.lastArguments?.value, newCredentials.UID)
    }
    
    /// * that updates if no previous credentials
    
    func testAuthHelperUpdatesCredentialsIfNoneWereAvailable() throws {
        let out = AuthHelper()
        out.onUpdate(credential: initialCredential, sessionUID: "test session")
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, initialCredential)
        XCTAssertTrue(AuthCredential.areEqualFieldwise(fetchedAuthCredential, AuthCredential(initialCredential)))
    }
    
    /// * that doesn't update if previous credentials but wrong session
    
    func testAuthHelperDoesNotUpdateCredentialsIfWrongSession() throws {
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.onUpdate(credential: initialCredential, sessionUID: "wrong session")
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, initialCredential)
        XCTAssertEqual(fetchedAuthCredential, initialAuthCredential)
    }
    
    /// * that updates if previous credentials and right session
    
    func testAuthHelperUpdatesCredentialsIfRightSession() throws {
        let newCredentials = Credential(UID: "test session", accessToken: "new access token", refreshToken: "new refresh token", userName: "new username", userID: "new password", scopes: ["new scope"])
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.onUpdate(credential: newCredentials, sessionUID: "test session")
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential, newCredentials)
        XCTAssertTrue(AuthCredential.areEqualFieldwise(fetchedAuthCredential, initialAuthCredential.updatedKeepingKeyAndPasswordDataIntact(credential: newCredentials)))
    }
    
    /// * that doesn't update scopes if none provided
    
    func testAuthHelperDoesNotClearScopesOnUpdate() throws {
        let newCredentials = Credential(UID: "test session", accessToken: "new access token", refreshToken: "new refresh token", userName: "new username", userID: "new password", scopes: [])
        let out = AuthHelper(credential: initialCredential)
        out.onUpdate(credential: newCredentials, sessionUID: "test session")
        let fetchedCredential = try XCTUnwrap(out.credential(sessionUID: "test session"))
        XCTAssertEqual(fetchedCredential.accessToken, "new access token")
        XCTAssertEqual(fetchedCredential.scopes, ["test scope"])
    }
    
    /// * that doesn't update key and password
    
    func testAuthHelperDoesNotUpdateKeyAndPassword() throws {
        let newCredentials = Credential(UID: "test session", accessToken: "new access token", refreshToken: "new refresh token", userName: "new username", userID: "new password", scopes: [])
        let out = AuthHelper(authCredential: initialAuthCredential)
        out.onUpdate(credential: newCredentials, sessionUID: "test session")
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedAuthCredential.accessToken, "new access token")
        XCTAssertEqual(fetchedAuthCredential.mailboxpassword, "test password")
        XCTAssertEqual(fetchedAuthCredential.privateKey, "test private key")
        XCTAssertEqual(fetchedAuthCredential.passwordKeySalt, "test salt")
    }
    
    /// * that updates password, salt, private key
    
    func testAuthHelperDoesUpdateKeyAndPassword() throws {
        let out = AuthHelper(authCredential: initialAuthCredential)
        out.updateAuth(for: "test session", password: "new password", salt: "new salt", privateKey: "new private key")
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedAuthCredential.mailboxpassword, "new password")
        XCTAssertEqual(fetchedAuthCredential.privateKey, "new private key")
        XCTAssertEqual(fetchedAuthCredential.passwordKeySalt, "new salt")
    }
    
    /// * that doesn't update password, salt, private key if wrong session
    
    func testAuthHelperDoesNotUpdateKeyAndPasswordIfWrongSession() throws {
        let out = AuthHelper(authCredential: initialAuthCredential)
        out.updateAuth(for: "wrong session", password: "new password", salt: "new salt", privateKey: "new private key")
        let fetchedAuthCredential = try XCTUnwrap(out.authCredential(sessionUID: "test session"))
        XCTAssertEqual(fetchedAuthCredential.mailboxpassword, "test password")
        XCTAssertEqual(fetchedAuthCredential.privateKey, "test private key")
        XCTAssertEqual(fetchedAuthCredential.passwordKeySalt, "test salt")
    }
    
    /// * that doesn't update password, salt, private key if no previous credentials
    
    func testAuthHelperDoesNotUpdateKeyAndPasswordIfNoPreviousCredentials() throws {
        let out = AuthHelper()
        out.updateAuth(for: "wrong session", password: "new password", salt: "new salt", privateKey: "new private key")
        XCTAssertNil(out.authCredential(sessionUID: "test session"))
    }
    
    /// * delegate is called if credentials are cleared
    
    func testAuthHelperCallsDelegateIfCredentialsAreCleared() throws {
        let delegate = AuthHelperDelegateMock()
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.setUpDelegate(delegate, callingItOn: .immediateExecutor)
        out.onLogout(sessionUID: "test session")
        XCTAssertTrue(delegate.credentialsWereUpdatedStub.wasNotCalled)
        XCTAssertTrue(delegate.sessionWasInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertEqual(delegate.sessionWasInvalidatedStub.lastArguments?.value, "test session")
    }
    
    /// * delegate is called if credentials are updated
    
    func testAuthHelperCallsDelegateIfCredentialsAreUpdated() throws {
        let delegate = AuthHelperDelegateMock()
        let newCredentials = Credential(UID: "test session", accessToken: "new access token", refreshToken: "new refresh token", userName: "new username", userID: "new password", scopes: ["new scope"])
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.setUpDelegate(delegate, callingItOn: .immediateExecutor)
        out.onUpdate(credential: newCredentials, sessionUID: "test session")
        XCTAssertTrue(delegate.sessionWasInvalidatedStub.wasNotCalled)
        XCTAssertTrue(delegate.credentialsWereUpdatedStub.wasCalledExactlyOnce)
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.lastArguments?.a2, newCredentials)
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.lastArguments?.a3, "test session")
    }
    
    func testAuthHelperCallsDelegateIfAuthIsUpdated() throws {
        let delegate = AuthHelperDelegateMock()
        let out = try XCTUnwrap(AuthHelper(initialBothCredentials: (initialAuthCredential, initialCredential)))
        out.setUpDelegate(delegate, callingItOn: .immediateExecutor)
        out.updateAuth(for: "test session", password: "new password", salt: "new salt", privateKey: "new private key")
        XCTAssertTrue(delegate.sessionWasInvalidatedStub.wasNotCalled)
        XCTAssertTrue(delegate.credentialsWereUpdatedStub.wasCalledExactlyOnce)
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.lastArguments?.a1.mailboxpassword, "new password")
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.lastArguments?.a1.passwordKeySalt, "new salt")
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.lastArguments?.a1.privateKey, "new private key")
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.lastArguments?.a3, "test session")
    }
    
    /// TODO: multithreading tests!
    
    func testConcurrentFetching() async throws {
        let out = AuthHelper(authCredential: initialAuthCredential)
        let results: [AuthCredential?] = await performConcurrentlySettingExpectations(amount: 100) { _, continuation in
            let fetchedAuthCredential = out.authCredential(sessionUID: "test session")
            continuation.resume(returning: (fetchedAuthCredential))
        }
        XCTAssertEqual(results.compactMap { $0 }, Array(repeating: initialAuthCredential, count: 100))
    }
    
    func testConcurrentClearing() async throws {
        let delegate = AuthHelperDelegateMock()
        let out = AuthHelper(authCredential: initialAuthCredential)
        out.setUpDelegate(delegate, callingItOn: .immediateExecutor)
        let _: [Void] = await performConcurrentlySettingExpectations(amount: 100) { _, continuation in
            out.onLogout(sessionUID: "test session")
            continuation.resume()
        }
        XCTAssertTrue(delegate.sessionWasInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertTrue(delegate.credentialsWereUpdatedStub.wasNotCalled)
    }
    
    func testConcurrentUpdating() async throws {
        let delegate = AuthHelperDelegateMock()
        let out = AuthHelper(credential: initialCredential)
        out.setUpDelegate(delegate, callingItOn: .immediateExecutor)
        let results: [Credential?] = await performConcurrentlySettingExpectations(amount: 100) { counter, continuation in
            let credential = self.initialCredential.updated(accessToken: "access \(counter)", refreshToken: "refresh \(counter)")
            out.onUpdate(credential: credential, sessionUID: "test session")
            continuation.resume(returning: out.credential(sessionUID: "test session"))
        }
        XCTAssertEqual(delegate.credentialsWereUpdatedStub.callCounter, 100)
        let counters = results.compactMap { $0 }.map { $0.accessToken.replacingOccurrences(of: "access ", with: "") }.map(Int.init)
        XCTAssertEqual(counters, Array(1...100))
        XCTAssertTrue(delegate.sessionWasInvalidatedStub.wasNotCalled)
    }
}
