//
//  LoginSignupTests.swift
//  SampleAppUITests
//
//  Created by Greg on 15.04.21.
//

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands
import ProtonCore_FeatureSwitch
import Alamofire

class LoginSignupTests: LoginBaseTestCase {
    
    lazy var quarkCommands = QuarkCommands(doh: doh)
    let mainRobot = LoginSampleAppRobot()
    
    let password = ObfuscatedConstants.password
    let shortPassword = ObfuscatedConstants.shortPassword
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    let emailVerificationWrongCode = ObfuscatedConstants.emailVerificationWrongCode
    let testEmail = ObfuscatedConstants.testEmail
    let testNumber = ObfuscatedConstants.testNumber
    let exampleCountry = "Swi"
    let exampleCode = "+41"
    let defaultCode = "XXXXXX"
    let existingName = ObfuscatedConstants.existingUsername
    let existingEmail = "\(ObfuscatedConstants.externalUserUsername)@me.com"
    let existingEmailPassword = ObfuscatedConstants.externalUserPassword
    
    var currentFeatures: [Feature] = []
    
    let signupTestCases = SignupUITestCases()
    override func setUp() {
        if let json = self.readLocalFile(forName: #function) {
            self.launchEnvironment = ["FeatureSwitch": json]
        }
        super.setUp()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }
    
    private func readLocalFile(forName name: String) -> String? {
        do {
            if let bundlePath = Bundle(for: LoginSignupTests.self).path(forResource: name, ofType: "json") {
                let jsonData = try String(contentsOfFile: bundlePath)
                return jsonData
            }
        } catch {
            
        }
        return nil
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testCloseButtonExists() {
        let signupRobot = mainRobot.showSignup()
        signupTestCases.testCloseButtonExists(signupRobot: signupRobot)
    }
    
    func testCloseButtonDoesntExist() {
        let signupRobot = mainRobot
            .closeSwitchTap()
            .showSignup()
        signupTestCases.testCloseButtonDoesntExist(signupRobot: signupRobot)
    }
    
    func testBothAccountInt() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.internal))
            .showSignup()
        signupTestCases.testBothAccountInteralFirst(signupRobot: signupRobot)
    }
    
    func testBothAccountExt() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
        signupTestCases.testBothAccountExternalFirst(signupRobot: signupRobot)
    }
    
    func testIntAccountOnly() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .internal)
            .showSignup()
        signupTestCases.testInternalAccountOnly(signupRobot: signupRobot)
    }
    
    func testExtAccountOnly() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .external)
            .showSignup()
        signupTestCases.testExtAccountOnly(signupRobot: signupRobot)
    }
    
    func testBothAccountIntExternalSignupFeatureOff() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.internal))
            .showSignup()
        signupTestCases.testBothAccountIntExternalSignupFeatureOff(signupRobot: signupRobot)
    }
    
    func testBothAccountExtExternalSignupFeatureOff() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
        signupTestCases.testBothAccountExtExternalSignupFeatureOff(signupRobot: signupRobot)
    }
    
    func testIntAccountOnlyExternalSignupFeatureOff() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .internal)
            .showSignup()
        signupTestCases.testIntAccountOnlyExternalSignupFeatureOff(signupRobot: signupRobot)
    }
    
    func testExtAccountOnlyExternalSignupFeatureOff() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .external)
            .showSignup()
        signupTestCases.testExtAccountOnlyExternalSignupFeatureOff(signupRobot: signupRobot)
    }
    
    func testSwitchIntToLogin() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testSwitchIntToLogin(signupRobot: signupRobot)
    }
    
    func testSwitchExtToLogin() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testSwitchExtToLogin(signupRobot: signupRobot)
    }
    
    func testSignupNewIntAccountSuccess() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testSignupNewIntAccountSuccess(signupRobot: signupRobot,
                                                       randomName: randomName,
                                                       password: password,
                                                       randomEmail: randomEmail,
                                                       emailVerificationCode: ObfuscatedConstants.emailVerificationCode)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
    }
    
    func testSignupExistingIntAccount() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.internal))
            .showSignup()
        signupTestCases.testSignupExistingIntAccount(signupRobot: signupRobot, existingName: existingName)
    }
    
    func testSignupNewExtAccountSuccess() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.internal))
            .showSignup()
        signupTestCases.testSignupNewExtAccountSuccess(signupRobot: signupRobot,
                                                       randomEmail: randomEmail,
                                                       password: password,
                                                       emailVerificationCode: emailVerificationCode)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
    }
    
    func testSignupExistingExtAccount() {
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.internal))
            .showSignup()
        signupTestCases.testSignupExistingExtAccount(signupRobot: signupRobot,
                                                     existingEmail: existingEmail,
                                                     existingEmailPassword: existingEmailPassword,
                                                     emailVerificationCode: emailVerificationCode)
    }
    
    func testPasswordVerificationEmpty() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testPasswordVerificationEmpty(signupRobot: signupRobot,
                                                      randomName: randomName)
    }
    
    func testPasswordVerificationTooShort() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testPasswordVerificationTooShort(signupRobot: signupRobot,
                                                         randomName: randomName,
                                                         shortPassword: shortPassword)
    }
    
    func testPasswordVerificationRepeatPasswordEmpty() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testPasswordVerificationRepeatPasswordEmpty(signupRobot: signupRobot,
                                                                    randomName: randomName,
                                                                    password: password)
    }
    
    func testPasswordVerificationPasswordEmpty() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testPasswordVerificationPasswordEmpty(signupRobot: signupRobot,
                                                              randomName: randomName,
                                                              password: password)
    }
    
    func testPasswordsVerificationDoNotMatch() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testPasswordsVerificationDoNotMatch(signupRobot: signupRobot,
                                                            randomName: randomName,
                                                            password: password)
    }
    
    func testRecoveryVerificationEmail() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testRecoveryVerificationEmail(signupRobot: signupRobot,
                                                      randomName: randomName,
                                                      password: password,
                                                      testEmail: testEmail)
    }
    
    func testRecoveryVerificationPhone() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testRecoveryVerificationPhone(signupRobot: signupRobot,
                                                      randomName: randomName,
                                                      password: password,
                                                      testNumber: testNumber)
    }
    
    func testRecoverySelectCountryAndCheckCode() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testRecoverySelectCountryAndCheckCode(signupRobot: signupRobot,
                                                              randomName: randomName,
                                                              password: password,
                                                              exampleCountry: exampleCountry,
                                                              exampleCode: exampleCode)
    }
    
    func testSignupNewIntAccountHVRequired() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testSignupNewIntAccountHVRequired(signupRobot: signupRobot,
                                                          randomName: randomName,
                                                          password: password)
    }
    
    func testSignupNewIntStayInRecoveryMethod() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testSignupNewIntStayInRecoveryMethod(signupRobot: signupRobot,
                                                             randomName: randomName,
                                                             password: password)
    }
    
    func testSignupNewExtSendCodeRequestNewCode() {
        let email = randomEmail
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
        signupTestCases.testSignupNewExtSendCodeRequestNewCode(signupRobot: signupRobot,
                                                               randomEmail: email,
                                                               defaultCode: defaultCode)
    }
    
    func testSignupNewExtSendCodeCancel() {
        let email = randomEmail
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
        signupTestCases.testSignupNewExtSendCodeCancel(signupRobot: signupRobot,
                                                       randomEmail: email)
    }
    
    func testSignupNewExtWrongVerificationCodeResend() {
        let email = randomEmail
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
        signupTestCases.testSignupNewExtWrongVerificationCodeResend(signupRobot: signupRobot,
                                                                    randomEmail: email,
                                                                    emailVerificationWrongCode: emailVerificationWrongCode,
                                                                    defaultCode: defaultCode)
    }
    
    func testSignupNewExtWrongVerificationCodeChangeEmail() {
        let email = randomEmail
        let signupRobot = mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
        signupTestCases.testSignupNewExtWrongVerificationCodeChangeEmail(signupRobot: signupRobot,
                                                                         randomEmail: email,
                                                                         emailVerificationWrongCode: emailVerificationWrongCode)
    }
    
    func testSignupNewIntTermsAndConditions() {
        let signupRobot = mainRobot
            .showSignup()
        signupTestCases.testSignupNewIntTermsAndConditions(signupRobot: signupRobot,
                                                           randomName: randomName,
                                                           password: password)
    }
}
