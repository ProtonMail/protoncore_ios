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

### Feature flags usage

The be able to fetch your business unit feature flags you will need to create a configuration to instantiate the `FeatureFlagRepository`.
The configuration is composed of the current id of the user and a list of the flags you want to monitor. This list must conform to  the `FeatureFlagTypeProtocol`.
This list must be provided to filter out unwanted flags as `unleash` endpoint return all existing flags.
The package offers a default implementation for the local and remote data sources. 
Feel free to use them or implement your own.
The following code is an generic example of how you could implement this tool.

```swift
import FeatureFlags
import ProtonCoreNetworking
import ProtonCoreServices

let apiService: APIService = YourNetworkService()

let repo = FeatureFlagsRepository(localDataSource: DefaultLocalFeatureFlagsDataSource(),
                                  remoteDataSource: DefaultRemoteFeatureFlagsDataSource(apiService: apiService))
            
```
You can now use the repo to `get`, `refresh`, `clean` the feature flags.

## Actions

### Refresh flags

```swift
   let newFlags = try await repo.refreshFlags()
```

### Get all current flags

```swift
    let flags = try await repo.getFlags()
```

### Get one flag

```swift
    let value = try await repo.getFlag(for: .thisIsOneFlag)
```
