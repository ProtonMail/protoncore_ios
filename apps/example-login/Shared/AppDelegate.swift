//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Igor Kulman on 03/11/2020.
//

import ProtonCore_Doh
import ProtonCore_Log
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
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
