# FeatureFlags

This package purpose is to helps fetch feature flags and manage **feature flags** comming from the new [Unleash](https://unleash.protontech.ch/) tool.
It contains default implementations for instantiation component.

# What

- [x] Unleash
- [x] Uses of Apple's new structured concurrency (Async/Await)
- [x] Local Storage

## Getting Started
* [Installation](#installation)
* [Feature flags usage](#feature-flags-usage)
* [Actions](#actions)

# Installation

`FeatureFlags` is installed via the official [Swift Package Manager](https://swift.org/package-manager/).  
As it is exposed through SPM you should pull the public github repo for any open source repository.
Otherwise you can pull the gitlab endpoint.

Select `Xcode`>`File`> `Swift Packages`>`Add Package Dependency...`  
and add `https://git@github.com:ProtonMail/protoncore_ios.git`.

## Setup

Import the following:

```swift
import FeatureFlags
import ProtonCoreServices
```

In the startup sequence of your app, setup the `FeatureFlagsRepository` singleton:

```swift
// Set the API service
let apiService = YouAPIService()
FeatureFlagsRepository.shared.setApiService(apiService)

// Set the user ID as soon as you have it (likely in the session refresh steps on app start, and after login)
// Important: setting an empty-string for userId will fetch features flags for an unauthenticated session.
if !userID.isEmpty {
    FeatureFlagsRepository.shared.setUserId(userID)
}

// Fetch updated feature flag values for the logged-in user (or unauthenticated session)
Task {
    try await FeatureFlagsRepository.shared.fetchFlags()
}
```

Alternatively, you can create you own implementation for the local data source of feature flags by 
implementing `LocalFeatureFlagsDataSourceProtocol`.

In this case, you can set your local data source with:

```swift
    let customLocalFeatureFlagsDataSource = MyDataSource()

    FeatureFlagsRepository.shared.updateLocalDataSource(customLocalFeatureFlagsDataSource)
```

You can now use the shared `FeatureFlagsRepository` to fetch and check the value of feature flags.

## Defining you Feature Flag values

### Get the Flag name from Unleash

Go to your project's Unleash dashboard and get the name of your desired feature ("MyFeature" in the example below).

Create an enum conforming to `FeatureFlagTypeProtocol` like:

```swift
public enum MyFlagType: String, FeatureFlagTypeProtocol {
    case myFeature = "MyFeature"
}
```

## Actions

### Fetch flags

This updates the local feature flag data source:

```swift
    try await FeatureFlagsRepository.shared.fetchFlags()
```

`fetchFlags()` uses the `userId` and `apiService` set with `setUserId(_:)` and `setApiService(_:)` respectively.

### Check the value of a feature flag

To check the value of a given feature flag, use:

```swift
    let isMyFeatureEnabled: Bool = FeatureFlagRepository.shared.isEnabled(MyFlagType.myFeature)
```

`isEnabled()` implicitly uses the `userId` and `apiService` set with `setUserId(_:)` and `setApiService(_:)` respectively.

To check the value for a given user, call:

```swift
    let isMyFeatureEnabled: Bool = FeatureFlagRepository.shared.isEnabled(MyFlagType.myFeature, for: userId)
```

where `userId` is the user ID of the logged-in user (useful in multi-user contexts).

IMPORTANT: by default, calls to `isEnabled()` will return the same value for a given user for the duration of 
the app lifecycle.  That is, subsequent calls to update the local data source (`fetchFlags()`) will by default 
not change the value returned from `isEnabled()`.  This is by design to protect against internal inconsistency.

If you wish to read the latest value fetched for a given feature flag and user, call

```swift
    let isMyFeatureEnabled: Bool = FeatureFlagRepository.shared.isEnabled(MyFlagType.myFeature, 
                                                                          for: userId,
                                                                          reloadValue: true)
```


## Logout

On logout, clear the feature flags for that user, and also the user ID set on the shared `FeatureFlagsRepository`.

```Swift
    FeatureFlagsRepository.shared.resetFlags(for: userId)
    FeatureFlagsRepository.shared.clearUserId(userId)
```
