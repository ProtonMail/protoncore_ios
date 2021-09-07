//
//  SampleAppLogoutManager.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Settings

final class SampleAppLogoutManager: LogoutManager {
    func logout(completion: @escaping LogoutAction) {
        print("Logout 😢!!!")

        AppDelegate.keymaker.wipeMainKey()

        // Remove all protection
        if AppDelegate.keymaker.isBioProtected && AppDelegate.keymaker.isPinProtected {
            AppDelegate.keymaker.deactivatePin(completion: { _ in })
            AppDelegate.keymaker.deactivateBio(completion: { _ in })

        } else if AppDelegate.keymaker.isBioProtected {
            AppDelegate.keymaker.deactivateBio(completion: { _ in })

        } else if AppDelegate.keymaker.isPinProtected {
            AppDelegate.keymaker.deactivatePin(completion: { _ in })
        }

        completion(.success(Void()))
    }
}
