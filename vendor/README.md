# Golang libraries

Proton uses some core libraries written in golang, to have a shared implementation for
mobile platforms.

## Flavors

The way golang bindings are generated imposes to have at most one golang runtime per process.
That means that we have to bundle all golang libraries into a single framework.
As some clients require different libraries for product specific features, we
provide different flavors of the golang build.

### Crypto 

The crypto build contains the cryptographic libraries used by all clients:

- [go-srp](https://github.com/ProtonMail/go-srp/) : used for signup and login authentication
- [gopenpgp](https://github.com/ProtonMail/gopenpgp): used for OpenPGP crypto

### VPN

In addition to the cryptographic libraries, the VPN flavor includes a vpn specific library:

- [go-vpn-libs](https://github.com/ProtonVPN/go-vpn-lib)

### Search

In addition to the cryptographic libraries, the Search flavor includes a mail specific library:

- [go-encrypted-search](https://github.com/ProtonMail/go-encrypted-search)

## Golang version

The ideal situation is to have all clients using the latest stable version of golang.
In practice, some clients have experienced crashes when trying to upgrade, and 
some clients need to support iOS versions that are no longer supported by the latest version of golang.
To resolve this situation, we provide frameworks built with different golang versions.
The goal is to have all the clients independently experiment with upgrading the builds to the highest golang version that supports their target OS version.

The 1.15.15 and 1.18.3 builds are legacy builds, and clients should upgrade to 1.17.9 if they need support for iOS 11 and 1.19.2 if they don't.

### Golang 1.15.15
- Builds: 
  - [Crypto-Go1.15.15](Crypto-Go1.15.15)
  - [Crypto+Search-Go1.15.15](Crypto+Search-Go1.15.15)
  - [Crypto+VPN-Go1.15.15](Crypto+VPN-Go1.15.15)
- This is a legacy build, clients should try to upgrade to 1.17.9 or 1.19.2
- Changes in golang >= 1.16 brought some instability for iOS, which blocked some clients from upgrading.
  - New builds use a forked version of golang, made to patch the reported issues.
- Has a known issue (crash can happen) that was fixed in 1.17.6
- iOS Support: iOS >=10

### Golang 1.17.9

- Builds: 
  - [Crypto-Go1.17.9](Crypto-Go1.17.9)
  - [Crypto+Search-Go1.17.9](Crypto+Search-Go1.17.9)
  - [Crypto+VPN-Go1.17.9](Crypto+VPN-Go1.17.9)
- Last stable version to support iOS 11
- Built with a fork of golang to patch known issues that blocked the upgrade from 1.15.15 
- iOS Support: iOS >=11

### Golang 1.18.3

- Builds: 
  - [Crypto-Go1.18.3](Crypto-Go1.18.3)
  - [Crypto+Search-Go1.18.3](Crypto+Search-Go1.18.3)
  - [Crypto+VPN-Go1.18.3](Crypto+VPN-Go1.18.3)
- This is a legacy build, clients should try to upgrade to 1.19.2
- Built with a fork of golang to patch known issues that blocked the upgrade from 1.15.15 
- iOS Support: 
  - VPN Build targets iOS >=12
  - Other builds target iOS >=13

### Golang 1.19.2

- Builds: 
  - [Crypto-Go1.19.2](Crypto-Go1.19.2)
  - [Crypto+Search-Go1.19.2](Crypto+Search-Go1.19.2)
  - [Crypto+VPN-Go1.19.2](Crypto+VPN-Go1.19.2)
- This is the latest version of golang at the time of build
- Built with a fork of golang to patch known issues that blocked the upgrade from 1.15.15 
- iOS Support: 
  - VPN Build targets iOS >=12
  - Other builds target iOS >=13

### Golang 1.19.2 - macOS patch

- Builds: 
  - [Crypto-patched-Go1.19.2](Crypto-patched-Go1.19.2)
- Adds a patch for an issue reported in macOS drive app.