# ``ProtonCoreKeymaker``

iOS Core framework Keymaker

## Overview

In the iOS client team, Keymaker is also called MainKey. It was built for an intermediate layer of protection to protect the data when the iOS sandbox is compromised. Or someone managed to dump the keychain.
The Mainkey is protected by biometric authentication and a hardware chip or Pin code. We also announced it to the public as a security feature. 

## Topics

### Essentials

- <doc:/tutorials/Keymaker>
- <doc:GettingStarted>

### Keymaker

- ``Keymaker``
- ``MainKey``

### Protection Strategy

- ``BioProtection``
- ``PinProtection``
- ``RandomPinProtection``
- ``NoneProtection``
- ``ProtectionStrategy``

### Auto Locker

- ``Autolocker``
- ``AutolockTimeout``
- ``Clock``
- ``SettingsProvider``

### Crypto
- ``CryptoSubtle``
- ``Locked``

### Transformer

- ``CryptoTransformer``
- ``StringCryptoTransformer``

### Keychain

- ``Keychain``

### Notification Events

- ``Constants``

### Errors

- ``Errors``
- ``LockedErrors``
