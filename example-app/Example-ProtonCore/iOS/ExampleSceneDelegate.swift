//
//  ExampleSceneDelegate.swift
//  CoreExample - Created on 06/10/2021.
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

import UIKit
import SwiftUI

@available(iOS 13.0, *)
final class ExampleSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        if UIApplication.shared.applicationState == .background ||
            nil == UIApplication.shared.openSessions.compactMap({ $0.scene }).first(where: { $0.activationState != .background })
        {
            SettingsViewController.keymaker.updateAutolockCountdownStart()
        }
        
        var taskID = UIBackgroundTaskIdentifier(rawValue: 0)
        taskID = UIApplication.shared.beginBackgroundTask {
            print("Background Task Timed Out")
            UIApplication.shared.endBackgroundTask(taskID)
            taskID = .invalid
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(20)) {
            print("End Background Task")
            UIApplication.shared.endBackgroundTask(taskID)
            taskID = .invalid
        }
    }
}

