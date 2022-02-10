//
//  SettingsInitialViewController.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import UIKit
import ProtonCore_Settings
import ProtonCore_Keymaker

/// This class represents the coordinator/wireframe that controls the flow of the app.
/// Notifications for `Keymaker`'s `MainKey` removal and creation are observed from here.
/// Each app should put their code in the "right place" so that the app has the intened behaviour,
/// this setup is completed by starting the autolock count everytime the app is sent to background,
/// see `SceneDelegate`.
final class SettingsInitialViewController: UIViewController {
    let removedKey = Keymaker.Const.removedMainKeyFromMemory
    let obtainedKey = Keymaker.Const.obtainedMainKey

    private var nextScreen: Next = .app {
        didSet { print("State: ", nextScreen) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreenIfNeeded), name: removedKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appScreen), name: obtainedKey, object: nil)
        setNextIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentNext()
    }

    // MARK: - Navigation
    @objc private func lockScreenIfNeeded() {
        guard isProtected else { return }

        guard nextScreen == .app else { return }
        DispatchQueue.main.async {
            self.nextScreen = .lock
            self.removeFollowingVC()
        }
    }

    @objc private func appScreen() {
        guard nextScreen == .lock else { return }
        DispatchQueue.main.async {
            self.nextScreen = .app
            self.removeFollowingVC()
        }
    }

    func presentNext() {
        let vc = self.nextScreen.viewController
        navigationController?.pushViewController(vc, animated: false)
    }

    private func removeFollowingVC() {
        presentedViewController?.dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: false)
    }

    private func setNextIfNeeded() {
        guard isProtected else {
            return appScreen()
        }
        keymaker.mainKeyExists()
    }

    private var keymaker: Keymaker {
        SettingsViewController.keymaker
    }

    private var isProtected: Bool {
        keymaker.isBioProtected || keymaker.isPinProtected
    }
}

private enum Next {
    case lock
    case app

    var viewController: UIViewController {
        switch self {
        case .app:
            return UIStoryboard(name: "Example-Settings", bundle: .main)
                .instantiateViewController(withIdentifier: "SettingsViewController")
        case .lock:
            return PMUnlockViewControllerComposer.assemble(
                header: .drive(subtitle: nil),
                unlocker: SettingsViewController.keymaker,
                logoutManager: SettingsLogoutManager(),
                logoutAlertSubtitle: "By logging out, all files saved for Offline will be deleted from your device?")
        }
    }
}
