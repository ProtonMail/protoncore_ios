# Golang libraries

Proton uses some core libraries written in golang, to have a shared implementation for
mobile platforms.

Each directory here holds one prebuilt `GoLibs.xcframework` plus the
`build-config.json` it was produced from.

## Flavors

The way golang bindings are generated imposes to have at most one golang runtime per process.
That means that we have to bundle all golang libraries into a single framework.
As some clients require different libraries for product specific features, we
provide different flavors of the golang build.

Every flavor therefore ships a framework named `GoLibs.framework`, so **a single build
must depend on exactly one of them**. Linking two flavors fails with
`Multiple commands produce .../GoLibs.framework`. This is why each flavor has its own
Xcode scheme in `.swiftpm/xcode/xcshareddata/xcschemes/` rather than being built together.

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

### Drive

The Drive flavor bundles the same libraries as the Crypto build, but leaves out the
[gopenpgp-v3-c-api](https://github.com/ProtonMail/gopenpgp-v3-c-api) (the `cgo_api` entry
in `build-config.json`). It is for clients that do not use the v3 API and do not want to
pay for it: dropping it takes the `ios-arm64` slice from about 11 MB to about 9.8 MB.

## Builds

| Directory | SwiftPM binary target | Product to depend on | Extra library | gopenpgp v3 C API |
|---|---|---|---|---|
| `Crypto-Go` | `GoLibsCryptoGo` | `ProtonCoreCryptoGoImplementation` | — | yes |
| `Crypto-patched-Go` | `GoLibsCryptoPatchedGo` | `ProtonCoreCryptoPatchedGoImplementation` | — | yes |
| `Crypto-Go-Drive` | `GoLibsCryptoDriveGo` | `ProtonCoreCryptoDriveGoImplementation` | — | no |
| `Crypto-patched-Go-Drive` | `GoLibsCryptoDrivePatchedGo` | `ProtonCoreCryptoDrivePatchedGoImplementation` | — | no |
| `Crypto+Search-Go` | `GoLibsCryptoSearchGo` | `ProtonCoreCryptoSearchGoImplementation` | go-encrypted-search | no |
| `Crypto+VPN-patched-Go` | `GoLibsCryptoVPNPatchedGo` | `ProtonCoreCryptoVPNPatchedGoImplementation` | go-vpn-lib | no |

All builds currently share the same base:

- golang `1.23.12`
- [gopenpgp](https://github.com/ProtonMail/gopenpgp) `v2.10.0-proton`: used for OpenPGP crypto
- [go-srp](https://github.com/ProtonMail/go-srp/) `v0.0.7`: used for signup and login authentication
- minimum iOS `14.0`, minimum macOS `12.0` (VPN targets macOS `10.15`)
- slices for `ios-arm64`, iOS simulator, Mac Catalyst and macOS
  (the VPN build additionally ships tvOS slices)

The extra libraries are pinned at [go-encrypted-search](https://github.com/ProtonMail/go-encrypted-search)
`v0.0.3` and [go-vpn-lib](https://github.com/ProtonVPN/go-vpn-lib)
`5684efdb259346cfdc93efc938d1549b4b028df8`.

### The `patched` variants

`patched` means the framework was built with a golang fork carrying a patch for a macOS
issue (`fork/go1.23.12-macos-patch` instead of `fork/go1.23.12`) — see the macOS patch note
under [History](#history-golang-versions). It changes nothing about which libraries are
bundled, so `Crypto-Go` and `Crypto-patched-Go` are otherwise equivalent. Clients seeing
the macOS issue should prefer the patched build.

## Using a flavor

The Swift sources are identical for every flavor; the per-flavor targets under
`libraries/CryptoGoImplementation/` are symlinks to a single `Sources` directory, and only
the linked `GoLibs.xcframework` differs. Depend on one product and call
`injectDefaultCryptoImplementation()` to wire it into `ProtonCoreCryptoGoInterface`.

## Updating a build

The frameworks are prebuilt and committed. To refresh one, rebuild from its
`build-config.json` and replace the `GoLibs.xcframework` in place. When adding a new
flavor, remember to point `destination_folder` at its own directory, register the binary
target and product in `Package.swift`, add the source and test symlinks under
`libraries/CryptoGoImplementation/`, and add a scheme for it.

## History: golang versions

All flavors are built with the same golang version today, so the version is no longer part
of the directory names. It used to be: we shipped one set of builds per golang version, and
clients picked the highest one their target OS allowed. The notes below are kept because
they record *why* we build golang from a fork at all, and which upgrades broke which
clients. The directories they refer to no longer exist (hence the plain names rather than
links) — use `git log` if you need the frameworks themselves.

The ideal situation is to have all clients using the latest stable version of golang.
In practice, some clients have experienced crashes when trying to upgrade, and
some clients need to support iOS versions that are no longer supported by the latest version of golang.
To resolve this situation, we provide frameworks built with different golang versions.
The goal is to have all the clients independently experiment with upgrading the builds to the highest golang version that supports their target OS version.

The 1.15.15 and 1.18.3 builds are legacy builds, and clients should upgrade to 1.17.9 if they need support for iOS 11 and 1.19.2 if they don't.

### Golang 1.15.15
- Builds:
  - `Crypto-Go1.15.15`
  - `Crypto+Search-Go1.15.15`
  - `Crypto+VPN-Go1.15.15`
- This is a legacy build, clients should try to upgrade to 1.17.9 or 1.19.2
- Changes in golang >= 1.16 brought some instability for iOS, which blocked some clients from upgrading.
  - New builds use a forked version of golang, made to patch the reported issues.
- Has a known issue (crash can happen) that was fixed in 1.17.6
- iOS Support: iOS >=10

### Golang 1.17.9

- Builds:
  - `Crypto-Go1.17.9`
  - `Crypto+Search-Go1.17.9`
  - `Crypto+VPN-Go1.17.9`
- Last stable version to support iOS 11
- Built with a fork of golang to patch known issues that blocked the upgrade from 1.15.15
- iOS Support: iOS >=11

### Golang 1.18.3

- Builds:
  - `Crypto-Go1.18.3`
  - `Crypto+Search-Go1.18.3`
  - `Crypto+VPN-Go1.18.3`
- This is a legacy build, clients should try to upgrade to 1.19.2
- Built with a fork of golang to patch known issues that blocked the upgrade from 1.15.15
- iOS Support:
  - VPN Build targets iOS >=12
  - Other builds target iOS >=13

### Golang 1.19.2

- Builds:
  - `Crypto-Go1.19.2`
  - `Crypto+Search-Go1.19.2`
  - `Crypto+VPN-Go1.19.2`
- This is the latest version of golang at the time of build
- Built with a fork of golang to patch known issues that blocked the upgrade from 1.15.15
- iOS Support:
  - VPN Build targets iOS >=12
  - Other builds target iOS >=13

### Golang 1.19.2 - macOS patch

- Builds:
  - `Crypto-patched-Go1.19.2`
- Adds a patch for an issue reported in macOS drive app.
