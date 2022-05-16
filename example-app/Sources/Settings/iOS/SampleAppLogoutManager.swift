//
//  SettingsLogoutManager.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import ProtonCore_Log
import ProtonCore_Settings

final class SettingsLogoutManager: LogoutManager {
    func logout(completion: @escaping LogoutAction) {
        PMLog.info("Logout 😢!!!")

        SettingsViewController.keymaker.wipeMainKey()

        // Remove all protection
        if SettingsViewController.keymaker.isBioProtected && SettingsViewController.keymaker.isPinProtected {
            SettingsViewController.keymaker.deactivatePin(completion: { _ in })
            SettingsViewController.keymaker.deactivateBio(completion: { _ in })

        } else if SettingsViewController.keymaker.isBioProtected {
            SettingsViewController.keymaker.deactivateBio(completion: { _ in })

        } else if SettingsViewController.keymaker.isPinProtected {
            SettingsViewController.keymaker.deactivatePin(completion: { _ in })
        }

        completion(.success(Void()))
    }
}
