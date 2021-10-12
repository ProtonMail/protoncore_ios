//
//  ExampleAppDelegate.swift
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

@main
class ExampleAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "DefaultConfiguration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        var taskID = UIBackgroundTaskIdentifier(rawValue: 0)
        taskID = application.beginBackgroundTask {
            print("Background Task Timed Out")
            application.endBackgroundTask(taskID)
            taskID = .invalid
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(20)) {
            print("End Background Task")
            application.endBackgroundTask(taskID)
            taskID = .invalid
        }
    }
}