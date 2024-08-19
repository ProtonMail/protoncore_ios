# Crypto

This repo is a wrapper around Crypto.framework to allow its usage as standalone package. Frameworks for different architectures are packed into one Xcframework. This is a pre-compiled version and it complied from repo [GopenPGP](https://github.com/ProtonMail/gopenpgp)

## Build instructions

* Read and complete the prerequisites [build tool readme](https://github.com/ProtonMail/gomobile-build-tool#prerequisites)

* clone the build tool

    ```[git]
    git clone https://github.com/ProtonMail/gomobile-build-tool.git gomobile-build-tool
    ```

* complie the crypto with [build config file](build-config.json). [build configuration doc](https://github.com/ProtonMail/gomobile-build-tool#configuration-of-the-build)

* command:

    ```[bash]
    cd gomobile-build-tool
    make build cfg=../ProtonCore/vender/Crypto/build-config.json
    #then wait the compile process to be finished
    ```

* After the compile process is completed. you will find the new xcframework in output folder `gomobile-build-tool/out/Crypto.xcframework`.

* Update this repo [Update framework](#Update-framework)

## Common issues

* Err: The output of `go version` does not match the one in your configuration

    Find out what go version you have installed by running the command: `go version`
    open the build-config.json and modify the `"go_version"` to match your local go version. For example change it to "go_version":"1.16.6".

## Update framework

In order to update the build of Crypto.framework inside this pod:

1. drop-in a new build of Crypto.xcframework into the repo `$COREROOT/vender/Crypto/`
2. update version in `$COREROOT/ProtonCore-Crypto.podspec` so all the dependant pods will know they need to re-fetch it
3. tag the commit accordingly

**Important:**
CocaPods supports xcframeworks starting v1.9, older versions will fail to install xcframework as a dependency.
CocoaPods has a bug (https://github.com/CocoaPods/CocoaPods/issues/9525) that does not let Xcode see simulator binary of xcframewrok correctly.
Temporary workaround is to manually change the order of framework search paths in xcconfig files.
Until that bug is fixed, please use v1.0.0 of this pod or install xcframework manually.
