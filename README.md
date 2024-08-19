# ProtonCore iOS

The set of core iOS modules used by Proton Technologies AG.


## Table of Contents

- [Modules](#modules)
- [Examples](#examples)
- [License](#license)
- [Contributing notice](#contributing-notice)


## Modules

### Account Switcher

UI components for showing the list of logged in account, switch between them, log out, log in another.

Sources: [libraries/AccountSwitcher](libraries/AccountSwitcher)

Platforms supported: iOS


### APIClient

API clients for a subset of small, common Proton APIs.

Sources: [libraries/APIClient](libraries/APIClient)

Platforms supported: iOS, macOS


### Authentication

API client for the Proton Authentication API.

Sources: [libraries/Authentication](libraries/Authentication)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-Authentication/UsingCrypto`
* `ProtonCore-Authentication/UsingCryptoVPN`


### Authentication-KeyGeneration

Extension to the [Authentication](#authentication) module for the key generation operations.

Sources: [libraries/Authentication-KeyGeneration](libraries/Authentication-KeyGeneration)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-Authentication-KeyGeneration/UsingCrypto`
* `ProtonCore-Authentication-KeyGeneration/UsingCryptoVPN`


### Challenge

Gathering information used by the anti-abuse filters to limit fraud and abuse.

Sources: [libraries/Challenge](libraries/Challenge)

Platforms supported: iOS


### Common

Architectural sketch. A set of protocols and basic types to base the architecture on.

Sources: [libraries/Common](libraries/Common)

Platforms supported: iOS, macOS (very limited subset of sources)


### Crypto

Wrapper and delivery mechanism for the go crypto libraries, built into `vendor/Crypto/Crypto.xcframework`. 
More info in [Crypto README](libraries/Crypto/Readme.md).

Sources: [libraries/Crypto](libraries/Crypto)

Uses and deliveres framework: [Crypto.xcframework](vendor/Crypto/Crypto.xcframework)

Platforms supported: iOS, macOS


### Crypto-VPN

Wrapper and delivery mechanism for the go crypto libraries, built into `vendor/Crypto_VPN/Crypto_VPN.xcframework`. 
More info in [Crypto README](libraries/Crypto/Readme.md).

Sources: [libraries/Crypto](libraries/Crypto)

Uses and deliveres framework: [Crypto_VPN.xcframework](vendor/Crypto_VPN/Crypto_VPN.xcframework)

Platforms supported: iOS, macOS


### DataModel

Basic data objects used in various modules.

Sources: [libraries/DataModel](libraries/DataModel)

Platforms supported: iOS, macOS


### DoH

Basic logic for DNS over HTTPS feature.

Sources: [libraries/DoH](libraries/DoH)

Platforms supported: iOS, macOS


### Features

Common cross-app user features. 
Right now only single one: email sending.

Sources: [libraries/Features](libraries/Features)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-Features/UsingCrypto`
* `ProtonCore-Features/UsingCryptoVPN`

### Feature Flags

Common cross-app unleash feature flags. 

README: [Doc](libraries/FeatureFlags/README.md)

Sources: [libraries/FeatureFlags](libraries/FeatureFlags/)

Platforms supported: iOS, macOS


### ForceUpgrade

Logic for handling force upgrade.

Sources: [libraries/ForceUpgrade](libraries/ForceUpgrade)

Platforms supported: iOS, macOS (very limited subset of sources)


### Foundations

Helpers for common tasks. Not really well defined.

Sources: [libraries/Foundations](libraries/Foundations)

Platforms supported: iOS, macOS (very limited subset of sources)


### Hash

Basic hash algo types.

Sources: [libraries/Hash](libraries/Hash)

Platforms supported: iOS, macOS


### HumanVerification

Human verification handling with the UI.

Sources: [libraries/HumanVerification](libraries/HumanVerification)

Platforms supported: iOS, macOS


### Keymaker

Logic related to storing keys and maintaining access to them.

Sources: [libraries/Keymaker](libraries/Keymaker)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-Keymaker/UsingCrypto`
* `ProtonCore-Keymaker/UsingCryptoVPN`


### KeyManager

Crypto operations using keys.

Sources: [libraries/KeyManager](libraries/KeyManager)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-KeyManager/UsingCrypto`
* `ProtonCore-KeyManager/UsingCryptoVPN`


### Log

Logging events. File-backed.

Sources: [libraries/Log](libraries/Log)

Platforms supported: iOS, macOS


### Login

Login and signup services. 
Setting the right account state during login.

Sources: [libraries/Login](libraries/Login)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-Login/UsingCrypto`
* `ProtonCore-Login/UsingCryptoVPN`


### LoginUI

Login and signup UI.

Sources: [libraries/LoginUI](libraries/LoginUI)

Platforms supported: iOS

Variants: 
* `ProtonCore-LoginUI/UsingCrypto`
* `ProtonCore-LoginUI/UsingCryptoVPN`


### Networking

Common networking objects and protocols. 

Sources: [libraries/Networking](libraries/Networking)

Platforms supported: iOS, macOS


### ObfuscatedConstants

A wrapper for sensitive data like test user accounts 
or internal testing environments that are not available publicly.

Sources: [libraries/ObfuscatedConstants](libraries/ObfuscatedConstants)

Platforms supported: iOS, macOS

### Payments

Payments services and logic.

Sources: [libraries/Payments](libraries/Payments)

Platforms supported: iOS, macOS

Variants: 
* `ProtonCore-Payments/UsingCrypto`
* `ProtonCore-Payments/UsingCryptoVPN`


### PaymentsUI

Payments UI.

Sources: [libraries/PaymentsUI](libraries/PaymentsUI)

Platforms supported: iOS

Variants: 
* `ProtonCore-PaymentsUI/UsingCrypto`
* `ProtonCore-PaymentsUI/UsingCryptoVPN`


### Services

Actual network engine. Uses either AFNetworking or Alamofire under the hood.

Sources: [libraries/Services](libraries/Services)

Platforms supported: iOS, macOS


### Settings

UI component for limited app settings.

Sources: [libraries/Settings](libraries/Settings)

Platforms supported: iOS


# TestingToolkit

A number of things helping with unit and UI testing of modules. Submodule-based.

Sources: [libraries/TestingToolkit](libraries/TestingToolkit)

Platforms supported: iOS, macOS


# UIFoundations

Colors, styles and common UI components.

Sources: [libraries/UIFoundations](libraries/UIFoundations)

Platforms supported: iOS, macOS (very limited subset of sources)


# Utilities

A number of common helpers and extensions used in various modules.

Sources: [libraries/Utilities](libraries/Utilities)

Platforms supported: iOS, macOS


# VCard

Delivery mechanism for the VCard library, built into `vendor/VCard/VCard.xcframework`. 
No actual Swift sources here.

Uses and deliveres framework: [VCard.xcframework](vendor/VCard/VCard.xcframework)

Platforms supported: iOS, macOS


## Example app

The example app is located in [the ExampleApp directory](ExampleApp).

## License

The code and data files in this distribution are licensed under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.html) for a copy of this license.

See [LICENSE](LICENSE) file.

This product includes software developed by the "Marcin Krzyzanowski" (http://krzyzanowskim.com/).

## Contributing notice

By contributing to the ProtonCore iOS you accept the [CONTRIBUTION_POLICY](CONTRIBUTION_POLICY.md). Please read and understand before making a contribution.
