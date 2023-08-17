# How to add Push Notification support to your app


## How to add Push Notification support to your app

In order to add support, follow these steps

1. Open your Xcode project, and select <kbd><samp>File/Add Packages…</samp></kbd> menu item. Navigate to `protoncore/libraries/Proton-PushNotifications`. Before clicking Add Package, select on the bottom picker the project that contains your app targets. Repeat this for as many app targets as you have.
2. Select the Xcode project in the Project Navigator and, in the targets list, select your app target. Scroll down to Frameworks, Libraries and embedded content and there, use the Add Items button to add Proton-PushNotifications library.
3. In your app delegate file, import `Proton_PushNotifications` and in the `didFinishLaunching` method, using your preferred DI management, instantiate `PushNotificationService` (or use the `.shared` instance) and store it for later use.
4. Then, wherever you configure other ProtonCore settings, still within the `didFinishLaunching` call, add a call to `.setup(launchOptions: launchOptions)` passing it the `launchOptions` arguments from `didFinishLaunching`. This will take care of checking/requesting permissions and storing the device token for later use.

    ```swift
    PushNotificationService.shared.setup(launchOptions: launchOptions)
    ```

5. Also in your App Delegate, implement (or extend your existing) delegate remote registration methods and forward them to `PushNotificationService.shared`:

    ```swift
    // substitute NSApplication for UIApplication as appropriate
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationService.shared.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationService.shared.didFailToRegisterForRemoteNotifications(withError: error)
    }
    ```
6. In the **Info.plist** of your app, add a new key `NSUserNotificationsUsageDescription` with a string explaining why your app needs to send user notifications.
